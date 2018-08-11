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

/**
 * a test class to implements yamlize
 */
public abstract class Pluie.Yaml.Object : GLib.Object
{
    /**
     *
     */
    private static GLib.Module? p_module;

    /**
     *
     */
    public virtual void yaml_init ()
    {
        Dbg.msg ("Yaml.Object (%s) instantiated".printf (this.type_from_self ()), Log.LINE, Log.FILE);
    }

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
     * retiew GLib.Type related to instance
     */
    public string type_from_self ()
    {
        return Type.from_instance (this).name ();
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
    public static Yaml.Object? from_node (Yaml.Node node)
    {
        Yaml.Object? obj = null;
        try {
            if (node.tag != null) {
                if (Yaml.Scanner.DEBUG) of.action ("tag value", node.tag.value);
                Type? type = type_from_tag (node.tag.value);
                if (type != null && type.is_object ()) {
                    if (Yaml.Scanner.DEBUG) of.echo ("object type founded : %s".printf (type.to_string ()));
                    obj = (Yaml.Object) GLib.Object.new (type);
                    if (node!= null && !node.empty ()) {
                        GLib.ParamSpec?  def = null;
                        Yaml.Node?    scalar = null;
                        foreach (var child in node) {
                            if ((def = obj.get_class ().find_property (child.name)) != null) {
                                if (child.ntype.is_single_pair ()) {
                                    if ((scalar = child.first ()) != null) {
                                        obj.set_from_scalar (def.name, def.value_type, scalar);
                                    }
                                }
                                else if (child.ntype.is_mapping ()) {
                                    obj.set (child.name, from_node(child));
                                }
                            }
                        }
                    }
                }
                else {
                    of.echo ("searched type : %s".printf (type.to_string ()));
                }
            }
        }
        catch (GLib.Error e) {
            of.warn (e.message);
        }
        obj.yaml_init ();
        return obj;
    }

    /**
     *
     */
    public void set_from_scalar (string name, GLib.Type type, Yaml.Node node)
    {
        GLib.Value v = GLib.Value(type);
        var data     = node.data; 
        if (Yaml.Scanner.DEBUG) {
            of.action("Auto setting property value %s".printf (of.c (ECHO.MICROTIME).s (type.name ())), name);
            of.echo (data);
        }
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
        this.set_property(name, v);
    }
}
