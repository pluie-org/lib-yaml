# pluie-yaml

vala shared library managing yaml files and yaml nodes in vala language.


## Prerequisites

valac meson ninja glib gio gee gobject pluie-echo


## Install

git clone the project then cd to project and do :

```
meson --prefix=/usr ./ build
sudo ninja install -C build
```

## Compilation

```
valac --pkg gee-0.8 --pkg pluie-echo-0.2 --pkg pluie-yaml-0.3 main.vala

```

## Api / Documentation

https://pluie.org/pluie-yaml-0.3/index.htm  
(comming soon)

## Docker

a demo image will be available on docker hub. you can run a container with :

```
docker run --rm -it pluie/libyaml
```

## Usage

```
    var loader = new Yaml.Loader (path);
    if ((done = loader.done)) {
        Yaml.NodeRoot root = loader.get_nodes ();
        root.display_childs ();
    }
```

### more samples

see samples files in ./samples directory
