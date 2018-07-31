using GLib;
using Gee;
using Pluie;

/**
 * a Yaml Loader class
 */
public class Pluie.Yaml.Loader
{
    /**
     * Scanner 
     */
    Yaml.Scanner    scanner     { public get; internal set; }

    /**
     * indicate if file has been sucessfully loaded
     */
    public bool     done        { get; internal set; }

    /**
     * Reader used to load content yaml file
     */
    Io.Reader       reader;

    /**
     * @param path the path of file to parse
     * @param displayFile display original file
     * @param displayNode display corresponding Yaml Node Graph
     */
    public Loader (string path, bool displayFile = false, bool displayNode = false )
    {
        this.reader  = new Io.Reader (path);
        if (displayFile) {
            this.displayFile ();
        }
        this.scanner = new Yaml.Scanner (path);
        if ((this.done = this.scanner.run()) && displayNode) {
            this.get_nodes ().display_childs ();
            of.state(true);
        }
    }

    /**
     * return resulting Yaml root node
     */
    public Yaml.NodeRoot get_nodes ()
    {
        return this.scanner.get_nodes ();
    }

    /**
     * display original file
     */
    public void displayFile ()
    {
        of.action ("Reading file", this.reader.path);
        of.echo ();
        while (this.reader.readable) {
            of.echo ("%s %s".printf (
                of.c (ECHO.DATE   ).s ("%03d |".printf (this.reader.line)), 
                of.c (ECHO.OPTION_SEP).s (this.reader.read ()))
            ); 
        }
        of.echo ("EOF");
        of.state (true);
    }
}
