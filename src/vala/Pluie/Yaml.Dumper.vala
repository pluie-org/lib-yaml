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
 * interface representing a collection node
 */
public class Pluie.Yaml.Dumper
{
    /**
     *
     */
    public static int  DEFAULT_INDENT { get; internal set; default = 4; }
    /**
     *
     */
    public static bool SHOW_DOC       { get; internal set; default = true; }
    /**
     *
     */
    public static bool SHOW_TAGS      { get; internal set; default = true; }
    /**
     *
     */
    public static bool SHOW_FULL_KEYS { get; internal set; default = false; }
    /**
     *
     */
    public static bool SHOW_COLORS    { get; internal set; default = false; }
    /**
     *
     */
    public static bool SHOW_LINE      { get; internal set; default = false; }
    /**
     *
     */
    static int         line           { get; internal set; default = 0; }

    /**
     *
     */
    internal Dumper ()
    {
    }

    /**
     * get a gracefull yaml presentation of current Yaml.Node
     */
    public static void show_yaml_string (
        Yaml.Node? node, 
        bool show_line     = true, 
        bool show_color    = true, 
        bool show_tags     = Yaml.Dumper.SHOW_TAGS,
        bool show_doc      = Yaml.Dumper.SHOW_DOC,
        int indent         = Yaml.Dumper.DEFAULT_INDENT,
        bool show_fullkeys = Yaml.Dumper.SHOW_FULL_KEYS
    )
    {
        bool prev1  = SHOW_LINE;
        bool prev2  = SHOW_COLORS;
        bool prev3  = SHOW_TAGS;
        SHOW_LINE   = show_line;
        SHOW_COLORS = show_color;
        SHOW_TAGS   = show_tags;
        string yaml = dump (node, indent, show_doc, show_tags, show_fullkeys, show_color);
        SHOW_LINE   = prev1;
        SHOW_COLORS = prev2;
        SHOW_TAGS   = prev3;
        of.action ("Yaml string representation for", node!= null ? node.name : "null");
        print ("%s%s%s", "\n", yaml, "\n");
    }

    /**
     * get a yaml presentation of current Yaml.Node
     */
    public static string dump (
        Yaml.Node? node, 
        int indent         = Yaml.Dumper.DEFAULT_INDENT,
        bool show_doc      = Yaml.Dumper.SHOW_DOC,
        bool show_tags     = Yaml.Dumper.SHOW_TAGS,
        bool show_fullkeys = Yaml.Dumper.SHOW_FULL_KEYS,
        bool show_colors   = Yaml.Dumper.SHOW_COLORS
    )
    {
        var yaml = new StringBuilder("");
        if (node != null) {
            if (node.ntype.is_root ()) {
                line = 0;
                yaml_root (ref yaml, node as Yaml.Root, show_doc);
                foreach (var child in node) {
                    yaml.append (Yaml.Dumper.dump (child, indent, show_doc, show_tags, show_fullkeys, show_colors));
                }
            }
            else if (node.ntype.is_single_pair ()) {
                yaml_key (ref yaml, node, indent, show_tags);
                yaml_scalar (ref yaml, node.first (), indent, show_tags);
            }
            else if (node.ntype.is_collection ()) {
                yaml_key (ref yaml, node, indent, show_tags);
                foreach (var child in node) {
                    yaml.append (Yaml.Dumper.dump (child, indent, show_doc, show_tags, show_fullkeys, show_colors));
                }
            }
            else if (node.ntype.is_scalar ()) {
                yaml_scalar (ref yaml, node, indent, show_tags);
            }
        }
        line++;
        return yaml.str;
    }

    /**
     *
     */
    private static void yaml_indent (ref StringBuilder yaml, Yaml.Node node, int indent, bool wrapchild = false)
    {
        yaml.append("%s%s".printf (
            ! SHOW_LINE ? "" : of.c (ECHO.NUM).s ("%03d %s".printf (line, of.c (ECHO.FILE).s ("|"))),
            string.nfill ((node.level-1) * indent - (wrapchild ? 2 : 0), ' ')
        ));
    }

