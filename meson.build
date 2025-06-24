project(
  'plank-reloaded',
  'c',
  'cpp',
  'vala',
  version: '0.11.135',
  meson_version: '>= 0.59.0',
  license: 'GPL3',
)

# Generate ChangeLog from git log
git = find_program('git', required: false)
if git.found() and run_command(git, 'rev-parse', '--git-dir', check: false).returncode() == 0
  # Only generate ChangeLog if we're in a git repository
  custom_target(
    'changelog',
    output: 'ChangeLog',
    command: [
      'sh',
      '-c', '''if test -d "@0@/.git"; then
           @0@/build-aux/gitlog-to-changelog --format='%s%n%n%b%n' --no-cluster --strip-tab --strip-cherry-pick | fmt --split-only --width=80 > @OUTPUT@
         else
           echo "Git checkout required to generate ChangeLog" > @OUTPUT@
         fi'''.format(meson.project_source_root()),
    ],
    build_by_default: true,
  )
endif

# Library versioning
lt_current = '1'
lt_revision = '0'
lt_age = '0'
lib_version = '@0@.@1@.@2@'.format(lt_current, lt_revision, lt_age)
lib_soversion = lt_current

production_release = get_option('production-release')
if not production_release
  git_version = run_command('git', 'describe', '--tags', check: false).stdout().strip()
  if git_version != ''
    version_parts = git_version.split('-')
    if version_parts.length() > 1
      plank_version = version_parts[0]
      git_revision = version_parts[2] # Store git hash separately
    else
      plank_version = git_version
      git_revision = ''
    endif
  else
    plank_version = meson.project_version()
    git_revision = ''
  endif
else
  plank_version = meson.project_version()
endif

version_array = plank_version.split('.')

# Generate version file for dist
custom_target(
  '.version',
  output: '.version',
  command: ['echo', plank_version],
  capture: true,
  build_by_default: true,
)

gnome = import('gnome')
gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
i18n = import('i18n')
cc = meson.get_compiler('c')
cpp = meson.get_compiler('cpp')

vala_version_required = '0.34.0'
vala = meson.get_compiler('vala')
if not vala.version().version_compare('>= @0@'.format(vala_version_required))
  error('Valac >= @0@ required!'.format(vala_version_required))
endif

data_dir = join_paths(get_option('prefix'), get_option('datadir'))
docklets_dir = join_paths(get_option('prefix'), get_option('libdir'), 'plank', 'docklets')
pkgdata_dir = join_paths(get_option('prefix'), get_option('datadir'), 'plank')
pkglib_dir = join_paths(get_option('prefix'), get_option('libdir'), 'plank')

config_inc_dir = include_directories('.')

conf = configuration_data()
conf.set_quoted('PACKAGE', meson.project_name())
conf.set_quoted('PACKAGE_BUGREPORT', 'https://github.com/zquestz/plank-reloaded/issues')
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_STRING', 'Plank Reloaded')
conf.set_quoted('PACKAGE_TARNAME', meson.project_name())
conf.set_quoted('PACKAGE_URL', 'https://github.com/zquestz/plank-reloaded')
conf.set_quoted('PACKAGE_VERSION', plank_version)
conf.set_quoted('DATADIR', data_dir)
conf.set_quoted('PKGDATADIR', pkgdata_dir)
conf.set_quoted('PKGLIBDIR', pkglib_dir)
conf.set_quoted('DOCKLETSDIR', docklets_dir)
conf.set_quoted('RELEASE_NAME', 'Still stupidly simple.')
conf.set_quoted('VERSION', plank_version)
conf.set_quoted('VERSION_INFO', (production_release ? 'Release' : 'Development'))
conf.set_quoted('BUILD_VERSION', plank_version)
conf.set('VERSION_MAJOR', version_array[0])
conf.set('VERSION_MINOR', version_array[1])
conf.set('VERSION_MICRO', version_array[2])
conf.set('VERSION_NANO', (version_array.length() > 3 ? version_array[3] : 0))
configure_file(input: 'config.h.meson', output: 'config.h', configuration: conf)

customconf = configuration_data()
customconf.set('GETTEXT_PACKAGE', meson.project_name())
customconf.set('PLANK_MAJOR_VERSION', version_array[0])
customconf.set('PLANK_MINOR_VERSION', version_array[1])
customconf.set('PLANK_MICRO_VERSION', version_array[2])
customconf.set('PLANK_NANO_VERSION', (version_array.length() > 3 ? version_array[3] : 0))

pkgconf = configuration_data()
pkgconf.set('PACKAGE_VERSION', plank_version)
pkgconf.set('prefix', get_option('prefix'))
pkgconf.set('exec_prefix', '${prefix}')
pkgconf.set('libdir', '${prefix}/@0@'.format(get_option('libdir')))
pkgconf.set('bindir', '${exec_prefix}/@0@'.format(get_option('bindir')))
pkgconf.set('datarootdir', '${prefix}/@0@'.format(get_option('datadir')))
pkgconf.set('datadir', '${datarootdir}')
pkgconf.set('includedir', '${prefix}/@0@'.format(get_option('includedir')))

add_project_arguments(
  [
    '--target-glib=2.48',
    '--hide-internal',
    '--enable-deprecated',
    '--vapidir=' + join_paths(meson.project_source_root(), 'vapi'),
  ],
  language: 'vala',
)
add_project_arguments(
  [
    '-Wno-discarded-qualifiers',
    '-Wno-incompatible-pointer-types',
    '-Wno-unused',
    '-Wl,--enable-new-dtags',

    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    '-DGMENU_I_KNOW_THIS_IS_UNSTABLE',
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',

    '-DGLIB_VERSION_MIN_REQUIRED=GLIB_VERSION_2_48',
    '-DGLIB_VERSION_MAX_ALLOWED=GLIB_VERSION_2_48',
    '-DGDK_VERSION_MIN_REQUIRED=GDK_VERSION_3_10',
    '-DGDK_VERSION_MAX_ALLOWED=GDK_VERSION_3_10',
  ],
  language: 'c',
)

