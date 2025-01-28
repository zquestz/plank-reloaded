tests_bin_sources = [
  'Controller.vala',
  'Drawing.vala',
  'Items.vala',
  'Main.vala',
  'Preferences.vala',
  'TestHelper.vala',
  'Widgets.vala',
]

test_home = meson.current_build_dir() / 'plank_tests'

# Create clean directory target
clean_test_dir = custom_target(
  'clean-test-dir',
  output: 'clean_test_dir_stamp',
  command: [
    'sh',
    '-c', 'rm -rf "@0@" && mkdir -p "@0@" && touch @OUTPUT@'.format(test_home),
  ],
  build_always_stale: true,
)

tests_bin = executable(
  'tests',
  tests_bin_sources,
  'test-config.vapi',
  dependencies: [plank_dep, plank_internal_dep, plank_base_dep, wnck_x11_dep],
  c_args: [
    '-DTEST_DATA_DIR="@0@/tests/data"'.format(meson.project_source_root()),
    '-DTEST_HOME_DIR="@0@"'.format(test_home),
  ],
)

dock_bin_sources = [
  'Dock.vala',
]

dock_bin = executable(
  'dock',
  dock_bin_sources,
  'test-config.vapi',
  plank_gschema_compile,
  dependencies: [plank_dep, plank_base_dep],
)

test_env = environment()
test_env.set('HOME', test_home)
test_env.set('GSETTINGS_SCHEMA_DIR', meson.current_build_dir() / '../data')
test_env.set('PLANK_DOCKLET_DIRS', meson.current_build_dir() / '../docklets')

# GMock tests setup
if get_option('enable-gmock')
  gtest_dep = dependency('gtest', required: true)
  gmock_dep = dependency('gmock', required: true)

  gmock_test = executable(
    'gmock-tests',
    'gmock/main.cpp',
    dependencies: [gtest_dep, gmock_dep, plank_dep, plank_base_dep],
    include_directories: [include_directories('../lib'), include_directories('../src')],
  )

  test(
    'plank-gmock-tests',
    gmock_test,
    env: test_env,
    workdir: meson.current_build_dir(),
    depends: [clean_test_dir],
    protocol: 'gtest',
  )
endif

# Headless test setup
if get_option('enable-headless-tests')
  xvfb_run = find_program('xvfb-run', required: true)
  dbus_run = find_program('dbus-run-session', required: true)

  # Main test suite
  test(
    'plank-tests',
    xvfb_run,
    args: [
      '--auto-servernum',
      '--server-args=-screen 0 1280x1024x24',
      dbus_run.full_path(),
      tests_bin.full_path(),
    ],
    env: test_env,
    workdir: meson.current_build_dir(),
    depends: [clean_test_dir],
    protocol: 'tap',
    timeout: 120,
  )

  # Dock test
  test(
    'dock-test',
    xvfb_run,
    args: [
      '--auto-servernum',
      '--server-args=-screen 0 1280x1024x24',
      dbus_run.full_path(),
      dock_bin.full_path(),
      '-n', 'test1',
    ],
    env: test_env,
    workdir: meson.current_build_dir(),
    depends: [clean_test_dir],
    protocol: 'exitcode',
    timeout: 60,
  )
else
  # Regular test without headless setup
  test(
    'plank-tests',
    tests_bin,
    env: test_env,
    workdir: meson.current_build_dir(),
    depends: [clean_test_dir],
    protocol: 'tap',
  )

  test(
    'dock-test',
    dock_bin,
    args: ['-n', 'test1'],
    env: test_env,
    workdir: meson.current_build_dir(),
    depends: [clean_test_dir],
    protocol: 'exitcode',
  )
endif
