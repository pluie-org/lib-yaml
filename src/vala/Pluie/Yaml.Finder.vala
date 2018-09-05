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
 * Finder class used to easily retriew Yaml.Node
 * 
 * Path definition has two mode :
 * default mode is ''Yaml.FIND_MODE.DOT''
 * 
 *  * child mapping node are separated by dot :
 *  *  sequence entry must be enclosed in curly brace
 *  ex : ``grandfather.father.son{2}.age``
 * 
 * other mode is ''Yaml.FIND_MODE.SQUARE_BRACKETS''.
 * 
 *  * node's key name must be enclosed in square brackets
 *  * sequence entry must be enclosed in curly brace
 *  ex : ``[grandfather][father][son]{2}[age]``
 */
public class Pluie.Yaml.Finder : GLib.Object
{

    /**
     * Context node
     */
    public Yaml.Node? context     { get; internal set; }

    /**
     * default Yaml.Finder constructor
     * @param context default Yaml.Node context
     */
    public Finder (Yaml.Node context)
    {
        this.context = context;
    }

    /**
     * Find a specific child Yaml.Node corresponding to path definition.
     *
     * @param path the definition to retriew the child node
     * @param context the Yaml.Node context to operate
     */
    public Yaml.Node? find (string path, Yaml.Node? context = null)
    {
        string search         = this.find_path (path);
        bool match            = false;
        Yaml.Node? node = context == null ? this.context : context;
        Regex reg             = /(\[|\{)([^\]\}]*)(\]|\})/;
        MatchInfo mi;
        try {
            //of.echo ("find node %s".printf (path));
            // of.echo ("search %s".printf (search));
            for (reg.match (search, 0, out mi) ; mi.matches () ; mi.next ()) {
                // of.echo ("=> %s%s%s".printf (mi.fetch (1), mi.fetch (2), mi.fetch (3)));
                if (this.is_collection_path (mi)) {
                    if (!match) match = true;
                    if (this.is_collection_path (mi, true)) {
                        var n = node as Yaml.Mapping;
                        if (n !=null && !n.empty ()) {
                            node = n.item (mi.fetch (FIND_COLLECTION.KEY));
                        }
                    }
                    else {
                        int index = int.parse (mi.fetch (FIND_COLLECTION.KEY));
                        if (index == 0 && !node.empty() && node.first().ntype.is_scalar ()) {
                            node  = node.first ();
                        }
                        // assume sequence
                        else {
                            var n     = node as Yaml.Sequence;
                            if (n != null && !n.empty () && index >= 0 && index < n.count ()) {
                                node = n.list.get (index);
                            }
                            else node = null;
                        }
                    }
                    if (node == null) break;
                }
            }
        }
        catch (RegexError e) {
            of.error (e.message);
        }
        if (!match) node = null;
        return node;
    }

    /**
     * get a path definition depending of current Node.mode
     * if path definition is Yaml.FIND_MODE.DOT the path is convert to a 
     * Yaml.FIND_MODE.SQUARE_BRACKETS path definition
     * @param path the path definition
     * @return the find path definition according to current Node.mode
     */
    private string find_path (string path)
    {
        MatchInfo? mi = null;
        string search = "";
        if (Yaml.MODE.is_dot ()) {
            var stk = /([^.]*)\./.split (path);
            foreach (var s in stk) {
                if (s.strip() != "") {
                    if (/([^\{]+)(\{[0-9]+\})/.match (s, 0, out mi)) {
                        search = search + "[%s]%s".printf (mi.fetch (1), mi.fetch (2));
                    }
                    else {
                        search = search + "[%s]".printf (s);
                    }
                }
            }
        }
        else {
            search = path;
        } 
        return search;
    }

    /**
     * indicates if specifiyed MatchInfo is related to a mapping node only or a collection node
     * @param mi used MathInfo
     * @param mappingOnly  flag indicates if mappu only
     */
    private bool is_collection_path (MatchInfo mi, bool mappingOnly = false)
    {
        return (mi.fetch (FIND_COLLECTION.OPEN) == "[" && mi.fetch (FIND_COLLECTION.CLOSE) == "]") || (!mappingOnly &&
               (mi.fetch (FIND_COLLECTION.OPEN) == "{" && mi.fetch (FIND_COLLECTION.CLOSE) == "}"));
    }

}
