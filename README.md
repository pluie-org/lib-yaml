# pluie-yaml

**pluie-yaml** is a vala shared library managing yaml files (v 1.2) and yaml nodes in vala language.  
As json is now a valid subset of yaml, you can use this lib to load json files too.  

The purpose of this project is to make vala able to load and deal with yaml configuration files.  
So, currently the lib deal only with one yaml document, but an @import clause (nodemap) is plan in order to load a subset of yaml files in the main yaml document.  

**pluie-yaml** use the ![libyaml c library](https://github.com/yaml/libyaml) (License MIT, many thanks to Kirill Simonov) to parse and retriew related yaml events.

## License

GNU GPL v3

## Prerequisites

`valac meson ninja glib gee gobject pluie-echo`


## Install

git clone the project then cd to project directory and do :

```
meson --prefix=/usr ./ build
sudo ninja install -C build
```

## Compilation

```
valac --pkg gee-0.8 --pkg pluie-echo-0.2 --pkg pluie-yaml-0.3 main.vala
```

see https://git.pluie.org/pluie/libpluie-echo in order to install pluie-echo-0.2 pkg

you can use `./build.sh` to rebuild/install the **pluie-yaml** lib and compile samples files

## Api / Documentation

https://pluie.org/pluie-yaml-0.3/index.htm  
(comming soon)

## Docker

a demo image will be available soon on docker hub. you will be able to run a container with :

```
docker run --rm -it pluie/libyaml
```

## Usage

### config

```

    var config = new Yaml.Config (path);
    var node   = config.get ("ship-to.address.city{0}");
    if (node != null) {
        of.echo (node.data)
    }

```

### loader 

```
    var path   = "./config/main.yml";
    // uncomment to enable debug
    // Pluie.Yaml.Scanner.DEBUG = true;
    var loader = new Yaml.Loader (path /* , displayFile, displayNode */);
    if ((done = loader.done)) {
        Yaml.NodeRoot root = loader.get_nodes ();
        root.display_childs ();
    }
```

### finder

**lib-yaml** provide a `Yaml.Finder` to easily retriew a particular yaml node.  
Search path definition has two mode.  
The default mode is `Yaml.FIND_MODE.SQUARE_BRACKETS`  
- node's key name must be enclosed in square brackets  
- sequence entry must be enclosed in curly brace  

ex : `[grandfather][father][son]{2}[age]`

The Other mode is Yaml.FIND_MODE.DOT  
- child mapping node are separated by dot
- sequence entry must be enclosed in curly brace

ex : `grandfather.father.son{2}.age`

with singlepair node, you can retriew corresponding scalar node with {0}

```
/*
# ex yaml file :
product:
    - sku         : BL394D
      quantity    : 4
      description : Basketball
*/
    ...
    Yaml.NodeRoot root = loader.get_nodes ();
    Yaml.Node?    node = null;
    if ((node = finder.find("product{0}.description{0}")) != null) {
        var val = node.data;
    }
```

### more samples

see samples files in ./samples directory

### todo

* import clause
* fix nodes traversing
* dumper

