using GLib;
using Gee;
using Pluie;

int main (string[] args)
{
    Echo.init(false);

    var path     = "resources/test.yml";
    var done     = false;

    of.title ("Pluie Yaml Parser", Pluie.Yaml.VERSION, "a-sansara");
    Pluie.Yaml.Scanner.DEBUG = true;
    var loader = new Yaml.Loader (path, true, true);
    if ((done = loader.done)) {
        Yaml.NodeRoot root = loader.get_nodes ();
    }

    of.rs (done);
    of.echo ();
    return (int) done;

}
