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
 * a class dealing with a sequence of yaml events and composing the Yaml Node Graph
 */
public class Pluie.Yaml.Processor
{
    /**
     * indicates if processing is sucess
     */
    public bool                       done;

    /**
     * indicates if new node has been created
     */
    bool                              change;

    /**
     * indicates if document start begin
     */
    bool                              begin;

    /**
     * indicates if new node is a sequence entry
     */
    bool                              isEntry;

    /**
     * indicates if new node is a sequence entry mapping
     */
    bool                              isEntryMapping;

    /**
     * indicates if begon a flow sequence
     */
    bool                              beginFlowSeq;

    /**
     *
     */
    int                               indexEvt;

    /**
     * current anchor id
     */
    string?                           idAnchor;

    /**
     * current key
     */
    string?                           ckey;

    /**
     * current key tag
     */
    Yaml.Tag?                         keyTag;

    /**
     * current key tag
     */
    Yaml.Tag?                         valueTag;

    /**
     * current tag handle
     */
    string?                           tagHandle;

    /**
     * current tag handle
     */
    Yaml.Event?                        nextValueEvt;

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
    Yaml.Event?                       event            { get; internal set; }

    /**
     * Error event
     */
    public Yaml.Event?                error_event      { get; internal set; }

    /**
     * the root Yaml.Node
     */
    public Yaml.Root                  root;

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
     * Yaml.Event Iterator
     */
    Gee.Iterator<Yaml.Event>          iterator;

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
        var i = 0;
        foreach (Yaml.Event event in this.events) {
            int len = 24 - event.evtype.infos ().length;
            stdout.printf ("  %03d  [ %s"+@" %$(len)s "+", %d, %s", i++, event.evtype.infos (), " ", event.line, event.style != null ? event.style.to_string () : "0");
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
     * processing the events list and generate the corresponding Yaml Nodes
     */
    public bool run ()
    {
        if (Yaml.DEBUG) this.read ();
        Yaml.dbg_action ("Processing events");
        this.reset ();
        for (var has_next = this.iterator.next (); has_next; has_next = this.iterator.next ()) {
            this.event = this.iterator.get ();
            Yaml.dbg ("    [[[ EVENT %d %s ]]]".printf (this.indexEvt++, this.event.evtype.infos ()));
            if (this.event.evtype.is_tag_directive ()) {
                this.on_tag_directive ();
            }
            if (this.event.evtype.is_error ()) {
                this.on_error ();
                break;
            }
            if (!this.begin) {
                if (this.event.evtype.is_sequence_start () || this.event.evtype.is_mapping_start ()) {
                    this.begin = true;
                    continue;
                }
                else if (this.event.evtype.is_document_start ()) {
                    this.begin = true;
                    // to do
                    this.event = this.next_event ();
                    if (this.event.evtype.is_tag ()) {
                        this.root.tag = new Yaml.Tag (this.event.data["suffix"], this.event.data["handle"].replace("!", ""));
                        this.event = this.next_event ();
                    }
                    continue;
                }
            }
            else {
                if (this.event.evtype.is_anchor ()) {
                    this.on_anchor ();
                }
                else if (this.event.evtype.is_alias ()) {
                    this.on_alias ();
                }
                else if (this.event.evtype.is_mapping_end () || this.event.evtype.is_sequence_end ()) {
                    this.on_block_end ();
                    continue;
                }
                else if (this.event.evtype.is_key () && (this.event = this.get_value_key_event ()) != null) {
                    this.on_key ();
                }
                else  if (this.event.evtype.is_entry ()) {
                    this.on_entry ();
                }
                else if (this.event.evtype.is_mapping_start ()) {
                    this.create_mapping (this.isEntry);
                }
                else if (this.event.evtype.is_sequence_start ()) {
                    this.on_sequence_start ();
                }
                else if (this.event.evtype.is_value ()) {
                    continue;
                }
                else if (this.event.evtype.is_scalar ()) {
                    this.on_scalar ();
                }
                this.add_anchor_if_needed ();
                this.on_update ();
            }
        }
        this.done = error_event == null && this.root != null;
        return done;
    }

    /**
     *
     */
    private void reset ()
    {
        this.root          = new Yaml.Root ();
        this.prev_node     = this.root;
        this.parent_node   = this.root;
        this.iterator      = this.events.iterator ();
        this.change        = false;
        this.ckey          = null;
        this.idAnchor      = null;
        this.tagHandle     = null;
        this.keyTag        = null;
        this.valueTag      = null;
        this.beginFlowSeq  = false;
        this.nextValueEvt  = null;
        this.indexEvt      = 0;
        this.isEntry       = false;
        this.begin         = false;
        this.isEntryMapping = false;
    }

    /**
     * retriew the next Yaml Event
     */
    private Yaml.Event? next_event ()
    {
        Yaml.Event? evt = null;
        if (this.iterator.has_next () && this.iterator.next ()) {
            evt = this.iterator.get ();
            Yaml.dbg ("    >>>>> [EVENT event [%d] %s <<<<< %s".printf (this.indexEvt++, evt.evtype.infos (), Log.METHOD));
        }
        return evt;
    }

    /**
     * retriew the next Yaml Event without use of iterator
     */
    private Yaml.Event? get_next_event ()
    {
        Yaml.Event? evt = null;
        var i = this.indexEvt;
        if (i < this.events.size) {
            evt = this.events.get (i);
        }
        return evt;
    }

    /**
     * retriew the next Yaml Value Event closest to Key Event
     */
    private Yaml.Event? get_value_key_event ()
    {
        Yaml.Event? evt = null;
        var e = this.iterator.get ();
        if (e != null && e.evtype.is_key ()) {
            evt = this.next_event ();
        }
        return evt;
    }

    /**
     * retriew the next Yaml Value Event
     */
    private Yaml.Event? get_value_event ()
    {
        Yaml.Event? evt = null;
        var e = this.iterator.get ();
        if (e != null && e.evtype.is_value ()) {
            evt = this.next_event ();
            this.nextValueEvt = evt;
        }
        return evt;
    }

    /**
     * retriew the next Yaml Value Event without use of iterator
     */
    private Yaml.Event? get_next_value_event ()
    {
        Yaml.Event? evt = null;
        var i      = this.indexEvt;
        Yaml.dbg (" >>> %s from %d".printf (Log.METHOD, i));
        var search = true;
        while (search) {
            if (i < this.events.size) {
                var e = this.events.get (i++);
                if (e != null && e.evtype.is_value ()) {
                    evt = this.events.get (i);
                    Yaml.dbg (" >>> %s > %d : %s".printf (Log.METHOD, i, evt.evtype.infos ()));
                    break;
                }
            }
            else search = false;
        }

        return evt;
    }

    /**
     *
     */
    private void on_tag_directive ()
    {
        Yaml.dbg_action ("on_tag_directive %s".printf (this.event.data["handle"]), this.event.data["prefix"]);
        this.root.tag_directives[this.event.data["handle"]] = this.event.data["prefix"];
    }

    /**
     *
     */
    private void on_error ()
    {
        this.error_event = this.event;
    }

    /**
     *
     */
    private bool is_entry_nested_block (Yaml.Node node)
    {
        return node.ntype.is_sequence () && !node.empty() && node.first ().ntype.is_collection ();
    }

    /**
     *
     */
    private void on_block_end ()
    {
        if (this.prev_node.ntype.is_scalar () || (this.prev_node.ntype.is_single_pair () && this.prev_node.parent != null && this.prev_node.parent.ntype.is_mapping ())) {
            this.prev_node = this.prev_node.parent;
        }
        this.parent_node = this.prev_node.parent != null && this.prev_node.parent != this.root 
            ? this.prev_node.parent
            : this.root;
        this.prev_node = this.parent_node;
    }

    /**
     *
     */
    private void on_entry ()
    {
        this.isEntry = true;
        this.ckey = null;
        var e = this.get_next_event ();
        if (e!= null && e.evtype.is_mapping_start ()) {
            this.isEntryMapping = true;
            this.create_mapping (true);
            this.next_event ();
        }
    }


    /**
     *
     */
    private void on_tag (bool onKey = false)
    {
        if (this.event.evtype.is_tag ()) {
            Yaml.dbg_keyval ("tag %s".printf (this.event.data["handle"]), this.event.data["suffix"]);
            if (this.root.tag_directives.has_key (this.event.data["handle"])) {
                var tag = new Yaml.Tag (this.event.data["suffix"], this.event.data["handle"].replace("!", ""));
                if (onKey) 
                    this.keyTag = tag;
                else
                    this.valueTag = tag;
                this.event = this.next_event ();
            }
            else {
                of.warn ("tag handle %s not found in directive".printf (this.event.data["handle"]));
            }
        }
    }

    /**
     *
     */
    private void on_key ()
    {
        this.on_tag (true);
        if (this.event.evtype.is_scalar ()) {
            this.ckey = this.event.data["data"];
            Yaml.dbg (" >> node name : %s".printf (this.ckey));
        }
    }

    /**
     *
     */
    private void on_scalar (bool entry = false)
    {
        if (this.ckey != null && this.parent_node.ntype.is_collection ()) {
            this.node = new Yaml.Mapping.with_scalar (this.parent_node, this.ckey, this.event.data["data"]);
        }
        else {
            this.node = new Yaml.Scalar (this.parent_node, this.event.data["data"]);
        }
        this.change = true;
    }

    /**
     *
     */
    private void on_anchor ()
    {
        if (this.event.data != null) {
            this.idAnchor = this.event.data["id"];
        }
    }

    /**
     *
     */
    private void on_alias ()
    {
        if (this.event.data != null) {
            this.idAnchor      = this.event.data["id"];
            Yaml.Node? refnode = this.anchors.get(this.idAnchor);
            if (refnode != null) {
                this.node = refnode.clone_node (this.ckey);
                this.parent_node.add (this.node);
                this.prev_node = this.node;
            }
        }
    }

    /**
     *
     */
    private void on_sequence_start ()
    {
        this.node         = new Yaml.Sequence (this.parent_node, this.ckey);
        this.change       = true;
    }

    /**
     *
     */
    private void on_mapping_start (bool entry = false)
    {
        this.ckey  = null;
        this.event = this.next_event ();
        if (this.event.evtype.is_key ()) {
            this.event = this.next_event ();
            this.on_tag (true);
            if (this.event.evtype.is_scalar ()) {
                this.ckey = this.event.data["data"];
            }
            var e = this.get_next_value_event();
            if (e!=null) {
                if ( e.evtype.is_sequence_start ()) {
                    this.on_sequence_start ();
                }
                else {
                    this.create_mapping (this.isEntry);
                }
            }
        }
    }

    /**
     *
     */
    private void create_mapping (bool entry = false)
    {
        if (entry && this.ckey == null) {
            this.ckey = "_%d".printf(this.parent_node.count());
        }
        this.node   = new Yaml.Mapping (this.parent_node, this.ckey);
        this.change = true;
    }

    /**
     *
     */
    private void add_anchor_if_needed ()
    {
        if (this.idAnchor != null && this.node != null) {
            this.anchors.set(this.idAnchor, this.node);
            this.idAnchor = null;
        }
    }

    /**
     *
     */
    private void on_update ()
    {
        if (this.node != null) {
            Yaml.dbg (Log.METHOD);
            Yaml.dbg (this.node.name);
            Yaml.dbg (this.node.ntype.infos ());
            Yaml.dbg ("anchor ? %s".printf (this.idAnchor));
        }
        if (this.change) {
            if (this.node.parent.ntype.is_sequence ()) {
                var seq = this.node.parent as Yaml.Sequence;
                if (seq != null) seq.close_block = false;
            }
            Yaml.dbg_action ("on change", this.node.name != null ? this.node.name : this.node.data);
            if (this.keyTag != null) {
                Yaml.dbg_action ("setting tag", this.keyTag.@value);
                this.node.tag       = this.keyTag;
            }
            else if (this.valueTag != null) {
                if (this.node.ntype.is_scalar ()) {
                    this.node.tag = this.valueTag;
                }
                else if (!this.node.empty () && this.node.first().ntype.is_scalar ()) {
                    this.node.first ().tag = this.valueTag;
                }
            }
            if (this.node.ntype.is_collection () && (this.node.empty() || (!this.node.first().ntype.is_scalar ()))) {
                this.parent_node = this.node;
            }
            else {
                this.parent_node = this.node.parent;
            }
            this.prev_node = this.node;
            this.tagHandle = null;
            this.keyTag    = null;
            this.valueTag  = null;
            this.node      = null;
            this.isEntryMapping = false;
            this.change    = false;
            this.isEntry   = false;
            this.ckey      = null;
        }
    }

}
