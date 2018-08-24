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
 * abstract class representing a node
 */
public abstract class Pluie.Yaml.AbstractNode : GLib.Object
{
    /**
     * universal unique identifier
     */
    public string                           uuid       { get; internal set; }

    /**
     * current node name (key)
     */
    public string?                          name       { get; internal set; default = null; }

    /**
     * current node data for Yaml.NodeScalar node
     */
    public string?                          data       { get; internal set; default = null; }

    /**
     * node type related to Yaml.NODE_TYPE
     */
    public Yaml.NODE_TYPE                   ntype      { get; internal set; default = NODE_TYPE.UNDEFINED; }

    /**
     * default Yaml.Node constructor
     * @param type the NODE_TYPE of Yaml.Node to create
     * @param name the node name
     */
    public AbstractNode (Yaml.NODE_TYPE type = Yaml.NODE_TYPE.UNDEFINED, string? name = null)
    {
        this.with_name(type, name);
    }

    /**
     * @param type the NODE_TYPE of Yaml.Node to create
     * @param name the node name
     * @param data the node data
     */
    public AbstractNode.with_name (Yaml.NODE_TYPE type = Yaml.NODE_TYPE.UNDEFINED, string? name = null, string? data = null)
    {
        this.ntype  = type;
        this.name   = name;
        this.data   = data;
        this.uuid   = Yaml.uuid ();
    }

    /**
     * test if specifiyed node is current node
     * @param node the Yaml.Node node to test
     */
    public virtual bool same_node (Yaml.AbstractNode? node)
    {
        return node != null && node.uuid == this.uuid;
    }

    public virtual string to_string (
        bool withIndent   = Yaml.DBG_SHOW_INDENT, 
        bool withParent   = Yaml.DBG_SHOW_PARENT, 
        bool withUuid     = Yaml.DBG_SHOW_UUID, 
        bool withLevel    = Yaml.DBG_SHOW_LEVEL, 
        bool withCount    = Yaml.DBG_SHOW_COUNT, 
        bool withRefCount = Yaml.DBG_SHOW_REF, 
        bool withTag      = Yaml.DBG_SHOW_TAG, 
        bool withType     = Yaml.DBG_SHOW_TYPE
    )
    {
        return "";
    }
 
    /**
     * get a yaml presentation of current Yaml.Node
     */
    public string to_yaml_string (
        int indent         = Yaml.Dumper.DEFAULT_INDENT, 
        bool show_doc      = Yaml.Dumper.SHOW_DOC, 
        bool show_tags     = Yaml.Dumper.SHOW_TAGS,
        bool show_fullkeys = Yaml.Dumper.SHOW_FULL_KEYS
    )
    {
        return Yaml.Dumper.dump (
            (Yaml.Node) this, 
            indent, 
            show_doc, 
            show_tags, 
            show_fullkeys
        );
    }
}
