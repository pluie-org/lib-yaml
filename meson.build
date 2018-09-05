#^# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
#  @software    :    pluie-yaml       <https://git.pluie.org/pluie/lib-yaml>
#  @version     :    0.56
#  @type        :    library
#  @date        :    2018
#  @license     :    GPLv3.0          <http://www.gnu.org/licenses/>
#  @author      :    a-Sansara        <[dev]at[pluie]dot[org]>
#  @copyright   :    pluie.org        <http://www.pluie.org>
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  This file is part of pluie-yaml.
#
#  pluie-yaml is free software (free as in speech) : you can redistribute it
#  and/or modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation, either version 3 of the License,
#  or (at your option) any later version.
#
#  pluie-yaml is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License
#  along with pluie-yaml.  If not, see  <http://www.gnu.org/licenses/>.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #^#

project('pluie-yaml', ['vala', 'c'], version:'0.5')

cc            = meson.get_compiler('c')
version       = meson.project_version()
bindir        = join_paths(get_option('prefix'), get_option('bindir'))
datadir       = join_paths(get_option('prefix'), get_option('datadir'), 'pluie/yaml')
libdir        = join_paths(get_option('prefix'), get_option('libdir'), 'pkgconfig')
incdir        = join_paths(get_option('prefix'), get_option('includedir'), 'pluie')
conf          = configuration_data()
conf.set('VERSION'     , version)
conf.set('INSTALL_PATH', bindir)
if get_option('LOCAL')
    conf.set('DATA_PATH'   , './resources')
else
    conf.set('DATA_PATH'   , datadir)
endif

configure_file(
  input: 'src/vala/install.vala.in',
  output: 'install.vala',
  configuration: conf
)

install_data([
        'resources/main.yml',
        'resources/tag.yml',
        'resources/bug.yml',
        'resources/test.yml',
        'resources/test.json'
    ],
    install_dir : datadir
)
install_data('resources/config/db.yml', install_dir : join_paths(datadir, 'config'))
install_data('resources/config/subdir/test.yml', install_dir : join_paths(datadir, 'config/subdir'))

subdir('src')

add_global_arguments('-D DEBUG', language : 'valac')


libpluie_yaml = library(
    'pluie-yaml-' + version, 
    src_files,
    vala_header  : 'pluie_yaml.h',
    vala_vapi    : 'pluie-yaml-' +version+'.vapi',
    dependencies : [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gmodule-2.0'),
        dependency('gio-2.0'),
        dependency('gee-0.8'),
        dependency('pluie-echo-0.2'),
        cc.find_library('m', required : false),
        cc.find_library('yaml', required : true)
    ],
    install      : true,
    version      : version,
    install_dir  : [get_option('libdir'), incdir, true]
)

pkgconfig = import('pkgconfig')
pkgconfig.generate(
    libraries   : libpluie_yaml,
    requires    : 'glib-2.0 gmodule-2.0 gobject-2.0 gio-2.0 gee-0.8 pluie-echo-0.2',
    variables   : 'datarootdir='+join_paths('${prefix}', get_option('datadir'))+'\ndatadir='+join_paths('${datarootdir}', 'pluie'),
    version     : version,
    name        : 'libpluie-yaml',
    filebase    : 'pluie-yaml-' + version,
    subdirs     : 'pluie',
    description : 'The pluie yaml library'
)


