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
     * previous indent
     */
    int                               prev_indent;

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
        EVT? prevEvent   = null;
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
            of.echo ("]\n");
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
        this.root        = new Yaml.NodeRoot ();
        this.prev_node   = this.root; 
        this.parent_node = this.root;
        this.prev_indent = this.root.indent;
        int indent       = this.root.indent +4;
        EVT? prevEvent   = null;
        var it           = this.events.iterator ();
        var change       = false;
        string? key      = null;
        string? id       = null;
        Yaml.Event? evt;
        if (Pluie.Yaml.Scanner.DEBUG) of.action ("Processing events");
        for (var has_next = it.next (); has_next; has_next = it.next ()) {
            evt = it.get ();
            if (evt.evtype.is_error ()) {
                error_event = evt;
                break;
            }
            if (evt.evtype.is_mapping_end () || evt.evtype.is_sequence_end ()) {
                indent          -= 4;
                this.parent_node = this.prev_node.parent != this.root ? this.prev_node.parent.parent : this.root;
                this.prev_node   = this.parent_node;
                continue;
            }
            if (evt.evtype.is_entry ()) {
                evt = this.next_event(it);
                if (evt.evtype.is_mapping_start ()) {
                    key       = "_%d".printf((this.parent_node as Yaml.NodeSequence).get_size());
                    this.node = new Yaml.NodeMap (this.parent_node, indent, key);
                    key       = null;
                    indent   += 4;
                    change    = true;
                }
            }
            if (evt.evtype.is_key () && (evt = this.get_value_key_event (it)) != null) {
                key = evt.data["data"];
            }
            if (evt.evtype.is_value () && (evt = this.get_value_event (it)) != null) {
                if (evt.evtype.is_scalar ()) {
                    var content = evt.data["data"];
                    if (key != null) {
                        this.node = new Yaml.NodeSinglePair (this.parent_node, indent, key, content);
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
                        this.prev_node   = this.node;
                        this.prev_indent = this.prev_node.indent;
                    }
                }
                if (evt.evtype.is_mapping_start ()) {
                    this.node = new Yaml.NodeMap (this.parent_node, indent, key);
                    indent   += 4;
                    change    = true;
                }
                else if (evt.evtype.is_sequence_start ()) {
                    this.node = new Yaml.NodeSequence (this.parent_node, indent, key);
                    indent   += 4;
                    change    = true;
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
                this.prev_indent = this.prev_node.indent;
                this.node        = null;
                change = false;
            }
        }
        this.done = error_event == null && this.root != null;
        return done;
    }

}
