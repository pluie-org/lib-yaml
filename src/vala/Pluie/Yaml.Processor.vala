/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  @software  : lib-yaml    <https://git.pluie.org/pluie/lib-yaml>
 *  @version   : 0.3
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
using Pluie;

/**
 * a class dealing with a sequence of yaml events and composing the Yaml Node Graph
 */
public class Pluie.Yaml.Processor
{
    /**
     * indicates if processing is sucess
     */
    public bool                       done;

    /**
     * Events list
     */
    public Gee.ArrayList<Yaml.Event>  events           { get; internal set; }

    /**
     * Anchor map
     */
    Gee.HashMap<string, Yaml.Node>    anchors          { get; internal set; }

    /**
     * Error event
     */
    public Yaml.Event?                error_event      { get; internal set; }

    /**
     * the root Yaml.Node
     */
    public Yaml.Node                  root;

    /**
     * current previous Yaml.Node
     */
    Yaml.Node?                        prev_node;

    /**
     * current parent Yaml.Node
     */
    Yaml.Node?                        parent_node;

    /**
     * current Yaml.Node
     */
    Yaml.Node                         node;

    /**
     * previous level
     */
    int                               prev_level;

    /**
     *
     */
    public Processor ()
    {
        this.events  = new Gee.ArrayList<Yaml.Event>();
        this.anchors = new Gee.HashMap<string, Yaml.Node>();
    }

    /**
     * display the list of events generated via yaml.c
     */
    public void read ()
    {
        of.action ("Reading events");
        foreach (Yaml.Event event in this.events) {
            int len = 24 - event.evtype.infos ().length;
            stdout.printf ("    [ %s"+@" %$(len)s "+", %d, %s", event.evtype.infos (), " ", event.line, event.style != null ? event.style.to_string () : "0");
            if (event.data != null && event.data.size > 0) {
                stdout.printf (", {");
                var it = event.data.map_iterator ();
                string sep;
                for (var has_next = it.next (); has_next; has_next = it.next ()) {
                    sep = it.has_next () ? ", " : "";
                    stdout.printf ("%s: %s%s", it.get_key (), it.get_value (), sep);
                }
                stdout.printf (" }");
            }
            of.echo ("]");
        }
    }

    /**
     * retriew the next Yaml Event
     * @param the iterator
     */
    private Yaml.Event? next_event (Iterator<Yaml.Event> it)
    {
        Yaml.Event? evt = null;
        if (it.has_next () && it.next ()) {
            evt = it.get ();
        }
        return evt;
    }

    /**
     * retriew the next Yaml Value Event closest to Key Event
     * @param the iterator
     */
    private Yaml.Event? get_value_key_event (Iterator<Yaml.Event> it)
    {
        Yaml.Event? evt = null;
        var e = it.get ();
        if (e != null && e.evtype.is_key ()) {
            evt = this.next_event (it);
        }
        return evt;
    }

    /**
     * retriew the next Yaml Value Event
     * @param the iterator
     */
    private Yaml.Event? get_value_event (Iterator<Yaml.Event> it)
    {
        Yaml.Event? evt = null;
        var e = it.get ();
        if (e != null && e.evtype.is_value ()) {
            evt = this.next_event (it);
        }
        return evt;
    }

    /**
     * processing the events list and generate the corresponding Yaml Nodes
     */
    public bool run ()
    {
        if (Pluie.Yaml.Scanner.DEBUG) this.read ();
        this.root         = new Yaml.NodeRoot ();
        this.prev_node    = this.root; 
        this.parent_node  = this.root;
        this.prev_level   = this.root.level;
        int level         = this.root.level + 1;
        var it            = this.events.iterator ();
        var change        = false;
        string? key       = null;
        string? id        = null;
        bool beginFlowSeq = false;
        Yaml.Event? evt;
        if (Pluie.Yaml.Scanner.DEBUG) of.action ("Processing events");
        for (var has_next = it.next (); has_next; has_next = it.next ()) {
            evt = it.get ();
            if (evt.evtype.is_error ()) {
                error_event = evt;
                break;
            }
            if (evt.evtype.is_mapping_end () || evt.evtype.is_sequence_end ()) {
                level           -= 4;
                this.parent_node = this.prev_node.parent != null && this.prev_node.parent != this.root 
                    ? this.prev_node.parent.parent 
                    : this.root;
                this.prev_node   = this.parent_node;
                continue;
            }
            if (evt.evtype.is_entry ()) {
                evt = this.next_event(it);
                if (evt.evtype.is_mapping_start ()) {
                    key       = "_%d".printf((this.parent_node as Yaml.NodeSequence).get_size());
                    this.node = new Yaml.NodeMap (this.parent_node, key);
                    key       = null;
                    level    += 1;
                    change    = true;
                }
                else if (evt.evtype.is_scalar ()) {
                    var content = evt.data["data"];
                    this.node   = new Yaml.NodeScalar (this.parent_node, content);
                    change      = true;
                }
            }
            if (beginFlowSeq && evt.evtype.is_scalar ()) {
                var content  = evt.data["data"];
                this.node    = new Yaml.NodeScalar (this.parent_node, content);
                change       = true;
                beginFlowSeq = false;
            }
            if (evt.evtype.is_key () && (evt = this.get_value_key_event (it)) != null) {
                key = evt.data["data"];
            }
            if (evt.evtype.is_value () && (evt = this.get_value_event (it)) != null) {
                if (evt.evtype.is_scalar ()) {
                    var content = evt.data["data"];
                    if (key != null) {
                        this.node = new Yaml.NodeSinglePair (this.parent_node, key, content);
                        change    = true;
                    }
                }
                else if (evt.evtype.is_anchor ()) {
                    id  = evt.data["id"];
                    evt = this.next_event (it);
                }
                else if (evt.evtype.is_alias ()) {
                    id = evt.data["id"];
                    Yaml.Node? refnode = this.anchors.get(id);
                    if (refnode != null) {
                        this.node = refnode.clone_node (key);
                        this.parent_node.add (this.node);
                        this.prev_node  = this.node;
                        this.prev_level = this.prev_node.level;
                    }
                }
                if (evt.evtype.is_mapping_start ()) {
                    this.node = new Yaml.NodeMap (this.parent_node, key);
                    level    += 1;
                    change    = true;
                }
                else if (evt.evtype.is_sequence_start ()) {
                    this.node    = new Yaml.NodeSequence (this.parent_node, key);
                    level       += 1;
                    change       = true;
                    beginFlowSeq = true;
                }
                if (id != null) {
                    if (this.node != null) {
                        this.anchors.set(id, this.node);
                    }
                    id = null;
                }
                key = null;
            }
            if (change) {
                this.parent_node.add (this.node);
                if (this.node.node_type.is_collection ()) {
                    this.parent_node = this.node;
                }
                this.prev_node   = this.node;
                this.prev_level  = this.prev_node.level;
                this.node        = null;
                change = false;
            }
        }
        this.done = error_event == null && this.root != null;
        return done;
    }

}
