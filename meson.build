# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
#  @version   : 0.4
#  @date      : 2018
#  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
#  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
#  @copyright : pluie.org   <http://www.pluie.org/>
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  This file is part of lib-yaml.
#  
#  lib-yaml is free software (free as in speech) : you can redistribute it
#  and/or modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation, either version 3 of the License,
#  or (at your option) any later version.
#  
#  lib-yaml is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with lib-yaml.  If not, see <http://www.gnu.org/licenses/>.
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
project('libpluie-yaml', 'vala', 'c', version:'0.4')

cc            = meson.get_compiler('c')
dep_glib      = dependency('glib-2.0')
dep_gobject   = dependency('gobject-2.0')
dep_gmodule   = dependency('gmodule-2.0')
dep_gio       = dependency('gio-2.0')
dep_gee       = dependency('gee-0.8')
dep_echo      = dependency('pluie-echo-0.2')
dep_m         = cc.find_library('m', required : false)
dep_yaml      = cc.find_library('yaml', required : true)

#~ add_global_link_arguments('-lyaml', language : 'c')

version       = '0.4'
bindir        = join_paths(get_option('prefix'), get_option('bindir'))
datadir       = join_paths(get_option('prefix'), get_option('datadir'), 'pluie/yaml')
libdir        = join_paths(get_option('prefix'), get_option('libdir'), 'pkgconfig')
incdir        = join_paths(get_option('prefix'), get_option('includedir'), 'pluie')

conf          = configuration_data()
conf.set('VERSION'     , version)
conf.set('INSTALL_PATH', bindir)
conf.set('DATA_PATH'   , datadir)

configure_file(
  input: 'install.vala.in',
  output: 'install.vala',
  configuration: conf
)

sources = [
    'build/install.vala',
    'src/vala/Pluie/Io.Reader.vala',
    'src/vala/Pluie/Io.StreamLineMark.vala',
    'src/vala/Pluie/Yaml.global.vala',
    'src/vala/Pluie/Yaml.AbstractChild.vala',
    'src/vala/Pluie/Yaml.AbstractNode.vala',
    'src/vala/Pluie/Yaml.Builder.vala',
    'src/vala/Pluie/Yaml.Collection.vala',
    'src/vala/Pluie/Yaml.Config.vala',
    'src/vala/Pluie/Yaml.Event.vala',
    'src/vala/Pluie/Yaml.Example.vala',
    'src/vala/Pluie/Yaml.ExampleChild.vala',
    'src/vala/Pluie/Yaml.ExampleStruct.vala',
    'src/vala/Pluie/Yaml.Finder.vala',
    'src/vala/Pluie/Yaml.Loader.vala',
    'src/vala/Pluie/Yaml.Mapping.vala',
    'src/vala/Pluie/Yaml.Node.vala',
    'src/vala/Pluie/Yaml.Object.vala',
    'src/vala/Pluie/Yaml.Processor.vala',
    'src/vala/Pluie/Yaml.Register.vala',
    'src/vala/Pluie/Yaml.Root.vala',
    'src/vala/Pluie/Yaml.Scalar.vala',
    'src/vala/Pluie/Yaml.Scanner.vala',
    'src/vala/Pluie/Yaml.Sequence.vala',
    'src/vala/Pluie/Yaml.Tag.vala',
    'src/c/yaml.c'
]

install_data('resources/main.yml', install_dir : datadir)
install_data('resources/tag.yml', install_dir : datadir)
install_data('resources/test.yml', install_dir : datadir)
install_data('resources/test.json', install_dir : datadir)
install_data('resources/config/db.yml', install_dir : join_paths(datadir, 'config'))
install_data('resources/config/subdir/test.yml', install_dir : join_paths(datadir, 'config/subdir'))

libpluie_yaml = library(
    'pluie-yaml-' + version, 
    sources,
    vala_header  : 'pluie_yaml.h',
    vala_vapi    : 'pluie-yaml-' +version+'.vapi',
    dependencies : [dep_glib, dep_gobject, dep_gmodule, dep_gio, dep_gee, dep_echo, dep_m, dep_yaml],
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


