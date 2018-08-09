/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.4
 *  @date      : 2018
 *  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
 *  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
 *  @copyright : pluie.org   <http://www.pluie.org/>
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  This file is part of lib-yaml.
 *  
 *  lib-yaml is free software (free as in speech) : you can redistribute it
 *  and/or modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation, either version 3 of the License,
 *  or (at your option) any later version.
 *  
 *  lib-yaml is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with lib-yaml.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */

using GLib;
using Gee;
using Pluie;

int main (string[] args)
{
    Echo.init(false);

    var path     = Yaml.DATA_PATH + "/tag.yml";
    var done     = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");
    Pluie.Yaml.Scanner.DEBUG = true;
    var config = new Yaml.Config (path, true);
    Yaml.Node root   = (Yaml.Node) config.root_node ();
    root.display_childs ();
    Gee.HashMap<string, Yaml.Example> list = new Gee.HashMap<string, Yaml.Example> ();
    if ((done = root != null)) {
        foreach (var node in root) {
            of.action ("Yamlize Yaml.Example", node.name);
            of.echo (node.to_string ());
            if (node.tag != null && node.tag.@value == "Pluie.Yaml.Example") {
                list[node.name] = new Yaml.Example ();
                of.state (list[node.name].yamlize (node));
            }
            node = node.next_sibling ();
        }
    }

    foreach (var entry in list.entries) {
        of.action ("Getting values", entry.key);
        of.keyval("type_int" , "%d".printf(entry.value.type_int));
        of.keyval("type_bool", "%s".printf(entry.value.type_bool.to_string ()));
        of.keyval("type_char", "%c".printf(entry.value.type_char));
    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
