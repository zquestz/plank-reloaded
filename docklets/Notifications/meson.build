docklet_notifications_sources = [
  'NotificationsPreferences.vala',
  'NotificationsDockItem.vala',
  'NotificationsDocklet.vala',
]

shared_module(
  'docklet-notifications',
  docklet_notifications_sources,
  dependencies: [plank_dep, plank_base_dep, gnomemenu_dep],
  install: true,
  install_dir: docklets_dir,
)
