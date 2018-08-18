# pluie-yaml

**pluie-yaml** is a vala shared library managing yaml files (v 1.2) and yaml nodes in vala language.  
As json is now a valid subset of yaml, you can use this lib to load json files too.  

The purpose of this project is to make vala able to load and deal with yaml configuration files.  
So, currently the lib deal only with one yaml document (it's not recommended to use multiples doc), 
but you can use a special `^imports` clause (special mapping node) to load a subset of yaml files 
in the main yaml document.

The lib partially manage tag directives and tag values (basic types and Yaml.Object extended objects types).

**pluie-yaml** use the ![libyaml c library](https://github.com/yaml/libyaml) (License MIT, many thanks to Kirill Simonov) to parse and retriew related yaml events.

![pluie-yaml](https://www.meta-tech.academy/img/pluie-yaml-imports2.png)

_legend display_childs_ :

```
[ node.name  [refCount]  node.parent.name  node.level  node.ntype.infos ()  node.count ()  node.uuid ]
```

## License

GNU GPL v3

## Prerequisites

`valac meson ninja libyaml glib gobject gmodule gee pluie-echo`

see https://git.pluie.org/pluie/libpluie-echo in order to install pluie-echo-0.2 pkg


## Install

git clone the project then cd to project directory and do :

```
meson --prefix=/usr ./ build
sudo ninja install -C build
```

## Compilation

```
valac  --pkg pluie-echo-0.2 --pkg pluie-yaml-0.4 main.vala
```

you can use `./build.sh` to rebuild/install the **pluie-yaml** lib and compile samples files


## Api / Documentation

https://pluie.org/pluie-yaml-0.4/index.htm  


## Docker

a demo image is now available on docker hub. To run a container  :

```
docker run --rm -it pluie/libyaml
```

then you can execute any samples, for example :
```
./json-loader
```

![pluie-yaml-json](https://www.meta-tech.academy/img/pluie-yaml-json.png)

see ![pluie/docker-images repository](https://github.com/pluie-org/docker-images)
for more details


## Usage

-------------------

### config

```vala

    var config = new Yaml.Config (path);
    var node   = config.get ("ship-to.address.city{0}");
    if (node != null) {
        of.echo (node.data)
    }

```
see Finder below to get precisions about config.get parameter (search path definition)

-------------------

### config with ^imports clause

```yml
# |  use special key word '^imports' to import other yaml config files in 
# |  current yaml document
# |  '^imports' must be uniq and a direct child of root node
# |  imported files are injected as mapping nodes at top document level
# |  so you cannot use keys that already exists in the document
^imports :
    # you can redefine default import path with the special key '^path'
    # if you do not use it, the default path value will be the current directory
    # redefined path values are relative to the current directory (if a relative path 
    # is provided)
    ^path : ./config
    # you can also define any other var by prefixing key with ^
    ^dir  : subdir
    # and use it enclosed by ^
    # here final test path will be "./config/subdir/test.yml"
    test  : ^dir^/test.yml 
    # here final db path will be "./config/db.yml"
    db    : db.yml
```

-------------------

### loader 

load a single document.   
`^imports` clause is out of effects here.

```vala
    var path   = "./config/main.yml";
    // uncomment to enable debug
    // Pluie.Yaml.DEBUG = true;
    var loader = new Yaml.Loader (path /* , displayFile, displayNode */);
    if ((done = loader.done)) {
        Yaml.Node root = loader.get_nodes ();
        root.display_childs ();
    }
```
-------------------

### finder

**pluie-yaml** provide a `Yaml.Finder` to easily retriew a particular yaml node.  
Search path definition has two mode.  
The default mode is `Yaml.FIND_MODE.DOT`  
- child mapping node are separated by dot
- sequence entry must be enclosed in curly brace

ex : `grandfather.father.son{2}.age`

The Other mode is Yaml.FIND_MODE.SQUARE_BRACKETS  
- node's key name must be enclosed in square brackets  
- sequence entry must be enclosed in curly brace  

ex : `[grandfather][father][son]{2}[age]`

with singlepair node, you can retriew corresponding scalar node with {0}

ex yaml file :

```yml
product:
    - sku         : BL394D
      quantity    : 4
      description : Basketball
```

vala code :

```vala
    ...
    var loader = new Yaml.Loader (path, true);
    if ((done = loader.done)) {
        Yaml.Node root = loader.get_nodes ();
        var finder = new Yaml.Finder(root);
        Yaml.Node? node = null;
        if ((node = finder.find ("product{0}.description")) != null) {
            var val = node.val ();
        }
        ...
    }
```

### Traversing

#### via iterator

```vala
    var config = new Yaml.Config (path);
    var root   = config.root_node ();
    if (root != null && !root.empty ()) {
        foreach (var child in root) {
            // do stuff
            of.echo (child.to_string ());
        }
    }
```

or

```vala
    var config = new Yaml.Config (path);
    var root   = config.root_node ();
    if (root != null && root.count () > 0) {
        Iterator<Yaml.Node> it = root.iterator ();
        Yaml.Node? child = null;
        for (var has_next = it.next (); has_next; has_next = it.next ()) {
            child = it.get ();
            // do stuff
            of.echo (child.to_string ());
        }
    }
```

#### other

```vala
        if (!node.empty ()) {
            Yaml.Node child = node.first();
            of.action("loop throught mapping next sibling", child.name);
            while (child!=null && !child.is_last()) {
                // do stuff
                of.echo (child.to_string ());

                child = child.next_sibling ();
            }
        }
```

```vala
        if (node.count () > 0) {
            child = node.last();
            of.action("loop throught mapping previous sibling", child.name);
            while (child!=null && !child.is_first()) {
                // do stuff
                of.echo (child.to_string ());
                
                child = child.previous_sibling ();
            }
        }
```

-------------------

### Tag Directives & Tag values

an example is available with `samples/yaml-tag.vala` sample
and `resources/tag.yml` file

on yaml side, proceed like that :

```yaml
%YAML 1.2
%TAG !v! tag:pluie.org,2018:vala/
---
!v!Pluie.Yaml.Example test1 :
    myname      : test1object
    type_int    : !v!int 3306
    type_bool   : !v!bool false
    type_char   : !v!char c
    type_string : !v!string mystring1
    type_uchar  : !v!uchar L
    type_uint   : !v!uint 62005
    type_float  : !v!float 42.36
    type_double : !v!double 95542123.4579512128
    !v!Pluie.Yaml.SubExample type_object : 
        toto : totovalue1
        tata : tatavalue1
        titi : 123
        tutu : 1
```

on vala side :

```vala
    ...
    var obj = (Yaml.Example) Yaml.Builder.from_node (root.first ());
    of.echo("obj.type_int : %d".printf (o.type_int));
    obj.type_object.method_a ()
```

![pluie-yaml-tag](https://www.meta-tech.academy/img/libyaml-tag-ex.png)

### Builder

**pluie-yaml** has automatic mechanisms to build Yaml.Object instances (and derived classes)
and set basics types properties, enum properties and based Yaml.Object properties.

Other types like struct or native GLib.Object (Gee.ArrayList for example) properties need some stuff in order to populate instances appropriately  
We cannot do introspection on Structure's properties, so you need to implement a method which will do the job.

First at all you need to register in the static construct, (properties) types that need some glue for instanciation.

```vala
public class Example : Yaml.Object
{
    static construct
    {
        Yaml.Object.register.add_type (typeof (Example), typeof (ExampleStruct));
        Yaml.Object.register.add_type (typeof (Example), typeof (Gee.ArrayList));
    }
    ...
```

Secondly you must override the `Yaml.Object populate_by_type (Glib.Typem Yaml.Node node)` original method.  
`populate_by_type` is called by the Yaml.Builder only if the type property is prealably registered.

Example of implementation from `src/vala/Pluie/Yaml.Example.vala` :

```
    public override void populate_by_type(GLib.Type type, Yaml.Node node)
    {
        switch (type) {
            case typeof (Yaml.ExampleStruct) :
                this.type_struct = ExampleStruct.from_yaml_node (node);
                break;
            case typeof (Gee.ArrayList) :
                this.type_gee_al = new Gee.ArrayList<string> ();
                if (!node.empty ()) {
                    foreach (var child in node) {
                        this.type_gee_al.add(child.data);
                    }
                }
                break;
        }
    }
```


for more details see :
* `src/vala/Pluie/Yaml.Example.vala`
* `src/vala/Pluie/Yaml.ExampleChild.vala`
* `src/vala/Pluie/Yaml.ExampleStruct.vala`
* `samples/yaml-tag.vala`

code from samples/yaml-tag.vala :

![pluie-yaml-tag](https://www.meta-tech.academy/img/libyaml-tag-code.png)

output from samples/yaml-tag.vala :

![pluie-yaml-tag](https://www.meta-tech.academy/img/libyaml-tag-ex2.png)

-------------------

### more samples

see samples files in ./samples directory

-------------------

### todo

* ~~imports clause~~
* ~~fix nodes traversing~~
* ~~rewrite nodes classes~~
* ~~put doc online~~
* ~~add docker image~~
* manage tag directives & tag (partially done)
* improve doc
* dumper
