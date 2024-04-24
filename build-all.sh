#!/usr/bin/env bash
set -e

#
#  Build every preset
#

script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

# figure out where the root of the project is
project_dir=
if [[ "$PWD" == */build ]]
then
  project_dir=$(dirname "${PWD}")
else
  project_dir="${PWD}"
fi

echo -e "Project directory = \"${project_dir}\""

# if no build directory, make one
mkdir -p "${project_dir}/build"

# create the build directory if necessary
(
    cd "${project_dir}/build"
    # the "eval" is to remove the quotes around the preset names
    presets=$(eval echo $(cmake .. --list-presets | tail -n +3))

    for preset in ${presets}; do
        echo -en "Building \"${preset}\"..."

        rm -rf *
        cmake .. -G Ninja --preset=${preset} >&/dev/null

        if cmake --build . -j $(nproc) >&/dev/null && ctest --output-on-failure 1>/dev/null ; then
            echo -e "\e[92m ok \e[0m"
        else
            echo -e "\e[31m FAILED \e[0m"
            (cmake --build . -j $(nproc) && ctest --output-on-failure 1>/dev/null) || true # don't want this to stop the script
        fi
    done
)
