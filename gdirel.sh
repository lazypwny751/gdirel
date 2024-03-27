#!/bin/sh

# Required packages: coreutils and gawk

set -e
export verbose="false"

kernel_release() {
    cat "/proc/version" | gawk "{ print(\$1, \$2, \$3); }"
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
    elif [ -f "/etc/dnf/dnf.conf" ] && [ -f "$(command -v dnf)" ]
        then
        command -v dnf
    elif [ -d "/etc/zypp" ] && [ -f "$(command -v zypper)" ]
        then
        command -v zypper
    else
        echo "Unknown Package Manager."
    fi
}

packages() {
    case "${1}" in
        ("apt")
            dpkg -l | head -n -5 | wc -l
        ;;
        ("pacman")
            pacman -Qq | wc -l
        ;;
        ("dnf")
            dnf list installed | tail -n +3 | wc -l
        ;;
        ("zypper")
            zypper se --installed-only | tail -n +5 | wc -l
        ;;
        (*)
            echo "null"
        ;;
    esac
}

processor() {
    gawk -F ": " "/model name/ { print(\$2); exit; }" "/proc/cpuinfo"
}

corenum() {
    gawk -F ": " "/model name/ { count++ } END { print(count); }" "/proc/cpuinfo"
}

while getopts :komnpcavh opt
    do
        case "${opt}" in
            ("k")
                if "${verbose:-false}"
                    then 
                        printf "Kernel Release: " 
                fi
                kernel_release
            ;;
            ("o")
                if "${verbose:-false}"
                    then 
                        printf "Distribution Name: "
                fi
                distribution
            ;;
            ("m")
                export pkgm="$(packagemngr)"
                if "${verbose:-false}"
                    then 
                        printf "Package Manager: "
                fi
                echo "${pkgm##*/}"
            ;;
            ("n")
                export pkgm="$(packagemngr)"
                if "${verbose:-false}"
                    then 
                        printf "Package(s) installed via ${pkgm##*/}: "
                fi
                packages "${pkgm##*/}"
            ;;
            ("p")
                if "${verbose:-false}"
                    then 
                        printf "Processor: "
                fi
                processor
            ;;
            ("c")
                if "${verbose:-false}"
                    then 
                        printf "CPU(s): "
                fi
                corenum
            ;;
            ("a")
                if "${verbose}"
                    then
                        echo "with verbose all"
                else
                    echo "all"
                fi
            ;;
            ("v")
                if "${verbose:-false}"
                    then
                    export verbose="false"
                else
                    export verbose="true"
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