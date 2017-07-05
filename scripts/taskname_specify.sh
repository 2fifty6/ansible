#!/bin/bash

# this script ensures that"
#   if a task file's name is not "main", then all of its tasks' names will have that file name prepended
#   else, if the task's file name is "main", then its tasks will have nothing prepened as such
CURRENT_REPO_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
for TASK_DIR in `find $CURRENT_REPO_DIR/roles -type d -name tasks`; do
  for FILE in `ls $TASK_DIR 2>/dev/null | sed 's/.yml$//'`; do
    if [[ $FILE == "main" ]]; then
      grep -re "- name: " "$TASK_DIR/$FILE.yml" | grep "name: [\"']*\([A-Za-z_0-9]*\)* |" | while read LINE
      do
        BADMATCH=`echo $LINE | sed "s/\(\- name: \)\([A-Za-z_0-9]* | \)*\(.*\)/\2/"`
        TASKNAME=`echo $LINE | sed "s/\(\- name: \)\([A-Za-z_0-9]* | \)*\(.*\)/\3/"`
        echo -e "\e[35m$TASK_DIR/$FILE.yml:\e[0m  stripping '\e[1m`echo $BADMATCH | sed \"s/\(.*\) |/\1/\"`\e[0m' from task name"
        sed -i "s/- name: $BADMATCH\(.*\)/- name: \1/" "$TASK_DIR/$FILE.yml"
      done
    else
      grep -re "- name: " "$TASK_DIR/$FILE.yml" | grep -v "name: [\"']*$FILE |" | while read LINE
      do
        BADMATCH=`echo $LINE | sed "s/\(\- name: \)\([A-Za-z_0-9]* | \)*\(.*\)/\2/"`
        TASKNAME=`echo $LINE | sed "s/\(\- name: \)\([A-Za-z_0-9]* | \)*\(.*\)/\3/"`
        if [[ ! -z "$BADMATCH" ]]; then
          # - name: WRONG_FILE | task name
          echo -e "\e[35m$TASK_DIR/$FILE.yml:\e[0m replacing '\e[1m`echo $BADMATCH | sed \"s/\(.*\) |/\1/\"`\e[0m' with '\e[1m$FILE\e[0m' for '$TASKNAME'"
          sed -i "s/- name: $BADMATCH\(.*\)/- name: $FILE | \1/" "$TASK_DIR/$FILE.yml"
        else
          # - name: task name
          echo -e "\e[35m$TASK_DIR/$FILE.yml:\e[0m prepending '\e[1m$FILE\e[0m' to '$TASKNAME'"
          sed -i "s/- name: $TASKNAME/- name: $FILE | $TASKNAME/" "$TASK_DIR/$FILE.yml"
        fi
      done
    fi
  done
done

