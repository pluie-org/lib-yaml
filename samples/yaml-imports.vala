/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.3
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

    var pwd  = Environment.get_variable ("PWD");
//~     var path = Path.build_filename (pwd, "resources/main.yml");
    var path = "./resources/main.yml";
    var done = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");

    Pluie.Yaml.Scanner.DEBUG = false;
    var config = new Yaml.Config (path);
    var spath  = "^imports";
    var node   = config.get (spath);
    if ((done = node != null)) {
        of.action ("retriew node from Yaml.Config", spath);
        if ((node as Yaml.NodeMap).map.has_key ("^path")) {
            of.echo ((node as Yaml.NodeMap).map["^path"].to_string (false));
        }
        of.echo (node.to_string (false));
        spath = "therapy.dbname{0}";
        of.action ("retriew imported node from Yaml.Config", spath);
        var inode = config.get (spath);
        if ((done = node != null)) {
            of.echo (inode.to_string (false));
        }
    }
    var root = config.root_node ();
    root.display_childs ();
    of.rs (done);
    of.echo ();

    
    of.echo (pwd);


    return (int) done;

}
