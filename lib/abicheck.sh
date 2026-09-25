#!/bin/sh
#
# Compares the public ABI of libplank (plank.h) against the committed
# baseline in plank.abi.
#
# Third-party docklets are prebuilt binaries that subclass exported libplank
# classes, so the baseline is the contract. It records every public struct
# member in order (including class structs, whose members are the virtual
# method slots), every enum member with its value, every callback typedef,
# every public function prototype, and every exported variable. Any
# difference fails, additions included, so each ABI change is a deliberate
# baseline update that shows up in review.
#
# Usage:
#   abicheck.sh HEADER BASELINE VALAC_VERSION           check the header
#   abicheck.sh --update HEADER BASELINE VALAC_VERSION  regenerate the baseline
#
# From a meson build directory:
#   meson test abi-check
#   meson compile abi-update
#
# The baseline records the valac release series that generated it. Other
# series may format plank.h differently, so the check is skipped (exit 77)
# rather than reporting a false failure.

set -eu

update=false
if [ "${1-}" = "--update" ]; then
	update=true
	shift
fi

if [ $# -ne 3 ]; then
	echo "usage: $0 [--update] HEADER BASELINE VALAC_VERSION" >&2
	exit 2
fi

header=$1
baseline=$2
series="valac $(printf '%s\n' "$3" | cut -d. -f1,2)"

if [ ! -r "${header}" ]; then
	echo "$0: cannot read ${header}" >&2
	exit 2
fi

if ! ${update}; then
	if [ ! -r "${baseline}" ]; then
		echo "$0: cannot read ${baseline}, generate it with: meson compile -C <builddir> abi-update" >&2
		exit 2
	fi

	recorded=$(sed -n 1p "${baseline}")
	if [ "${recorded}" != "# ${series}" ]; then
		echo "Skipping: ${baseline} was generated with ${recorded#\# }, this build uses ${series}"
		exit 77
	fi
fi

entries=$(mktemp "${TMPDIR:-/tmp}/plank-abi.XXXXXX")
trap 'rm -f "${entries}"' EXIT
trap 'exit 1' HUP INT TERM

# Writes one line per ABI element. Wrapped declarations are joined, and
# struct and enum bodies are split on ';' and ',' rather than on line
# breaks, so the result does not depend on where valac wraps them.
awk '
function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
function squash(s) { gsub(/[ \t]+/, " ", s); return trim(s) }
function emit(kind, name, body, sep,    n, parts, i, m, k) {
	n = split(body, parts, sep)
	k = 0
	for (i = 1; i <= n; i++) {
		m = squash(parts[i])
		if (m == "")
			continue
		printf "%s %s %03d %s\n", kind, name, ++k, m
	}
}
function emit_function(s) {
	sub(/^VALA_EXTERN[ \t]+/, "", s)
	gsub(/G_GNUC_[A-Z_]+([ \t]*[(][^)]*[)])?/, "", s)
	s = squash(s)
	sub(/[ \t]*;$/, "", s)
	match(s, /plank_[A-Za-z0-9_]+ [(]/)
	print "function " substr(s, RSTART, RLENGTH - 2) " " s
}
function emit_variable(s) {
	sub(/^(VALA_EXTERN|extern)[ \t]+/, "", s)
	s = squash(s)
	sub(/[ \t]*;$/, "", s)
	match(s, /plank_[A-Za-z0-9_]+$/)
	print "variable " substr(s, RSTART, RLENGTH) " " s
}
mode == "struct" {
	if ($0 ~ /^[}];/) {
		emit("struct", name, body, ";")
		mode = ""
	} else
		body = body " " $0
	next
}
mode == "enum" {
	if ($0 ~ /^[}]/) {
		name = $0
		sub(/^[}][ \t]*/, "", name)
		sub(/;.*$/, "", name)
		emit("enum", name, body, ",")
		mode = ""
	} else
		body = body " " $0
	next
}
mode == "callback" || mode == "function" {
	body = body " " $0
	if ($0 ~ /;/) {
		if (mode == "callback")
			print "callback " squash(body)
		else
			emit_function(body)
		mode = ""
	}
	next
}
/^struct _[A-Za-z0-9_]+ [{]$/ { name = $2; body = ""; mode = "struct"; next }
/^typedef enum/ { body = ""; mode = "enum"; next }
/^typedef .*[(][*]/ {
	body = $0
	if ($0 ~ /;/)
		print "callback " squash(body)
	else
		mode = "callback"
	next
}
/^#/ { next }
!/[(]/ && /[ *]plank_[A-Za-z0-9_]+;[ \t]*$/ { emit_variable($0); next }
/plank_[A-Za-z0-9_]+ [(]/ {
	body = $0
	if ($0 ~ /;/)
		emit_function(body)
	else
		mode = "function"
	next
}
' "${header}" > "${entries}"

if ! grep -q . "${entries}"; then
	echo "$0: found no ABI elements in ${header}" >&2
	exit 1
fi

# The baseline is the valac series followed by the sorted elements.
if ${update}; then
	{ printf '# %s\n' "${series}"; LC_ALL=C sort "${entries}"; } > "${baseline}"
	echo "Updated ${baseline}"
	exit 0
fi

if { printf '# %s\n' "${series}"; LC_ALL=C sort "${entries}"; } | diff -u "${baseline}" -; then
	exit 0
fi

echo "libplank ABI differs from ${baseline}." >&2
echo "If the change is intended, regenerate the baseline: meson compile -C <builddir> abi-update" >&2
exit 1
