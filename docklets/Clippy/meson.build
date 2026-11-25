docklet_clippy_sources = [
  'ClippyDockItem.vala',
  'ClippyDocklet.vala',
  'ClippyPreferences.vala',
  'ClippyClipboardItem.vala',
  'ClippyPopup.vala',
]

shared_module(
  'docklet-clippy',
  docklet_clippy_sources,
  dependencies: [plank_dep, plank_base_dep, wnck_x11_dep, dependency('xtst')],
  install: true,
  install_dir: docklets_dir,
)
