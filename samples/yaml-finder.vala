/*^* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software    :    pluie-yaml       <https://git.pluie.org/pluie/lib-yaml>
 *  @version     :    0.60
 *  @type        :    library
 *  @date        :    2018
 *  @license     :    GPLv3.0          <http://www.gnu.org/licenses/>
 *  @author      :    a-Sansara        <[dev]at[pluie]dot[org]>
 *  @copyright   :    pluie.org        <http://www.pluie.org>
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
 *  along with pluie-yaml.  If not, see  <http://www.gnu.org/licenses/>.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *^*/

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

    var path     = Yaml.DATA_PATH + "/test.yml";
    var done     = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");
//~     Pluie.Yaml.DEBUG = false;
    var loader = new Yaml.Loader (path, true);
    if ((done = loader.done)) {
        Yaml.Node root = loader.get_nodes ();
        var finder = new Yaml.Finder(root);
        Yaml.Node? node = null;

        var spath = "bill-to.family";
        of.action ("Find node", spath);
        if ((node = finder.find(spath)) != null) {
            of.echo (node.to_string (false));
            of.action ("get scalar value", spath);
            of.echo (node.first ().data);

            of.action ("get parent node");
            of.echo (node.parent.to_string ());
            
            of.action ("get address node");
            if ((node = (node.parent as Yaml.Mapping).item ("address"))!= null) {
                of.echo (node.to_string (false));
                node.display_childs ();
                
                of.action ("Loop throught childs", node.name);
                foreach (var child in node.list) {
                    of.echo (child.to_string (false));
                }
            }
            of.state (node != null);
        }
        else of.state (node != null);

        of.action ("Set find mode", "SQUARE_BRACKETS");
        Yaml.MODE = Yaml.FIND_MODE.SQUARE_BRACKETS;
        of.state (true);

        spath = "[product]{0}[description]";
        // equivalent in DOT MODE
        // spath = "product{0}.description";
        of.action ("Find node", spath);
        if ((node = finder.find(spath)) != null) {
            of.echo (node.to_string (false));
        }
        of.state (node != null);
        
        spath = "[product]{0}[description]{0}";
        // equivalent in DOT MODE
        // spath = "product{0}.description[0}";
        of.action ("Find scalar node", spath);
        if ((node = finder.find(spath)) != null) {
            of.echo (node.to_string (false));
        }
        of.state (node != null);

        spath = "[product]{1}";
        of.action ("Find node", spath);
        if ((node = finder.find(spath)) != null) {
            of.echo (node.to_string (false));
            of.state (node != null);
            
            spath = "[description]{0}";
            of.action ("Find subnode in node context", spath);
            of.keyval ("context", node.name);
            if ((node = finder.find(spath, node)) != null) {
                of.echo (node.to_string (false));
            }
            of.state (node != null);
        }
        else of.state (node != null);

    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
