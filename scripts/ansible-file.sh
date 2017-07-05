#!/bin/bash
# This can be used to generate ansible yml files ad-hoc or in bulk

# vim plugin:
# https://github.com/chase/vim-ansible-yaml

create_file () {
  NEWFILE=$1
  cat > $NEWFILE<<END
---
# file: $NEWFILE

# TODO

# vim:ft=ansible
END
}

for NEWFILE in "$@"; do create_file $NEWFILE; done
