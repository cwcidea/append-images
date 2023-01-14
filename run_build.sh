#!/bin/bash
function show_help()
{
        echo -e "
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
                1) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter
                2) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -v centos
                3) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o
                4) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o tar
                5) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o tgz
                6) $0 -i pytorch:1.10.0-centos7.6 -t jupyter:pytorch1.10.0-centos7.6 -a jupyter -o jupyterpytorch1.10.0-centos7.6.tar
                7) $0 -i /path/to/pytorch1.10.0-centos7.6.tar -t jupyter:pytorch1.10.0-centos7.6 -a jupyter
        
        "
        exit 0
}
function check_args(){
        if [[ ! ${baseimage} ]];then
                echo "-i|--baseimage cann't be empty !"
                exit 1
        fi
        if [[ ! ${newtag} ]];then
                echo "-t|--newtag cann't be empty !"
                exit 1
        fi
        if [[ ! ${add} ]];then
                echo "-a|--add cann't be empty !"
                exit 1
        fi

}


function check_os(){
        osversion="$(docker run -t --entrypoint="" ${base_tag} cat /etc/os-release 2> /dev/null | grep -i '^NAME' | awk -F= '{print $2}' | sed 's/\"//g' | awk '{print $1}')"
        if [[ ${osversion} == "" ]];then 
        osversion="$(docker run -t --entrypoint="" ${base_tag} cat /etc/redhat-release 2> /dev/null | awk '{print $1}')"
        fi
}

function load_image(){
        echo "Loading the image may take some time..."
        last_line="$(docker load < ${baseimage} 2> /dev/null | grep -i '^Loaded image')"
        base_tag="$(echo ${last_line} | awk '{print $3}')"
        if [[ ${base_tag} == "" ]];then
        base_tag=${baseimage}
        elif [[ ${base_tag} == ID* ]];then
        base_tag="$(echo ${last_line} | awk '{print $4}' | awk -F: '{print $2}' | cut -b 1-12)"
        fi
}

function build_image(){
        if [ ! -d "./tmp" ];then
        mkdir tmp
        fi
        local tmp_dockerfile="Dockerfile.${RANDOM}"
        if [[ ${osversion} == CentOS* || ${osversion} == centos* ]];then
                case ${add} in
                        jupyter)
                                \cp -f ./centos_dockerfiles/Dockerfile.add_jupyterlab_centos ./tmp/${tmp_dockerfile}
                                ;;
                        vscode)
                                \cp -f ./centos_dockerfiles/Dockerfile.add_codeserver_centos ./tmp/${tmp_dockerfile}
                                ;;
                        rstudio)
                                \cp -f ./centos_dockerfiles/Dockerfile.add_rstudio_centos ./tmp/${tmp_dockerfile}
                                ;;
                        *)
                                echo "The parameter \"--add\" should be set to \"jupyter|vscode|rstudio\"."
                                exit 1
                                ;;
                esac
        elif [[ ${osversion} == Ubuntu* || ${osversion} == ubuntu* ]];then
                case ${add} in
                        jupyter)
                                \cp -f ./ubuntu_dockerfiles/Dockerfile.add_jupyterlab_ubuntu ./tmp/${tmp_dockerfile}
                                ;;
                        vscode)
                                \cp -f ./ubuntu_dockerfiles/Dockerfile.add_codeserver_ubuntu ./tmp/${tmp_dockerfile}
                                ;;
                        rstudio)
                                \cp -f ./ubuntu_dockerfiles/Dockerfile.add_rstudio_ubuntu ./tmp/${tmp_dockerfile}
                                ;;
                        *)
                                echo "The parameter \"--add\" should be set to \"jupyter|vscode|rstudio\"."
                                exit 1
                                ;;
                esac
        else 
                echo "${osversion} is not currently supported."
                exit 1
        fi
        local temp_image
        temp_image="$(grep -n '^FROM' ./tmp/${tmp_dockerfile} | tac | head -1 | awk '{print $2}')"
        sed -i "s?${temp_image}?${base_tag}?g" ./tmp/${tmp_dockerfile}
        docker build -f ./tmp/${tmp_dockerfile} -t ${newtag} ./tmp/
        if [[ $? -eq 0 ]];then
                echo -e "\033[32mBuild Image Successfully !\033[0m"
        else
                echo -e "\033[32mBuild Image unsuccessful !\033[0m"
                exit 1
        fi
}

function save_image(){
        if [[ ${button} -eq 1 ]];then
                echo "Saving the image may take some time..."
                case ${out} in
                        ""|tgz)
                        docker save ${newtag} | gzip > ./tmp/${newtag//:/}.tar.gz
                        if [[ $? -eq 0 ]];then
                                echo -e "\033[32mSave Image: ./tmp/${newtag//:/}.tar.gz Successfully.\033[0m"
                        fi
                        ;;
                        tar)
                        docker save -o ./tmp/${newtag//:/}.tar ${newtag}
                        if [[ $? -eq 0 ]];then
                                echo -e "\033[32mSave Image: ./tmp/${newtag//:/}.tar Successfully.\033[0m"
                        fi
                        ;;
                        *)
                        docker save -o ./tmp/${out} ${newtag}
                        if [[ $? -eq 0 ]];then
                                echo -e "\033[32mSave Image: ./tmp/${out} Successfully.\033[0m"
                        fi
                        ;;
                esac


        fi
}

# set -ex
args=$(getopt -n $0 -o hi:t:a:v::o:: -l help,baseimage:,newtag:,add:,osversion::,out:: -- "$@")

if [ $? != 0 ];then
	echo 'Try '$0 '--help for more information.'
	exit 1
fi

eval set -- "${args}"
while :
do
        case $1 in
                -h|--help)
                        show_help
                        exit 0
                        ;;
                -i|--baseimage)
                        baseimage=$2
                        shift
                        ;;
                -t|--newtag)
                        newtag=$2
                        shift
                        ;;
                -a|--add)
                        add=$2
                        shift
                        ;;
                -v|--osversion)
                        osversion=$2
                        shift
                        ;;
                -o|--out)
                        button=1
                        out=$2
                        shift
                        ;;
                --)
                        shift
                        break
                        ;;
                *)
                        echo "Internal error!"
                        exit 1
                        ;;
        esac
        shift
done
check_args
load_image     
if [[ ${osversion} == "" ]];then
check_os
fi
build_image
save_image