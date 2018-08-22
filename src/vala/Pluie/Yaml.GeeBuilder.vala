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

/**
 * a Yaml.Builder class helping to build vala Yaml.Object from Yaml.Node
 */
public class Pluie.Yaml.GeeBuilder
{

    /**
     *
     */
    public static void arraylist_from_node (ref Yaml.Object obj, Yaml.Node node, Type type)
    {
        Gee.ArrayList* p;
        obj.get (node.name, out p);
        GLib.Type? elementType = null;
        if (p != null && (elementType = p->element_type) != null) {
            Yaml.dbg (" arraylist_from_node %s (%s<%s>)".printf (node.name, type.name (), elementType.name ()));
            if (!elementType.is_object () && elementType.is_fundamental ()) {
                switch (elementType)
                {
                    case Type.STRING :
                        var l = new Gee.ArrayList<string> ();
                        foreach (var child in node) {
                            l.add(child.data);
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.CHAR :
                        var l = new Gee.ArrayList<int8> ();
                        foreach (var child in node) {
                            l.add((int8)child.data.data[0]);
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.UCHAR :
                        var l = new Gee.ArrayList<uchar> ();
                        foreach (var child in node) {
                            l.add((uint8)child.data.data[0]);
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.BOOLEAN :
                        var l = new Gee.ArrayList<bool> ();
                        foreach (var child in node) {
                            l.add(child.data == "1" || child.data.down () == "true");
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.INT :
                        var l = new Gee.ArrayList<int> ();
                        foreach (var child in node) {
                            l.add(int.parse(child.data));
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.UINT :
                        var l = new Gee.ArrayList<uint> ();
                        foreach (var child in node) {
                            l.add((uint)long.parse(child.data));
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.LONG :
                    case Type.INT64 :
                        var l = new Gee.ArrayList<long> ();
                        foreach (var child in node) {
                            l.add((long)int64.parse(child.data));
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.ULONG :
                    case Type.UINT64 :
                        var l = new Gee.ArrayList<ulong> ();
                        foreach (var child in node) {
                            l.add((ulong)uint64.parse(child.data));
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.FLOAT :
                        var l = new Gee.ArrayList<float?> ();
                        foreach (var child in node) {
                            l.add((float)double.parse(child.data));
                        }
                        obj.set (node.name, l);
                        break;
                    case Type.DOUBLE :
                        
//~                         .add(double.parse(child.data));
//~                         var l = new Gee.ArrayList<double?> ();
                        foreach (var child in node) {
                            obj.sig_set_data (node.name, type, child);
//~                             l.add(double.parse(child.data));
                        }
//~                         obj.set (node.name, l);
                        break;
                }
            }
            else if (elementType.is_object ()) {
//~                 var pg = p;
//~                 foreach (var child in node) {
//~                     pg.add(Yaml.Builder.from_node (child, elementType));
//~                 }
            }
        }
        else {
            of.warn ("can't retriew Generic Type. did you forget to instanciate the list in yaml_construct () method ?");
        }
    }

    /**
     *
     */
    public static Yaml.Node? arraylist_to_node (Gee.ArrayList* o, string property_name, Yaml.Node parent, bool is_char = false)
    {
        Yaml.dbg_action ("prop %s (type %s) has element type :".printf (property_name, o->get_type ().name ()), o->element_type.name ());
        var type = o->element_type;
        var node = new Yaml.Sequence (parent, property_name);
        var it = o->iterator();
        while (it.next ()) {
            if (!type.is_object () && type.is_fundamental ()) {
                string data = "";
                if (is_char && (type == typeof (unichar) || type == typeof (uchar))) {
                    void* d = (void*) it.get ();   
                    data = ((unichar) d).to_string();
                }
                else {
                    switch (type) {
                        case Type.LONG :
                        case Type.INT64 :
                            int64* d = (int64*) it.get ();
                            data = d.to_string ();
                            break;
                        case Type.INT   :
                            data = ((int64) it.get ()).to_string ();
                            break;
                        case Type.CHAR :
                            data = ((char) it.get ()).to_string ();
                            break;
                        case Type.UCHAR :
                            data = "%u".printf (((uint) it.get ()));
                            break;
                        case Type.ULONG :
                        case Type.UINT64 :
                            uint64* d = (uint64*) it.get ();
                            data = d.to_string ();
                            break;
                        case Type.UINT :
                            data = "%u".printf ((uint) it.get ());
                            break;
                        case Type.BOOLEAN :
                            data = ((bool) it.get ()).to_string ();
                            break;
                        case Type.FLOAT :
                            float* f = (float*) it.get ();
                            data = f.to_string ();
                            break;
                        case Type.DOUBLE :
                            double* d = (double*) it.get ();
                            data = d.to_string ();
                            break;
                        default :
                            data = (string) it.get ();
                            break;
                    }
                }
                var f = new Yaml.Scalar (node, data);
            }
            else if (type.is_object ()) {

            }
        }
        return node;
    }
}
