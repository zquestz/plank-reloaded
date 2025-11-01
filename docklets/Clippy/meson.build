docklet_clippy_sources = [
  'ClippyDockItem.vala',
  'ClippyDocklet.vala',
  'ClippyPreferences.vala',
  'ClippyClipboardItem.vala',
]

keybinder_dep = dependency('keybinder-3.0', required: false)

clippy_deps = [plank_dep, plank_base_dep]
clippy_vala_args = []

if keybinder_dep.found()
  clippy_deps += keybinder_dep
  clippy_vala_args += ['--pkg=keybinder-3.0']
endif

shared_module(
  'docklet-clippy',
  docklet_clippy_sources,
  dependencies: clippy_deps,
  vala_args: clippy_vala_args,
  install: true,
  install_dir: docklets_dir,
)
