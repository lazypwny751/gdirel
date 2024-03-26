#!/bin/sh

set -e
export table="false"

kernel_release() {
    while IFS="" read -r line
        do
        echo "${line}"
    done < "/proc/version"
}

distribution() {
    if [ -f "/etc/os-release" ]
        then
            . "/etc/os-release"
            if [ -n "${NAME}" ]
                then
                echo "${NAME}"
            else
                echo "Unknown Distribution."
            fi
    fi
}

# Priority: debian -> arch -> fedora -> suse
# this method is weak but fast. 
packagemngr() {
    if [ -d "/etc/apt" ] && [ -f "$(command -v apt)" ]
        then
        command -v apt
    elif [ -f "/etc/pacman.conf" ] && [ -f "$(command -v pacman)" ]
        then
        command -v pacman
    elif [ -d "" ]
        then
        command -v dnf
    elif [ -d "" ]
        then
        command -v zypper
    else
        echo "Unknown Package Manager."
    fi
}

while getopts :komnpcth opt
    do
        case "${opt}" in
            ("k")
                # printf "Kernel Release: "
                kernel_release
            ;;
            ("o")
                # printf "Distribution Name: "
                distribution
            ;;
            ("m")
                export pkgm="$(packagemngr)"
                # echo "Package Manager: ${pkgm##*/}"
                echo "${pkgm##*/}"
            ;;
            ("n")
                # export pkgm="$(packagemngr)"
                # echo "Package installed via ${pkgm##*/}: "
            ;;
            ("p")
                echo "processor name."
            ;;
            ("c")
                echo "core number"
            ;;
            ("t")
                if "${table:-false}"
                    then
                    export table="false"
                else
                    export table="true"
                fi
            ;;
            ("h")
                echo "
"
                exit 0
            ;;
            (\?)
                echo "unknown option, type \"sh ${0##*/} -h\" for more information."
                exit 1
            ;;
        esac
done