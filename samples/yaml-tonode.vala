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

public void inspect_type (GLib.Type type, ...) 
{
    var l = va_list();
    while (true) {
        var obj = l.arg<GLib.Object> ();
        if (obj == null) {
            break;  // end of the list
        }
        print ("%s\n", type.name ());
        print ("%s\n", type.name ());
        print (" is-obj: %s\n", type.is_object ().to_string ());
        print (" is-abstr: %s\n", type.is_abstract ().to_string ());
        print (" is-classed: %s\n", type.is_classed ().to_string ());
        print (" is-derivable: %s\n", type.is_derivable ().to_string ());
        print (" is-derived: %s\n", type.is_derived ().to_string ());
        print (" is-fund: %s\n", type.is_fundamental ().to_string ());
        print (" is-inst: %s\n", type.is_instantiatable ().to_string ());
        print (" is-iface: %s\n", type.is_interface ().to_string ());
        print (" is-enum: %s\n", type.is_enum ().to_string ());
        print (" is-flags: %s\n", type.is_object ().to_string ());

        // Output:
        //  `` Children:``
        print (" Children:\n");
        foreach (unowned Type ch in type.children ()) {
            print ("  - %s\n", ch.name ());
        }

        //  `` Interfaces:``
        //  ``  - Interface``
        print (" Interfaces:\n");
        foreach (unowned Type ch in type.interfaces ()) {
            if ( ch == typeof(Gee.Traversable)) {
                var t = (obj as Gee.Traversable).element_type;
                print ("  --- !!! element type is  %s\n", (obj as Gee.Traversable).element_type.name ());
                print (" is-obj: %s\n", t.is_object ().to_string ());
                print (" is-abstr: %s\n", t.is_abstract ().to_string ());
                print (" is-classed: %s\n", t.is_classed ().to_string ());
                print (" is-derivable: %s\n", t.is_derivable ().to_string ());
                print (" is-derived: %s\n", t.is_derived ().to_string ());
                print (" is-fund: %s\n", t.is_fundamental ().to_string ());
                print (" is-inst: %s\n", t.is_instantiatable ().to_string ());
                print (" is-iface: %s\n", t.is_interface ().to_string ());
                print (" is-enum: %s\n", t.is_enum ().to_string ());
                print (" is-flags: %s\n", t.is_object ().to_string ());
                if ((obj as Gee.Traversable).element_type == typeof (Gee.Map.Entry)) {
                    print ("  --- !!! key type is  %s\n", (obj as Gee.Map).key_type.name ());
                    print ("  --- !!! value type is  %s\n", (obj as Gee.Map).value_type.name ());
                }
            }
            print ("  - %s\n", ch.name ());
        }

        // Output:
        //  `` Parents:``
        //  ``  - GObject``
        print (" Parents:\n");
        for (Type p = type.parent (); p != 0 ; p = p.parent ()) {
            print ("  - %s\n", p.name ());
        }
    }
}

int main (string[] args)
{
    Echo.init(false);

    var path     = Yaml.DATA_PATH + "/tag.yml";
    var done     = false;

    of.title ("Pluie Yaml Library", Pluie.Yaml.VERSION, "a-sansara");
    Pluie.Yaml.DEBUG = false;
    var config = new Yaml.Config (path, true);
    var root   = config.root_node ();
    root.display_childs ();
    root.first ().display_childs ();

    of.action ("Yaml.Builder.from_node", root.first ().name);
    Samples.YamlObject obj = (Samples.YamlObject) Yaml.Builder.from_node (root.first ());
    obj.type_object.method_a ();
    if (obj.type_gee_al != null) {
        of.keyval("type_gee_al", "(%s)" .printf(obj.type_gee_al.get_type ().name ()));
        foreach (double v in obj.type_gee_al as Gee.ArrayList<double?>) {
            of.echo("       - item : %f".printf (v));
        }
    }

    var n = Yaml.Builder.to_node (obj);
    if ((done = n !=null)) { 
        n.display_childs ();
    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
