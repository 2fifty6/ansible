#!/bin/bash
# Script to automatically install/configure your Ansible environment

# TODO abstract for OSX

# convenience function, tells us what we're doing and when the command ran
shdo () {
  FULLCMD=($*)
  CMD="$1" ARGS=${FULLCMD[@]:1}
  NUMTABS=$((`tput cols`/8 - 2))

  if [[ `uname` == "Darwin" ]]; then
    echo -en "$CMD $ARGS"
    echo -ne "\r"
    for (( i=0; i<$NUMTABS; i++ ))
    do
      echo -ne "\t"
    done
    echo "   [ `date +%T` ]"
    eval "$CMD $ARGS"
    RC=$?
    if [ $RC -eq 0 ]
    then
      echo "[ OK ]"
    else
      echo "[ FAIL ] ($RC)"
    fi
  else
    echo -en "\e[01m* $CMD $ARGS\e[0m"
    echo -ne "\r"
    for (( i=0; i<$NUMTABS; i++ ))
    do
      echo -ne "\t"
    done
    echo -e "    \e[0;1m[ \e[32m`date +%T` \e[0;1m]\e[0m"
    eval "$CMD $ARGS"
    RC=$?
    if [ $RC -eq 0 ]
    then
      echo -e "[ \e[32mOK\e[0m ]"
    else
      echo -e "[ \e[01;31mFAIL\e[0m ] ($RC)"
    fi
  fi
}

# if we haven't specified not to install anything
if [[ -z "`echo $* | grep '\-\-no\-install'`" ]]; then
  # Determine package manager / if epel-release is necessary
  PKGCMD=""
  if [[ ! -z "`which yum`" ]]; then
    PKGCMD="yum"
    shdo sudo $PKGCMD install -y epel-release
    if [[ -z "`echo $* | grep '\-\-no\-update'`" ]]; then
      shdo sudo $PKGCMD makecache
    fi
  elif [[ ! -z "`which apt-get`" ]]; then
    PKGCMD="apt-get"
    shdo sudo $PKGCMD install -y software-properties-common
    shdo sudo add-apt-repository -y ppa:ansible/ansible
    if [[ -z "`echo $* | grep '\-\-no\-update'`" ]]; then
      shdo sudo $PKGCMD update
    fi
  elif [[ ! -z "`which brew`" ]]; then
    PKGCMD="brew"
  else
    echo -e "\e[1;31mERROR:\e[0m No package manager found!"
    exit 1
  fi

  # install deps
  if [[ $PKGCMD != "brew" ]]; then
    PKGCMD="sudo $PKGCMD"
  fi
  shdo $PKGCMD install -y ansible sshpass libssl-dev openssl python-pip # sshfs redis-server krb5-config libkrb5-dev

  shdo sudo -H pip install --upgrade pip
  shdo sudo -H pip install "http://github.com/diyan/pywinrm/archive/master.zip#egg=pywinrm"
  #shdo sudo -H pip install redis
  #shdo sudo -H pip install pykerberos
fi

# Uncomment to enable an ansible-vault password
#shdo sudo touch ./.vault_passwd.txt

# REQUIRED for fact-caching with redis
# TODO  ensure redis.conf does not have requirepass turned on
#shdo sudo sed -i 's/^\([^#]+\)requirepass\(.*\)/#\1requirepass\2/' /etc/redis/redis.conf