    /**
     *
     */
    private static void yaml_tag (ref StringBuilder yaml, Yaml.Node node, bool show_tags)
    {
        if (node.tag != null && show_tags) {
            if (SHOW_COLORS) yaml.append (of.c (ECHO.COMMAND).to_string ());
            yaml.append ("!%s!%s".printf (
                node.tag.handle, 
                node.tag.value
            ));
            yaml.append ("%s ".printf (SHOW_COLORS ? Color.off () : ""));
        }
    }

    /**
     *
     */
    private static void yaml_root (ref StringBuilder yaml, Yaml.Root node, bool show_doc)
    {
        yaml.append(! SHOW_LINE ? "" : of.c (ECHO.NUM).s ("%03d %s".printf (line++, of.c (ECHO.FILE).s ("|"))));
        yaml.append("%YAML %s\n".printf (Yaml.YAML_VERSION));
        foreach (var entry in node.tag_directives.entries) {
            yaml.append(! SHOW_LINE ? "" : of.c (ECHO.NUM).s ("%03d %s".printf (line, of.c (ECHO.FILE).s ("|"))));
            yaml.append ("%TAG %s %s\n".printf (entry.key, entry.value));
        }
        if (show_doc) {
            yaml.append(! SHOW_LINE ? "" : of.c (ECHO.NUM).s ("%03d %s".printf (line, of.c (ECHO.FILE).s ("|"))));
            yaml.append ("---\n");
        }
    }

    /**
     *
     */
    private static void yaml_key (ref StringBuilder yaml, Yaml.Node node, int indent, bool show_tags)
    {
        bool wrapseq   = node.parent.ntype.is_sequence () && node.ntype.is_mapping () && node.name[0]=='_';
        bool childwrap = node.parent != null && node.parent.parent != null && node.parent.parent.ntype.is_sequence () && node.parent.ntype.is_mapping () && node.parent.name[0]=='_';
        if (!childwrap) yaml_indent (ref yaml, node, indent);
        else if (!node.is_first ()) {
            yaml_indent (ref yaml, node, indent, true);
        }
        if (node.parent != null && node.parent.ntype.is_sequence ()) yaml.append (!SHOW_COLORS ? "- " : of.c (ECHO.DATE).s ("- "));
        if (wrapseq) {
            if (Yaml.DEBUG) of.warn ("node %s wrapseq ? %s".printf (node.name, wrapseq.to_string ()));
        }
        yaml_tag (ref yaml, node, show_tags);
        if (!wrapseq) {
            int len = 0;
            foreach (var child in node.parent) {
                if (child.name.length > len) len = child.name.length; 
            }
            len = (!show_tags || (node.tag == null && !node.ntype.is_collection ()) &&  len > 0) ? len +1 - node.name.length : 0;
            yaml.append("%s%s%s".printf(
                !SHOW_COLORS ? @"%s%$(len)s ".printf (node.name, " ") : of.c (node.ntype.is_collection() ? ECHO.TIME : ECHO.OPTION).s(@"%s%$(len)s".printf (node.name, " ")), 
                !SHOW_COLORS ? ":"       : of.c (ECHO.DATE).s(":"),
                node.ntype.is_collection () ? "\n" : " "
            ));
        }
    }

    /**
     *
     */
    private static void yaml_scalar (ref StringBuilder yaml, Yaml.Node node, int indent, bool show_tags)
    {
        if (!(node.parent !=null && node.parent.ntype.is_single_pair ())) yaml_indent (ref yaml, node, indent);
        if (node.parent != null && node.parent.ntype.is_sequence ()) yaml.append (!SHOW_COLORS ? "- " : of.c (ECHO.DATE).s ("- "));
        yaml_tag (ref yaml, node, show_tags);
        yaml.append ("%s\n".printf (
            !SHOW_COLORS ? node.data : of.c (ECHO.OPTION_SEP).s (node.data)
        ));
    }
}
