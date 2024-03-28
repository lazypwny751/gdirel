#!/bin/sh

# Required packages: coreutils and gawk

set -e
export verbose="false" help="true"

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

desktop() {
    if [ -n "${DESKTOP_SESSION}" ]
        then
            echo "${DESKTOP_SESSION}"
    elif [ -n "${XDG_SESSION_DESKTOP}" ]
        then
            echo "${XDG_SESSION_DESKTOP}"
    elif [ -n "${XDG_CURRENT_DESKTOP}" ]
        then
            echo "${XDG_CURRENT_DESKTOP}"
    else
        echo "Unknown Desktop Environment."
    fi
}

processor() {
    gawk -F ": " "/model name/ { print(\$2); exit; }" "/proc/cpuinfo"
}

corenum() {
    gawk -F ": " "/model name/ { count++ } END { print(count); }" "/proc/cpuinfo"
}

while getopts :komndpcavh opt
    do
        case "${opt}" in
            ("k")
                export help="false"
                if "${verbose:-false}"
                    then 
                        printf "Kernel Release: " 
                fi
                kernel_release
            ;;
            ("o")
                export help="false"
                if "${verbose:-false}"
                    then 
                        printf "Distribution Name: "
                fi
                distribution
            ;;
            ("m")
                export help="false"
                export pkgm="$(packagemngr)"
                if "${verbose:-false}"
                    then 
                        printf "Package Manager: "
                fi
                echo "${pkgm##*/}"
            ;;
            ("n")
                export help="false"
                export pkgm="$(packagemngr)"
                if "${verbose:-false}"
                    then 
                        printf "Package(s) installed via ${pkgm##*/}: "
                fi
                packages "${pkgm##*/}"
            ;;
            ("d")
                export help="false"
                if "${verbose:-false}"
                    then
                        printf "Default Desktop/Window Manager: "
                fi
                desktop
            ;;
            ("p")
                export help="false"
                if "${verbose:-false}"
                    then 
                        printf "Processor: "
                fi
                processor
            ;;
            ("c")
                export help="false"
                if "${verbose:-false}"
                    then 
                        printf "CPU(s): "
                fi
                corenum
            ;;
            ("a")
                export help="false"
                if "${verbose}"
                    then
                        export pkgm="$(packagemngr)"
                    cat <<VALL
Kernel Release: $(kernel_release)
Distribution Name: $(distribution)
Package Manager: ${pkgm##*/}
Package(s) installed via ${pkgm##*/}: $(packages "${pkgm##*/}")
Default Desktop/Window Manager: $(desktop)
Processor: $(processor)
CPU(s): $(corenum)
VALL
                else
                    export pkgm="$(packagemngr)"
                    kernel_release
                    distribution
                    echo "${pkgm##*/}"
                    packages "${pkgm##*/}"
                    desktop
                    processor
                    corenum
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
                printf "${0##*/} usage:
\t-k\tprint current kernel release.
\t-o\tprint distribution name.
\t-m\tprint current/native package manager name.
\t-n\thow many packages are installed with current/native package manager.
\t-d\tprint current desktop environment or window manager.
\t-p\tprint processor model.
\t-c\tprint the cpu have how many cores.
\t-a\tprint all informations above.
\t-v\tprint with verbose \"add header like (any: x)\".
\t-h\tprint this screen.

Pull requests are open: https://github.com/lazypwny751/gdirel \n"
                exit 0
            ;;
            (\?)
                echo "\"-${OPTARG}\" is an unknown option, type \"sh ${0##*/} -h\" for more information."
            ;;
        esac
done

if "${help}"
    then
    echo "If you don't know how to use it, you can start by typing \"sh ${0##*/} -va\", for more details type \"sh ${0##*/} -h\"."
fi