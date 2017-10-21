#!/bin/bash

CURRENT_DIR="$(pwd)"
PROJECTS_CONTAINER_DIR="$(cd ../ && pwd)"
PROJECTS_DIR="$(cd ../ && ls -d */)"

# bash version should be gte v4 to support associative array
declare -A ramdaapis

total=0
for project_dir in $PROJECTS_DIR
do
    cd "$PROJECTS_CONTAINER_DIR/$project_dir"
    is_git_project=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    if [ -d "$PROJECTS_CONTAINER_DIR/$project_dir" -a "$is_git_project" ]; then
        apis=$(git grep -n 'R\.[a-z_][a-zA-Z_]*' -- './server/*' './src/*' \
                   | grep -o 'R\.[a-zA-Z_]*' \
                   | grep -o '[a-zA-Z_]*$')
        for api in $apis
        do
            if [ -z ${ramdaapis[$api]} ]; then
                ramdaapis[$api]=1
            else
                ramdaapis[$api]=$((${ramdaapis[$api]} + 1))
            fi
            total=$(($total+1))
        done
    fi
done

table_head="$(echo -e '| API | Frequence | Percent |\n| :--- | :--- |:--- |\n')"
total_footer="Total count: ${total}."
sorted_keys=$(
    for api in ${!ramdaapis[*]}
    do
        percent=$(echo "scale = 2; ${ramdaapis[$api]} * 100 / ${total}" | bc)
        echo -e "| $api | ${ramdaapis[$api]} | ${percent}% |\n"
    done | sort -rn -k4)
echo -e "$table_head\n$sorted_keys\n\n$total_footer\n" | tee "$CURRENT_DIR/ramda-status.md"