# Dependencies
glib_version_required = '2.48.0'
gtk_version_required = '3.10.0'
gdk_pixbuf_version_required = '2.26.0'
bamf_version_required = '0.4.0'
cairo_version_required = '1.13'

gio_dep = [
  dependency('gio-2.0', version: '>= @0@'.format(glib_version_required)),
  dependency('gio-unix-2.0'),
]
gmodule_dep = dependency('gmodule-2.0', version: '>= @0@'.format(glib_version_required))
gtk_dep = [
  dependency('gtk+-3.0', version: '>= @0@'.format(gtk_version_required)),
  dependency('gdk-x11-3.0'),
]
dependency('gdk-pixbuf-2.0', version: '>= @0@'.format(gdk_pixbuf_version_required))
gee_dep = dependency('gee-0.8')
bamf_dep = dependency('libbamf3', version: '>= @0@'.format(bamf_version_required))
dependency('cairo', version: '>= @0@'.format(cairo_version_required))
wnck_x11_dep = [dependency('libwnck-3.0'), dependency('x11')]
gnomemenu_dep = dependency('libgnome-menu-3.0')
posix_dep = vala.find_library('posix')
m_dep = cc.find_library('m', required: false)

plank_base_dep = [gio_dep, gee_dep, gtk_dep, bamf_dep]

# Support dynamic quicklists provided with dbusmenu
enable_dbusmenu = get_option('enable-dbusmenu')
if enable_dbusmenu != 'no'
  want_dbusmenu = (enable_dbusmenu == 'yes')
  dbusmenu_glib_dep = dependency('dbusmenu-glib-0.4', required: false)
  dbusmenu_gtk_dep = dependency('dbusmenu-gtk3-0.4', required: false)
  if dbusmenu_glib_dep.found() and dbusmenu_gtk_dep.found()
    add_project_arguments(
      '--define', 'HAVE_DBUSMENU',
      '--pkg', 'dbusmenu-glib-0.4',
      '--pkg', 'dbusmenu-gtk3-0.4',
      language: 'vala',
    )
    plank_base_dep += [dbusmenu_glib_dep, dbusmenu_gtk_dep]
  elif want_dbusmenu
    error('No dbusmenu support possible which was explicitly requested.')
  endif
else
  dbusmenu_glib_dep = []
  dbusmenu_gtk_dep = []
endif

# Support barrier-supported unhiding using Xinput 2.3
enable_barriers = get_option('enable-barriers')
if enable_barriers != 'no'
  want_barriers = (enable_barriers == 'yes')
  xinput_dep = dependency('xi', required: false)
  xfixes_dep = dependency('xfixes', required: false)
  if cc.has_function('XIBarrierReleasePointer', dependencies: xinput_dep) and cc.has_function('XFixesDestroyPointerBarrier', dependencies: xfixes_dep)
    add_project_arguments(
      '--define', 'HAVE_BARRIERS',
      '--pkg', 'xi',
      '--pkg', 'xfixes',
      language: 'vala',
    )
  elif want_barriers
    error('No barriers support possible which was explicitly requested.')
  endif
else
  xinput_dep = []
  xfixes_dep = []
endif

# Run checks and add build-flags to e.g. differenciate between Linux and BSD
if cc.has_header('sys/prctl.h')
  add_project_arguments('--define', 'HAVE_SYS_PRCTL_H', language: 'vala')
endif

# Enable output of benchmarking data
enable_benchmark = get_option('enable-benchmark')
if enable_benchmark
  add_project_arguments('--define', 'BENCHMARK', language: 'vala')
endif

# Google Mock support
if get_option('enable-gmock')
  gmock_dep = dependency('gmock', required: true)
  gtest_dep = dependency('gtest', required: true)
  add_project_arguments(
    '--pkg', 'gtest',
    '--pkg', 'gmock',
    '--define', 'HAVE_GMOCK',
    language: 'vala',
  )
  add_project_arguments('-DHAVE_GMOCK', language: 'c')
endif

subdir('data')
subdir('po')
subdir('lib')
subdir('src')
subdir('docklets')
subdir('examples')
subdir('tests')
subdir('docs')

run_env = environment()
run_env.set('GSETTINGS_SCHEMA_DIR', meson.current_build_dir() / 'data')
run_env.set('PLANK_DOCKLET_DIRS', meson.current_build_dir() / 'docklets')

run_target(
  'run',
  command: [plank_bin, '-v'],
  env: run_env,
  depends: [
    plank_bin,
    plank_gschema_compile,
  ],
)

gdb = find_program('gdb', required: false)
if gdb.found()
  run_target(
    'run-debug',
    command: [gdb, '--args', plank_bin.full_path(), '-v'],
    env: run_env,
    depends: [
      plank_bin,
      plank_gschema_compile,
    ],
  )
endif

install_data(
  'README.md',
  install_dir: join_paths(get_option('datadir'), 'doc', 'plank-reloaded'),
)

# Dist script to include additional files
meson.add_dist_script(
  'sh',
  '-c', '''
  cp @0@/COPYING.LGPL2.1 @1@/
  cp @0@/COPYRIGHT @1@/
  cp @0@/HACKING.md @1@/
  cp @0@/README.md @1@/
'''.format(meson.project_source_root(), meson.project_build_root() / 'meson-dist'),
)
