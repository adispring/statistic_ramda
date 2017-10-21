#!/bin/bash

PROJECTS_CONTAINER_DIR="$(cd ../ && pwd)"
PROJECTS_DIR="$(cd ../ && ls -d */)"

# bash version should be gte v4 to support associative array
declare -A ramdaapis

for project_dir in $PROJECTS_DIR
do
    cd "$PROJECTS_CONTAINER_DIR/$project_dir"
    is_git_project=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    if [ -d "$PROJECTS_CONTAINER_DIR/$project_dir" -a "$is_git_project" ]; then
        apis=$(git grep -n 'R\.[a-z_][a-zA-Z_]*' -- './server/*' './src/*' | grep -o 'R\.[a-zA-Z_]*' | grep -o '[a-zA-Z_]*$')
        for api in $apis
        do
            if [ -z ${ramdaapis[$api]} ]; then
                ramdaapis[$api]=1
            else
                ramdaapis[$api]=$((${ramdaapis[$api]} + 1))
            fi
        done
    fi
done

for api in ${!ramdaapis[*]}
do
    echo "$api -> ${ramdaapis[$api]}"
done | sort -rn -k3 | tee ramda-status.md

