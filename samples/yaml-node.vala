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

    var done     = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");

    var gp = new Yaml.Mapping (null, "grandfather");
    of.action ("new mapping", gp.name);
    of.echo (gp.to_string ());
    var f = new Yaml.Mapping (gp, "father");
    of.action ("new mapping", f.name);
    of.echo (f.to_string ());

    var c1 = new Yaml.Mapping.with_scalar (f, "son1", "saraxce");
    of.action ("new mapping", c1.name);
    of.echo (c1.to_string ());
    var d1 = new Yaml.Scalar(null, "mes data");
    of.action ("new mapping", "scalar");
    of.echo (d1.to_string ());
    var d2 = new Yaml.Mapping(c1, "sonar");
    of.action ("new mapping", d2.name);
    of.echo (d2.to_string ());
    of.action ("adding scalar to ", c1.name);
    c1.add (d1);
    of.action ("count from", c1.name);
    of.echo ("%d ".printf (c1.count ()));
    of.action ("count from", gp.name);
    of.echo ("%d ".printf (gp.count ()));
    
    var c2 = new Yaml.Mapping (f, "son2");
    of.action ("new mapping", c2.name);
    of.echo (c2.to_string ());
    var d3 = new Yaml.Mapping.with_scalar (c2, "little-son1", "with data");
    of.action ("new mapping with scalar", d2.name);
    of.echo (d3.to_string ());
    var d4 = new Yaml.Mapping.with_scalar (c2, "little-son2", "with data too");
    of.action ("new mapping with scalar", d4.name);
    of.echo (d4.to_string ());
    var c3 = new Yaml.Mapping (f, "son3");
    of.action ("new mapping", c3.name);
    of.echo (c3.to_string ());
    var c4 = new Yaml.Mapping (f, "son4");
    of.action ("new mapping", c4.name);
    of.echo (c4.to_string ());

    of.action ("first from", f.name);
    var child = f.first( );
    if (child != null) {
        of.echo (child.to_string ());
        
        of.echo ("is first ? %d".printf ((int)child.is_first ()));
        of.echo ("is last ? %d".printf ((int)child.is_last ()));

        while ((child = child.next_sibling ()) != null) {
            of.action ("next sibling", child.name);
            of.echo (child.to_string ());
            of.echo ("is last ? %d".printf ((int)child.is_last ()));
        }
    }

    of.action ("clone node ", f.name);
    Yaml.Mapping f2 = f.clone_node("father2") as Yaml.Mapping;  
    of.echo (f2.to_string ());

    of.action ("iterator from", f2.name);   
    Iterator<Yaml.Node> it = f2.iterator ();
    Yaml.Node? n = null;
    for (var has_next = it.next (); has_next; has_next = it.next ()) {
        n = it.get ();
        of.action ("node via iterator.next ()", n.name);
        of.echo (n.to_string ());
    }

    of.action ("first from cloned", f2.name);
    child = f2.first( );
    if (child != null) {
        of.echo (child.to_string ());
        
        of.echo ("is first ? %d".printf ((int)child.is_first ()));
        of.echo ("is last ? %d".printf ((int)child.is_last ()));

        while ((child = child.next_sibling ()) != null) {
            of.action ("next sibling", child.name);
            of.echo (child.to_string ());
            of.echo ("is last ? %d".printf ((int)child.is_last ()));
        }
    }

    of.action ("get child via names from cloned", f2.name);
    foreach (string g in f2.child_names ()) {
        of.echo (f2.item (g).to_string ());
    }

    gp.add (f2);
    gp.display_childs ();
    
    var dq = new Yaml.Node (null, Yaml.NODE_TYPE.ROOT, "PluieYamlRoot");
    dq.add (gp);
    of.echo (dq.to_string ());
    dq.display_childs ();

    of.rs (n.is_last ());
    of.echo ();
    return (int) done;

}
