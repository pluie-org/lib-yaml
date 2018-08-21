/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : pluie-yaml  <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.5
 *  @type      : library
 *  @date      : 2018
 *  @licence   : GPLv3.0     <http://www.gnu.org/licenses/>
 *  @author    : a-Sansara   <[dev]at[pluie]dot[org]>
 *  @copyright : pluie.org   <http://www.pluie.org/>
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  This file is part of pluie-yaml.
 *  
 *  pluie-yaml is free software (free as in speech) : you can redistribute it
 *  and/or modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation, either version 3 of the License,
 *  or (at your option) any later version.
 *  
 *  pluie-yaml is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 *  more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with pluie-yaml.  If not, see <http://www.gnu.org/licenses/>.
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
    Pluie.Yaml.DEBUG = false;
    Yaml.Object? obj = null;
    var config = new Yaml.Config (path, true);
    var root   = config.root_node ();
    root.display_childs ();
    var list = new Gee.HashMap<string, Yaml.Object> ();
    if ((done = root != null)) {
        foreach (var node in root) {
            of.action ("Yaml.Object from node", node.name);
            of.echo (node.to_string (false));
            if ((obj = Yaml.Builder.from_node (node)) != null) {
                list[node.name] = obj;
            }
            else {
                of.error ("cannot set Yaml.Object from node : %s".printf (node.name), true);
            }
            node = node.next_sibling ();
        }
    }
    // hard code
    Yaml.Example? o = null;
    foreach (var entry in list.entries) {
        if ((o =  (Yaml.Example) entry.value)!=null) {
            of.action ("Getting Hard coded values for Yaml.Object %s".printf (of.c (ECHO.MICROTIME).s (o.get_type().name ())), entry.key);
            of.keyval("yaml_name"    , "%s" .printf(o.yaml_name));
            of.keyval("type_int"     , "%d" .printf(o.type_int));
            of.keyval("type_bool"    , "%s" .printf(o.type_bool.to_string ()));
            of.keyval("type_char"    , "%c" .printf(o.type_char));
            of.keyval("type_string"  , "%s" .printf(o.type_string));
            of.keyval("type_uchar"   , "%u" .printf(o.type_uchar));
            of.keyval("type_uint"    , "%u" .printf(o.type_uint));
            of.keyval("type_float"   , "%f" .printf(o.type_float));
            of.keyval("type_double"  , "%f" .printf(o.type_double));
            of.keyval("type_struct"  , "%s" .printf(o.type_struct.to_string ()));
            of.keyval("type_object"  , "%s" .printf(o.type_object.get_type ().name ()));
            of.keyval("    toto"     , "%s (string)" .printf(o.type_object.toto));
            of.keyval("    tapa"     , "%s (string)" .printf(o.type_object.tata));
            of.keyval("    titi"     , "%d (int)"    .printf(o.type_object.titi));
            of.keyval("    tutu"     , "%s (bool)"   .printf(o.type_object.tutu.to_string ()));
            o.type_object.method_a ();
            if (o.type_gee_al != null) {
                of.keyval("type_gee_al", "(%s)" .printf(o.type_gee_al.get_type ().name ()));
                foreach (double v in o.type_gee_al) {
                    of.echo("       - item : %f".printf (v));
                }
            }
        }
    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
