docklet_battery_sources = [
  'BatteryDockItem.vala',
  'BatteryDocklet.vala',
  'BatteryUPowerDockItem.vala',
  'BatteryPreferences.vala',
]

shared_module(
  'docklet-battery',
  docklet_battery_sources,
  dependencies: [plank_dep, plank_base_dep],
  install: true,
  install_dir: docklets_dir,
)
