plank_bin_sources = [
  'Main.vala',
  'MonitorManager.vala',
]

# The monitor manager reads EDIDs through XRandR, which has no Vala
# bindings, so its C helper builds apart from the Vala sources
monitor_edid_lib = static_library(
  'monitor-edid',
  'monitor-edid.c',
  dependencies: [gtk_dep, dependency('xrandr'), dependency('x11')],
)

plank_bin = executable(
  'plank',
  plank_bin_sources,
  link_with: monitor_edid_lib,
  dependencies: [plank_dep, plank_internal_dep, plank_base_dep, posix_dep],
  include_directories: [config_inc_dir, include_directories('.')],
  install: true,
  vala_args: [
    '--pkg', 'config',
    '--vapidir', meson.current_source_dir(),
    '--pkg', 'monitor-edid',
  ],
)
