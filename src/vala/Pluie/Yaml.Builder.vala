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
public class Pluie.Yaml.Builder
{
    /**
     *
     */
    private static GLib.Module? p_module;

    /**
     *
     */
    private static unowned GLib.Module p_open_module ()
    {
        if (p_module == null) {
            p_module = GLib.Module.open (null, 0);
        }
        return p_module;
    }

    /**
     *
     */
    public static GLib.Type? type_from_string (string name)
    {
        GLib.Type? type = Type.from_name (name.replace(".", ""));
        return type;
    }

    /**
     * retriew GLib.Type related to specified vala name
     * @param name a valid vala identifier name
     */
    public static Type type_from_vala (string name)
    {
        void * s;
        p_open_module ();
        if (!p_module.symbol (resolve_c_name(@"$(name).get_type"), out s)) {
            of.error ("cannot resolve type %s (not found)".printf (name));
        }
        return ((dlgType) s)();
    }

    /**
     * retiew GLib.Type related to specified tag value.
     * Type may not be registered yet
     */
    public static Type? type_from_tag (string tagValue)
    {
        var type = type_from_string (tagValue);
        if(type != null && type == Type.INVALID) {
            type = type_from_vala (tagValue);
        }
        return type;
    }

    /**
     * retriew corresponding c name related to specified vala name
     * @param name a valid vala identifier name
     */
    public static string resolve_c_name (string name)
    {
        string?      str = null;
        MatchInfo?    mi = null;
        StringBuilder sb = new StringBuilder ();
        bool begin       = true;
        try {
            var reg = new Regex ("([^.]*).?");
            for (reg.match (name, 0, out mi) ; mi.matches () ; mi.next ()) {
                if ((str = mi.fetch (1)) != null && str.length > 0) {
                    if (!begin) sb.append_unichar ('_');
                    else begin = false;
                    sb.append_unichar (str[0].tolower ());
                    sb.append (str.substring(1));
                }
            }
        }
        catch (GLib.RegexError e) {
            of.error (e.message, true);
        }
        return !begin ? sb.str : name;
    }

    [CCode (has_target = false)]
    private delegate Type dlgType();

    /**
     *
     */
    public static Yaml.Object? from_node (Yaml.Node node, Type otype = GLib.Type.INVALID)
    {
        Yaml.Object? obj = null;
        try {
            Type type = node.tag != null ? type_from_tag (node.tag.value) : otype;
            if (type != Type.INVALID) {
                Yaml.dbg_action ("vala type founded", "%s (%s)".printf (type.name (), type.to_string ()));
                if (type.is_object ()) {
                    obj = (Yaml.Object) GLib.Object.new (type);
                    obj.set ("yaml_name", node.name);
                    if (node!= null && !node.empty ()) {
                        GLib.ParamSpec?  def = null;
                        Yaml.Node?    scalar = null;
                        foreach (var child in node) {
                            if ((def = obj.get_class ().find_property (child.name)) != null) {
                                Yaml.dbg ("== prop [%s] type is : %s".printf (child.name, def.value_type.name ()));
                                if (child.ntype.is_single_pair () && (scalar = child.first ()) != null) {
                                    set_from_scalar (ref obj, def.name, def.value_type, scalar.data);
                                }
                                else if (child.ntype.is_collection ()) {
                                    set_from_collection (ref obj, type, child, def.value_type);
                                }
                            }
                            else {
                                of.warn ("property %s not found".printf (child.name));
                            }
                        }
                    }
                }
            }
            if (obj == null) {
                of.warn ("searched type not found : %s".printf (type.name ()));
            }
            else {
                obj.yaml_init ();
            }
        }
        catch (GLib.Error e) {
            of.warn (e.message);
        }
        return obj;
    }

    /**
     *
     */
    public static void set_from_collection (ref Yaml.Object obj, GLib.Type parentType, Yaml.Node node, GLib.Type type)
    {
        if (type.is_a (typeof (Yaml.Object))) {
            obj.set (node.name, Yaml.Builder.from_node(node, type));
        }
        else if (Yaml.Object.register.is_registered_type(parentType, type)) {
            Yaml.dbg ("%s is a registered type".printf (type.name ()));
            obj.populate_from_node (type, node);
        }
        else {
            Dbg.error ("%s is not registered and cannot be populated".printf (type.name ()), Log.METHOD, Log.LINE);
        }
    }

    /**
     *
     */
    public static void set_from_scalar (ref Yaml.Object obj, string name, GLib.Type type, string data)
    {
        GLib.Value v = GLib.Value(type);
        Yaml.dbg_action ("Auto setting property value %s".printf (of.c (ECHO.MICROTIME).s (type.name ())), name);
        Yaml.dbg (data);
        if (type.is_a(Type.ENUM))
            set_enum_value (ref v, type, data);
        else
            set_basic_type_value(ref v, type, data);
        obj.set_property(name, v);
    }

    /**
     *
     */
    public static void set_basic_type_value (ref Value v, GLib.Type type, string data)
    {
        switch (type)
        {
            case Type.STRING :
                v.set_string(data);
                break;
            case Type.CHAR :
                v.set_schar((int8)data.data[0]);
                break;
            case Type.UCHAR :
                v.set_uchar((uint8)data.data[0]);
                break;
            case Type.BOOLEAN :
                v.set_boolean (data == "1" || data.down () == "true");
                break;
            case Type.INT :
                v.set_int(int.parse(data));
                break;
            case Type.UINT :
                v.set_uint((uint)long.parse(data));
                break;
            case Type.LONG :
            case Type.INT64 :
                v.set_long((long)int64.parse(data));
                break;
            case Type.ULONG :
            case Type.UINT64 :
                v.set_ulong((ulong)uint64.parse(data));
                break;
            case Type.FLOAT :
                v.set_float((float)double.parse(data));
                break;
            case Type.DOUBLE :
                v.set_double(double.parse(data));
                break;
        }
    }

