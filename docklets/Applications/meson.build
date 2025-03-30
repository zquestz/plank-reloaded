docklet_applications_sources = [
  'ApplicationsPreferences.vala',
  'ApplicationsDockItem.vala',
  'ApplicationsDocklet.vala',
]

shared_module(
  'docklet-applications',
  docklet_applications_sources,
  dependencies: [plank_dep, plank_base_dep, gnomemenu_dep],
  install: true,
  install_dir: docklets_dir,
)
