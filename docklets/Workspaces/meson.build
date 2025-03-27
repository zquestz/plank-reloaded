docklet_workspaces_sources = [
  'WorkspacesDockItem.vala',
  'WorkspacesDocklet.vala',
  'WorkspacesPreferences.vala',
]

shared_module(
  'docklet-workspaces',
  docklet_workspaces_sources,
  dependencies: [plank_dep, plank_base_dep, gnomemenu_dep, wnck_x11_dep],
  install: true,
  install_dir: docklets_dir,
)
