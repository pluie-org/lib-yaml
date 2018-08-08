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

    var path     = Yaml.DATA_PATH + "/config/db.yml";
    var done     = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");
    Pluie.Yaml.Scanner.DEBUG = false;
    var config = new Yaml.Config (path, true);
    Yaml.Node root   = (Yaml.Node) config.root_node ();
    Gee.HashMap<string, Db.Profile> db = new Gee.HashMap<string, Db.Profile> ();
    if ((done = root != null)) {
        foreach (var node in root) {
            of.action ("Yamlize DB profile", node.name);
            db[node.name] = new Db.Profile ();
            if (db[node.name].yamlize (node)) {
                foreach (var p in db[node.name].get_class().list_properties ()) {
                    var g = (node as Yaml.Mapping).item (p.name);
                    if (g.tag == null) {
                        var v = null;
                        db[node.name].get(p.name, &v);
                        of.keyval (p.name, v != null ? v : "null");
                    }
                    else {
//~                         of.echo ("tag is %s".printf (g.tag));
                        if (g.tag == "int") {
                            int z = -1;
                            db[node.name].get(p.name, ref z);
                            of.keyval (p.name, z.to_string ());
                        }
                    }
                }
            }
            node = node.next_sibling ();
        }
    }

    of.echo ("param [%s] port as int %d".printf ("bo", db["bo"].port));
    of.echo ("param [%s] port as int %d".printf ("therapy", db["therapy"].port));


    of.rs (done);
    of.echo ();
    return (int) done;

}
