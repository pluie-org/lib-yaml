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
            p_module = Module.open (null, 0);
        }
        return p_module;
    }

    /**
     * retriew GLib.Type related to specified vala name
     * type must be registered
     */
    public static GLib.Type? type_from_string (string name)
    {
        Type? type = Type.from_name (name.replace(".", ""));
        return type;
    }

    /**
     * retriew GLib.Type related to specified vala name
     * type may be not registered
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
     * retriew GLib.Type related to specified tag value.
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
     *
     */
    private static string resolve_c_subname (string name) throws GLib.RegexError
    {
        MatchInfo?  mi = null;
        bool    update = false;
        var        reg = new Regex ("([A-Z]{1}[a-z]+)");
        string?    str = null;
        var         sb = new StringBuilder();
        for (reg.match (name, 0, out mi) ; mi.matches () ; mi.next ()) {
            if ((str = mi.fetch (1)) != null && str.length > 0) {
                sb.append ("%s%s%s".printf (update ? "_" : "", str[0].tolower ().to_string (), str.substring(1)));
                if (!update) update = true;
            }
        }
        return update ? sb.str : name;
    }

    /**
     * retriew corresponding c name related to specified vala name
     * @param name a valid vala identifier name
     */
    public static string resolve_c_name (string name)
    {
        string?      str  = null;
        MatchInfo?    mi  = null;
        StringBuilder sb = new StringBuilder ();
        bool begin       = true;
        try {
            var reg = new Regex ("([^.]*).?");
            for (reg.match (name, 0, out mi) ; mi.matches () ; mi.next ()) {
                str = Yaml.Builder.resolve_c_subname(mi.fetch (1));
                if (str != null && str.length > 0) {
                    if (!begin) sb.append_unichar ('_');
                    else begin = false;
                    sb.append_unichar (str[0].tolower ());
                    sb.append (str.substring(1));
                }
            }
        }
        catch (RegexError e) {
            of.error (e.message, true);
        }
        return !begin ? sb.str : name;
    }

    [CCode (has_target = false)]
    private delegate Type dlgType();

    /**
     * Build an Object from a YYaml.Node
     * @param node the source Yaml.Node
     * @param otype used for recursion only
     */
    public static GLib.Object? from_node (Yaml.Node node, Type otype = GLib.Type.INVALID)
    {
        GLib.Object? obj  = null;
        Type type = node.tag != null ? type_from_tag (node.tag.value) : otype;
        if (type != Type.INVALID) {
            Yaml.dbg_action ("vala type founded", "%s (%s)".printf (type.name (), type.to_string ()));
            if (type.is_object ()) {
                obj = GLib.Object.new (type);
                if (type.is_a (typeof (Yaml.Object))) {
                    (obj as Yaml.Object).set ("yaml_name", node.name);
                    (obj as Yaml.Object).yaml_construct ();
                }
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
            if (type.is_a (typeof (Yaml.Object))) {
                (obj as Yaml.Object).yaml_init ();
            }
        }
        return obj;
    }

    /**
     *
     */
    private static void set_from_collection (ref GLib.Object obj, Type parentType, Yaml.Node node, Type type)
    {
        Yaml.dbg (" > set_from_collection %s (%s)".printf (node.name, type.name ()));
        if (type.is_a (typeof (Yaml.Object)) || Yaml.Register.is_registered_type (parentType, type)) {
            (obj as Yaml.Object).populate_from_node (node.name, type, node);
        }
        else {
            of.error ("%s is not registered and cannot be populated".printf (type.name ()));
        }
    }

    /**
     *
     */
    private static void set_from_scalar (ref GLib.Object obj, string name, GLib.Type type, string data)
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
                v = "%g".printf (d);
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
    private static void set_enum_value (ref Value v, GLib.Type type, string data)
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

    private static string transform_param_name (string name)
    {
        return name.replace("-", "_");
    }

    /**
     *
     */
    private static Yaml.Tag add_tag (GLib.Type type)
    {
        return new Yaml.Tag (Yaml.Register.resolve_namespace_type(type), Yaml.YAML_VALA_PREFIX);
    }

    /**
     * transform an Yaml.Object to  his corresponding Yaml.Node
     * @param obj the obj to transform
     * @param parent the parent node
     * @param root indicates if node must be add to a root node, if true a Yaml.Root node is return
     * @param index for sequence entry anonymous mapping block
     * @param property_name name of property name related to obj
     */
    public static Yaml.Node to_node (GLib.Object obj, Yaml.Node? parent = null, bool root = true, int? index = null, string? property_name = null)
    { 
        string node_name = "";
        if (obj.get_type ().is_a (typeof (Yaml.Object))) {
            node_name = (obj as Yaml.Object).yaml_name;
        }
        else {
            node_name = parent.ntype.is_sequence () && index != null  ? "_%d".printf (index+1) : (property_name != null ? property_name : obj.get_type ().name ());
        }
        var node     = new Yaml.Mapping (parent, node_name);
        string? name = null;
        foreach (var def in obj.get_class ().list_properties ()){
            name = Yaml.Builder.transform_param_name(def.name);
            if (name != null && name != "yaml_name") {
                if (def.value_type.is_a (typeof (Yaml.Object)) || Yaml.Register.is_registered_type(obj.get_type (), def.value_type)) {
                    var child = (obj as Yaml.Object).populate_to_node(name, def.value_type, node);
                    if (child != null) {
                        child.tag = Yaml.Builder.add_tag (def.value_type);
                        node.add (child);
                    }
                }
                else if (def.value_type.is_enum ()) {
                    EnumValue enumval;
                    obj.get (name, out enumval);
                    string data = enumval.value.to_string ();
                    var n = new Yaml.Mapping.with_scalar (node, name, (string) data);
                    n.tag = Yaml.Builder.add_tag (def.value_type);
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
        node.tag = Yaml.Builder.add_tag (obj.get_type ());
        return root ? new Yaml.Root(null, true, node) : node;
    }
}