    /**
     *
     */
    public static string? get_basic_type_value (GLib.Object obj, GLib.Type type, string name)
    {
        GLib.Value v = GLib.Value(Type.STRING);
        switch (type)
        {
            case Type.STRING :
                string s; 
                obj.get (name, out s);
                v = s;
                break;
            case Type.CHAR :
                char c; 
                obj.get (name, out c);
                v = c.to_string ();
                break;
            case Type.UCHAR :
                uchar c; 
                obj.get (name, out c);
                break;
            case Type.UINT64 :
            case Type.UINT :
                uint64 i;
                obj.get (name, out i);
                break;
            case Type.INT64 :
            case Type.INT :
                int64 i;
                obj.get (name, out i);
                v = i.to_string ();
                break;
            case Type.BOOLEAN :
                bool b;
                obj.get (name, out b);
                v = b.to_string ();
                break;
            case Type.DOUBLE :
                double d;
                obj.get (name, out d);
                v = "%f".printf (d);
                break;
            case Type.FLOAT :
                float f;
                obj.get (name, out f);
                v = "%f".printf (f);
                break;
        }
        return (string) v;
    }

    /**
     *
     */
    public static void set_enum_value (ref Value v, GLib.Type type, string data)
    {
        EnumClass kenum = (EnumClass) type.class_ref();
        unowned EnumValue? enumval = kenum.get_value_by_name(data);
        if (enumval == null) {
            enumval = kenum.get_value_by_nick(data.down());
            int64 e = 0;
            if(enumval == null) {
                if(!int64.try_parse(data, out e)) {
                    Dbg.error ("invalid enum value %s".printf(data), Log.METHOD, Log.LINE);
                }
                else enumval = kenum.get_value((int)e);
            }
        }
        v.set_enum(enumval.value);
//~         of.echo ("enumValue : %d".printf (enumval.value));
    }

    public static string transform_param_name (string name)
    {
        return name.replace("-", "_");
    }

    /**
     *
     */
    public static Yaml.Node to_node (Yaml.Object obj, Yaml.Node? parent = null, bool root = true)
    { 
        var node     = new Yaml.Mapping (parent, obj.yaml_name);
        string? name = null;
        foreach (var def in obj.get_class ().list_properties ()){
            name = Yaml.Builder.transform_param_name(def.name);
            if (name != null && name != "yaml_name") {
                if (def.value_type.is_a (typeof (Gee.ArrayList))) {
                    void *p;
                    obj.get(name, out p);
                    Yaml.Builder.gee_arraylist_to_node(p, name, node);
                }
                else if (def.value_type.is_a (typeof (Yaml.Object)) || Yaml.Object.register.is_registered_type(obj.get_type (), def.value_type)) {
                    var child = obj.populate_to_node(def.value_type, name);
                    if (child != null) {
                        child.tag = new Yaml.Tag (Yaml.Object.register.resolve_namespace_type(def.value_type), "v");
                        node.add (child);
                    }
                }
                else if (def.value_type.is_enum ()) {
                    EnumValue enumval;
                    obj.get (name, out enumval);
                    string data = enumval.value.to_string ();
                    var n = new Yaml.Mapping.with_scalar (node, name, (string) data);
                    n.tag = new Yaml.Tag (Yaml.Object.register.resolve_namespace_type(def.value_type), "v");

                }
                else if (def.value_type.is_fundamental ()) {
                    string data = Yaml.Builder.get_basic_type_value(obj, def.value_type, name);
                    if (data != null) {
                        new Yaml.Mapping.with_scalar (node, name, (string) data);
                    }
                }
                else {
                    of.error ("type %s for property %s is not registered".printf (def.value_type.name (), name));
                }
            }
        }
        node.tag = new Yaml.Tag (Yaml.Object.register.resolve_namespace_type(obj.get_type ()), "v");
        if (root) {
            var rootNode = new Yaml.Root();
            rootNode.add (node);
            rootNode.tag_directives["!v!"] = "tag:pluie.org,2018:vala/";
            return rootNode;
        }
        else return node;
    }

    /**
     *
     */
    public static Yaml.Node? gee_arraylist_to_node (Gee.ArrayList* o, string property_name, Yaml.Node parent, bool is_char = false)
    {
        Yaml.dbg_action ("prop %s (type %s) has element type :".printf (property_name, o->get_type ().name ()), o->element_type.name ());
        var type = o->element_type;
        var node = new Yaml.Sequence (parent, property_name);
        var it = o->iterator();
        while (it.next ()) {
            if (!o->element_type.is_object () && o->element_type.is_fundamental ()) {
                string data = "";
                if (is_char && (o->element_type == typeof (unichar) || o->element_type == typeof (uchar))) {
                    void* d = (void*) it.get ();   
                    data = ((unichar) d).to_string();
                }
                else {
                    switch (o->element_type) {
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
            else if (o->element_type.is_object ()) {

            }
        }
        return node;
    }
}
