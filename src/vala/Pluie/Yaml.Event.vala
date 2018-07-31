using GLib;
using Gee;
using Pluie;

/**
 * Yaml Event class
 */
public class Pluie.Yaml.Event
{
    /**
     * event type
     */
    public Yaml.EVT  evtype  { get; internal set; default = 0; }
    /**
     * indicates the current line number
     */
    public int line          { get; internal set; default = 0; }
    /**
     * indicates the current event style
     */
    public int? style        { get; internal set; default = null; }
    /**
     * event data
     */
    public Gee.HashMap<string, string>? data  { get; internal set; default = null; }

    /**
     * construct a Event
     * @param path the path to load
     */
    public Event (Yaml.EVT evtype, int line=0, int? style=null, Gee.HashMap<string, string>? data=null)
    {
        this.evtype = evtype;
        this.line   = line;
        this.style  = style;
        this.data   = data;
    }
}
