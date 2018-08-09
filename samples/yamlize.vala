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
    Pluie.Yaml.Scanner.DEBUG = false;
    var config = new Yaml.Config (path, true);
    var root   = config.root_node ();
    root.display_childs ();
    // define a map with base Yaml.Object
    Gee.HashMap<string, Yaml.Object> list = new Gee.HashMap<string, Yaml.Object> ();
    // require to register type;
    Yaml.Example? obj = new Pluie.Yaml.Example ();
    if ((done = root != null)) {
        foreach (var node in root) {
            of.action ("Yamlize Yaml.Example", node.name);
            of.echo (node.to_string ());
            if (node.tag != null) {
                of.action ("tag value", node.tag.value);
                var type  = Yaml.Object.type_from_name (node.tag.value);
                if (type != null && type.is_object ()) {
                    of.echo ("type founded : %s".printf (type.to_string ()));
                
//~                 of.echo ("======");
//~                 of.action ("Auto Instanciate object as Yaml.Object", type.name ());
//~                 var o = (Yaml.Object) GLib.Object.new (type);
//~                 if (o != null) {
//~                     of.action ("Yamlize Yaml.Object", type.name ());
//~                     of.state (o.yamlize (node));
//~                     of.action ("Hardcode casting as", type.name ());
//~                     var so = o as Yaml.Example;
//~                     of.action ("Hardcode Getting values object", type.name ());
//~                     of.keyval("type_int" , "%d".printf(so.type_int));
//~                     of.keyval("type_bool", "%s".printf(so.type_bool.to_string ()));
//~                     of.keyval("type_char", "%c".printf(so.type_char));
//~                     of.echo ("======");
//~                 }
                    list[node.name] = (Pluie.Yaml.Object) GLib.Object.new (type);
                    of.state (list[node.name].yamlize (node));
                }
                else {
                    of.warn ("type %s not found, you probably need to instanciate it first".printf (node.tag.value));
                }
            }
            node = node.next_sibling ();
        }
    }

    foreach (var entry in list.entries) {
        of.action ("Getting values", entry.key);
        if ((obj =  entry.value as Yaml.Example)!=null) {
            of.keyval("type_int" , "%d".printf(obj.type_int));
            of.keyval("type_bool", "%s".printf(obj.type_bool.to_string ()));
            of.keyval("type_char", "%c".printf(obj.type_char));
        }
    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
