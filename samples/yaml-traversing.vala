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
    Pluie.Yaml.DEBUG = false;
    var config = new Yaml.Config (path, true);
    var node   = config.root_node ();
    if ((done = node != null)) {
        node.display_childs ();

        of.action("retriew child sequence node", "product");
        var child = config.get("product");
        of.echo (child.to_string (false));
        of.action("retriew sequence last child node", child.name);
        var nchild = child.last ();
        if (nchild != null) {
            of.echo (nchild.to_string ());
        }
        of.action("retriew sequence first child node", child.name);
        nchild = child.first ();
        if (nchild != null) {
            of.echo (nchild.to_string ());
            of.action("retriew sequence next sibling node", nchild.name);
            nchild = nchild.next_sibling ();
            if (nchild != null) {
                of.echo (nchild.to_string ());
                of.action("retriew sequence previous sibling node", nchild.name);
                nchild = nchild.previous_sibling ();
                if (nchild != null) {
                    of.echo (nchild.to_string ());
                }
            }
        }
        
        of.echo("\n   ================================ ");

        of.action("retriew mapping child node", "ship-to");
        child = config.get("ship-to");
        of.echo (child.to_string (false));
        of.action("retriew mapping last child node", child.name);
        nchild = child.last ();
        if (nchild != null) {
            of.echo (nchild.to_string ());
        }
        of.action("retriew mapping first child node", child.name);
        nchild = child.first ();
        if (nchild != null) {
            of.echo (nchild.to_string ());
        }
        of.action("loop throught mapping next sibling", child.name);
        while (child!=null && !child.is_last()) {
            child = child.next_sibling ();
            if (child != null) {
                of.echo (child.to_string (false));
            }
        }
        of.action("loop throught mapping previous sibling", child.name);
        while (!child.is_first()) {
            child = child.previous_sibling ();
            if (child != null) {
                of.echo (child.to_string (false));
            }
        }


        of.echo("\n   ================================ ");
        
        of.action ("current node is ", child.name);
        of.echo ("switch node : next_sibling ().next_sibling ().first_child ()");
        child = child.next_sibling ().next_sibling ().first ();

        of.action ("current node is ", child.name);
        of.echo ("use finder to retriew parent node");
        var n = config.get ("bill-to");
        if (n!= null) {
            of.echo (n.to_string (false));
            of.echo ("parent (mapping) contains child ? %d".printf ((int) n.contains (child)));
        }
        of.action ("current node is ", child.name);
        of.echo ("switch node : parent.next_sibling ().next_sibling ().first_child ().first_child ()");
        child = child.parent.next_sibling ().next_sibling ().first ().first ();
        of.action ("current node is ", child.name);
        of.echo ("use finder to retriew parent node");
        n = config.get ("product{0}");
        if (n!= null) {
            of.echo (n.to_string (false));
            of.echo ("parent (sequence) contains child ? %d".printf ((int) n.contains (child)));
        }

    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
