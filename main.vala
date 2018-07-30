using GLib;
using Gee;
using Pluie;

int main (string[] args)
{
    Echo.init(true);

    var path     = "resources/test.yml";
    var done     = false;

    of.title ("Pluie Yaml Parser", Pluie.Yaml.VERSION, "a-sansara");

    of.action ("Reading file", path);
    of.echo ();
    var reader = new Io.Reader (path);
    while (reader.readable) {
        of.echo ("%s %s".printf (
            of.c (ECHO.DATE   ).s ("%03d |".printf (reader.line)), 
            of.c (ECHO.OPTION_SEP).s (reader.read ()))
        ); 
    }
    of.echo ("EOF");
    of.state (true);

    of.action ("Parsing file", path);
    var processor = new Yaml.Processor (path);
    done = processor.done;

    of.state (done);
    of.echo ();
    return (int) done;

}
