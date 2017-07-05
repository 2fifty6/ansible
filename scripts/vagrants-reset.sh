#!/bin/bash

# This ensures that no sensitive info, i.e. credentials, will ever manage to outlive the lifetime of this script
control_c()
{
  exit
}
trap control_c SIGINT

TEMP=`getopt -o l:m:p:r:fs --long match:,playbook:,limit:,restore:,full,snapshot,no-provision,no-destroy -n "$0" -- "$@"`
eval set -- "$TEMP"

# TODO
usage () {
  ISERROR=$1
  echo -e "\[31;1mERROR:\e[;0m SoMeErRoRmEsSaGe!"
  echo -e "\t\e[1;1musage: `basename $0`\e[0m [ OPTION ]"
  exit $ISERROR
}

FULL=0
NO_DESTROY=0
NO_PROVION=0
PLAYBOOK=""
MATCH=""
LIMIT=""
RESTORE=""

while true ; do
  case "$1" in
    -f|--full) FULL=1 ; shift ;;
    -l|--limit) LIMIT=$2 ; shift 2 ;;
    -m|--match) MATCH=$2 ; shift 2 ;;
    -p|--playbook) PLAYBOOK=$2 ; shift 2 ;;
    -r|--restore) RESTORE=$2 ; NO_DESTROY=1 ; shift 2 ;;
    --no-provision) NO_PROVION=1 ; shift ;;
    --no-destroy) NO_DESTROY=1 ; shift ;;
    --) shift ; break ;;
  esac
done

# NOTE: for this script to work, Vagrantfiles must be placed in the "vagrants" directory
# one level up from the current script's directory

# RESET / RESTORE
REPO_DIR_LOCAL=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
for VAGRANT_DIR in `find $REPO_DIR_LOCAL/vagrants -type f -name Vagrantfile | sort -r | xargs dirname`; do
  if [[ "$VAGRANT_DIR" =~ "$MATCH" ]]; then
    echo -e "\e[1;4mWorking on vagrant\e[m: \e[92m`basename $VAGRANT_DIR`\e[m"
    cd $VAGRANT_DIR
    VM_NAME=$(grep --color=no -r vb.name Vagrantfile | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ ! -z "`VBoxManage list vms | grep \"$VM_NAME\"`" ]]; then
      vagrant halt
      LATEST_SNAPSHOT=$(VBoxManage snapshot $VM_NAME list | grep --color=no Name | tail -n1 | awk '{print $2}')
      if [[ ! -z $RESTORE ]]; then
        echo -e "\e[1;1mRestoring snapshot\e[m: \e[92m$RESTORE\e[m"
        VBoxManage snapshot $VM_NAME restore $RESTORE
      elif [[ ! -z $LATEST_SNAPSHOT ]]; then
        echo -e "\e[1;1mRestoring latest snapshot\e[m: \e[92m$LATEST_SNAPSHOT\e[m"
        VBoxManage snapshot $VM_NAME restorecurrent
      else
        echo -e "\e[1;31mDestroying $VM_NAME\e[m. (hit Ctrl+C to cancel)"
        sleep 3
        vagrant destroy -f
      fi
    fi
    vagrant up
    echo
  fi
done

# PROVISION
LIMIT=""
if [[ $NO_PROVION -ne 1 ]]; then
  if [[ ! -z $MATCH ]]; then
    LIMIT="--limit localhost,$MATCH"
  fi
  ansible-playbook $REPO_DIR_LOCAL/playbooks/vagrants/provision.yml $LIMIT
fi

if [[ $FULL -eq 1 ]]; then
  # classically, the site.yml is a playbook to be used to test all of your roles
  ansible-playbook $REPO_DIR_LOCAL/playbooks/vagrants/site.yml $LIMIT
elif [[ ! -z $PLAYBOOK && -e $REPO_DIR_LOCAL/playbooks/vagrants/${PLAYBOOK}.yml ]]; then
  ansible-playbook $REPO_DIR_LOCAL/playbooks/vagrants/${PLAYBOOK}.yml $LIMIT
fi
