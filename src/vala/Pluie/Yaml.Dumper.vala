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
    internal Dumper ()
    {
    }

    /**
     * get a yaml presentation of current Yaml.Node
     */
    public static string dump (
        Yaml.Node node, 
        int indent         = Yaml.Dumper.DEFAULT_INDENT,
        bool show_doc      = Yaml.Dumper.SHOW_DOC,
        bool show_tags     = Yaml.Dumper.SHOW_TAGS,
        bool show_fullkeys = Yaml.Dumper.SHOW_FULL_KEYS
    )
    {
        var yaml = new StringBuilder("");
        if (node.ntype.is_root ()) {
            yaml_root (ref yaml, node as Yaml.Root, show_doc);
            foreach (var child in node) {
                yaml.append (Yaml.Dumper.dump (child, indent, show_doc, show_tags, show_fullkeys));
            }
        }
        else if (node.ntype.is_single_pair ()) {
            yaml_key (ref yaml, node, indent);
            yaml_scalar (ref yaml, node.first (), indent);
        }
        else if (node.ntype.is_collection ()) {
            yaml_key (ref yaml, node, indent);
            foreach (var child in node) {
                yaml.append (Yaml.Dumper.dump (child, indent, show_doc, show_tags, show_fullkeys));
            }
        }
        else if (node.ntype.is_scalar ()) {
            yaml_scalar (ref yaml, node, indent);
        }
        return yaml.str;
//~         return "%s%s%s%s%s%s%s%s%s%s%s".printf (
//~             this.level == 0 ? "" : of.s_indent ((int8) (withIndent ? (this.level-1)*4 : 0)),
//~             of.c (ECHO.OPTION).s ("["),
//~             this.name != null && !this.ntype.is_scalar ()
//~                 ?  of.c (ntype.is_root () ? ECHO.MICROTIME : ECHO.TIME).s ("%s".printf (this.name))
//~                 : (
//~                     this.ntype.is_scalar ()
//~                         ? of.c(ECHO.DATE).s ("%s".printf (this.data))
//~                         : ""
//~             ),
//~             withRefCount ? of.c (ECHO.COMMAND).s ("[%lu]".printf (this.ref_count)) : "",
//~             !withParent || this.parent == null
//~                 ? withLevel ? of.c (ECHO.NUM).s (" %d".printf (this.level)) : ""
//~                 : of.c (ECHO.SECTION).s (" "+this.parent.name)+(
//~                     withLevel ? of.c (ECHO.NUM).s (" %d".printf (this.level)) : " "
//~                 ),
//~             withType  ? of.c (ECHO.OPTION_SEP).s (" %s".printf(this.ntype.infos ())) : "",
//~             withCount && this.ntype.is_collection () ? of.c (ECHO.MICROTIME).s (" %d".printf(this.count ())) : "",
//~             withUuid  ? of.c (ECHO.COMMENT).s (" %s".printf(this.uuid[0:8]+"...")) : "",
//~             this.tag != null && withTag
//~                 ? " %s%s".printf (
//~                     of.c (ECHO.TITLE).s (" %s ".printf(this.tag.handle)), 
//~                     of.c (ECHO.DEFAULT).s (" %s".printf(this.tag.value))
//~                 )
//~                 : "",
//~             of.c (ECHO.OPTION).s ("]"),
//~             withTag && this.ntype.is_root () ? (this as Yaml.Root).get_display_tag_directives () : ""
//~         );
    }

    /**
     *
     */
    private static void yaml_indent (ref StringBuilder yaml, Yaml.Node node, int indent, bool wrapchild = false)
    {
        yaml.append("%s".printf (string.nfill ((node.level-1) * indent - (wrapchild ? 2 : 0), ' ')));
    }

    /**
     *
     */
    private static void yaml_tag (ref StringBuilder yaml, Yaml.Node node)
    {
        if (node.tag != null) yaml.append ("!%s!%s ".printf (node.tag.handle, node.tag.value));
    }

    /**
     *
     */
    private static void yaml_root (ref StringBuilder yaml, Yaml.Root node, bool show_doc)
    {
        yaml.append("%YAML %s\n".printf (Yaml.YAML_VERSION));
        foreach (var entry in node.tag_directives.entries) {
            yaml.append ("%TAG %s %s\n".printf (entry.key, entry.value));
        }
        if (show_doc) yaml.append ("---\n");
    }

    /**
     *
     */
    private static void yaml_key (ref StringBuilder yaml, Yaml.Node node, int indent)
    {
        bool wrapseq   = node.parent.ntype.is_sequence () && node.ntype.is_mapping () && node.name[0]=='_';
        bool childwrap = node.parent.parent.ntype.is_sequence () && node.parent.ntype.is_mapping () && node.parent.name[0]=='_';
        if (!childwrap) yaml_indent (ref yaml, node, indent);
        else if (!node.is_first ()) {
            yaml_indent (ref yaml, node, indent, true);
        }
        if (node.parent.ntype.is_sequence ()) yaml.append ("- ");
        if (wrapseq) {
            of.warn ("node %s wrapseq ? %s".printf (node.name, wrapseq.to_string ()));
        }
        yaml_tag (ref yaml, node);
        if (!wrapseq) {
            yaml.append("%s:%s".printf(node.name, node.ntype.is_collection () ? "\n" : " "));
        }
    }

    /**
     *
     */
    private static void yaml_scalar (ref StringBuilder yaml, Yaml.Node node, int indent)
    {
        if (!node.parent.ntype.is_single_pair ()) yaml_indent (ref yaml, node, indent);
        if (node.parent.ntype.is_sequence ()) yaml.append ("- ");
        yaml_tag (ref yaml, node);
        yaml.append ("%s\n".printf (node.data));
    }

}
