help2man = find_program('help2man', required: false)
if help2man.found()
  custom_target(
    'plank-man',
    depends: plank_bin,
    input: 'plank.h2m',
    output: 'plank.1',
    command: [
      help2man,
      '--no-info',
      '--include=@INPUT@',
      '--output=@OUTPUT@',
      plank_bin.full_path(),
    ],
    build_by_default: true,
  )
endif

install_man('plank.1')

# Docs
valadoc = find_program('valadoc', required: get_option('enable-docs'))
if get_option('enable-docs')
  # Base Vala package flags
  vala_pkgs = [
    '--pkg', 'gio-unix-2.0',
    '--pkg', 'gmodule-2.0',
    '--pkg', 'gtk+-3.0',
    '--pkg', 'gdk-x11-3.0',
    '--pkg', 'gdk-pixbuf-2.0',
    '--pkg', 'cairo',
    '--pkg', 'gee-0.8',
    '--pkg', 'libbamf3',
    '--pkg', 'libwnck-3.0',
    '--pkg', 'posix',
    '--pkg', 'x11',
    '--pkg', 'compat',
    '--pkg', 'config',
  ]

  # Base Vala definitions
  vala_defines = [
    '--define', 'HAVE_SYS_PRCTL_H',
  ]

  # Optional: dbusmenu support
  enable_dbusmenu = get_option('enable-dbusmenu')
  if enable_dbusmenu != 'no'
    dbusmenu_glib_dep = dependency('dbusmenu-glib-0.4', required: false)
    dbusmenu_gtk_dep = dependency('dbusmenu-gtk3-0.4', required: false)
    if dbusmenu_glib_dep.found() and dbusmenu_gtk_dep.found()
      vala_pkgs += ['--pkg', 'dbusmenu-glib-0.4', '--pkg', 'dbusmenu-gtk3-0.4']
      vala_defines += ['--define', 'HAVE_DBUSMENU']
    endif
  endif

  # Optional: barriers support
  enable_barriers = get_option('enable-barriers')
  if enable_barriers != 'no'
    xinput_dep = dependency('xi', required: false)
    xfixes_dep = dependency('xfixes', required: false)
    if cc.has_function('XIBarrierReleasePointer', dependencies: xinput_dep) and cc.has_function('XFixesDestroyPointerBarrier', dependencies: xfixes_dep)
      vala_pkgs += ['--pkg', 'xi', '--pkg', 'xfixes']
      vala_defines += ['--define', 'HAVE_BARRIERS']
    endif
  endif

  # Get source files
  plank_doc_files = []
  foreach source : plank_lib_sources
    plank_doc_files += join_paths(meson.project_source_root(), 'lib', source)
  endforeach
  plank_doc_files += plank_version_sources

  # Common valadoc flags
  valadoc_flags = [
    '--force',
    '--verbose',
    '--package-name', meson.project_name(),
    '--package-version', meson.project_version(),
    '--pkg', 'plank-internal',
    '--vapidir=' + meson.current_build_dir() / '../lib',
    '--vapidir=' + meson.project_source_root() / 'vapi',
  ] + vala_pkgs + vala_defines

  # Vala docs (devhelp)
  vala_docs = custom_target(
    'vala-doc',
    input: plank_doc_files,
    output: 'vala-doc',
    depends: plank_internal_lib,
    command: [
      valadoc,
      '-o', '@OUTPUT@',
      '--doclet=devhelp',
      valadoc_flags,
      '@INPUT@',
    ],
    build_by_default: true,
    install: true,
    install_dir: get_option('datadir') / 'doc' / meson.project_name(),
  )

  # C docs (gtkdoc)
  c_docs = custom_target(
    'c-doc',
    input: plank_doc_files,
    output: 'c-doc',
    depends: [plank_internal_lib, plank_lib],
    command: [
      valadoc,
      '-X',
      '-l',
      '-X', meson.current_build_dir() / '../lib/libplank.so',
      '-X', meson.current_build_dir() / '../lib/plank.h',
      '-o', '@OUTPUT@',
      '--doclet=gtkdoc',
      valadoc_flags,
      '@INPUT@',
    ],
    build_by_default: false,
  )

  # HTML docs
  web_docs = custom_target(
    'web-doc',
    input: plank_doc_files,
    output: 'web-doc',
    depends: plank_internal_lib,
    command: [
      valadoc,
      '-o', '@OUTPUT@',
      '--doclet=html',
      valadoc_flags,
      '@INPUT@',
    ],
    build_by_default: false,
  )

  run_target(
    'all-docs',
    command: ['echo', 'Building all documentation...'],
    depends: [vala_docs, c_docs, web_docs],
  )

  # Clean target for docs
  run_target(
    'clean-docs',
    command: ['rm', '-rf', 'c-doc', 'vala-doc', 'web-doc'],
  )
endif
