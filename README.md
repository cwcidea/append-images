# append-images

This project can add various notebooks to your docker image.

## Install
Clone this project to your local host
```
git clone https://github.com/cwcidea/append-images.git
```

## Usage

NAME
        $0 - Additional notebook image.
SYNOPSIS
        $0 [REQIREDS]... [OPTIONS]...
REQIREDS
        -i, --baseimage : The original image of the notebook needs to be added.
        -t, --newtag :    Original image name.
        -a, --add :       Which notebook modules(jupyter|vscode|rstudio) need to be added.
OPTIONS
        -v, --osversion : OS(centos|ubuntu) within the original image
        -o, --out :       Save Image.
USAGES
        $0 [-i original_image_name] [-t image:tag] [-a module]
EXAMPLES
```
        1) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter
        2) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -v centos
        3) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o
        4) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o tar
        5) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o tgz
        6) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o jupyterpytorch1.10.0-centos7.6.tar
        7) $0 -i /path/to/pytorch1.10.0-centos7.6.tar -t jupyter:pytorch1.10.0-centos7.6 -a jupyter
```
