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

class Foo {
    public signal void sig (int x);
}

class Bar {
    private int data = 42;

    public void handler (int x) {
        stdout.printf ("%d Data via instance: %d\n", x, this.data);
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
    var root   = config.root_node () as Yaml.Root;
    root.first ().display_childs ();

    of.action ("with signal Yaml.Builder.from_node", root.first ().name);
    Yaml.Example obj = (Yaml.Example) Yaml.Builder.from_node (root.first ());
    obj.type_object.method_a ();
    if (obj.type_gee_al != null) {
        of.keyval("type_gee_al", "(%s<%s>)" .printf(obj.type_gee_al.get_type ().name (), obj.type_gee_al.element_type.name ()));
        foreach (var v in obj.type_gee_al) {
            of.echo("       - item : %g".printf (v));
        }
        of.keyval("type_object", "(%s)" .printf(obj.type_object.get_type ().name ()));
        of.keyval("    toto"     , "%s (string)" .printf(obj.type_object.toto));
        of.keyval("    tapa"     , "%s (string)" .printf(obj.type_object.tata));
        of.keyval("    titi"     , "%d (int)"    .printf(obj.type_object.titi));
        of.keyval("    tutu"     , "%s (bool)"   .printf(obj.type_object.tutu.to_string ()));
        obj.type_object.method_a ();

        of.keyval("type_gee_alobject", "(%s<%s>)" .printf(obj.type_gee_alobject.get_type ().name (), obj.type_gee_alobject.element_type.name ()));
        foreach (var child in obj.type_gee_alobject) {
            of.echo("        == entry (%s) ==".printf(child.get_type ().name ()));
            of.keyval("    toto"     , "%s (string)" .printf(child.toto));
            of.keyval("    tapa"     , "%s (string)" .printf(child.tata));
            of.keyval("    titi"     , "%d (int)"    .printf(child.titi));
            of.keyval("    tutu"     , "%s (bool)"   .printf(child.tutu.to_string ()));
            child.method_a ();
        }
    }

    of.action ("with signal Yaml.Builder.to_node", obj.yaml_name);
    var n = Yaml.Builder.to_node (obj);
    if ((done = n !=null)) { 
        n.display_childs ();
    }

    of.rs (done);
    of.echo ();

    var foo = new Foo ();

    int data = 52;
    foo.sig.connect ((x) => {        // 'user_data' in C code = variables from outer context
        stdout.printf ("%d Data via closure: %d\n", x, data);
    });

    var bar = new Bar ();
    foo.sig.connect (bar.handler);  // 'user_data' in C code = 'bar'

    // Emit signal
    foo.sig (73);

    return (int) done;

}
