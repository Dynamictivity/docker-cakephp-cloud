#!/bin/bash

if [ -n "$ANSIBLE_GALAXY_ROLES" ]; then
  # Split ansible galaxy roles into array
  IFS=',' read -r -a array <<< "$ANSIBLE_GALAXY_ROLES";

  # Iterate over each galaxy role and install it
  for element in "${array[@]}"
  do
      ansible-galaxy install $element >>/ansible/galaxy-install.log 2>&1;
  done
fi

if [ -n "$ANSIBLE_GALAXY_ROLES" ]; then
    # Download remote playbook
    cd /ansible && wget -O playbook.yml $ANSIBLE_PLAYBOOK_URL
fi

# Run Ansible playbook
cd /ansible && ansible-playbook playbook.yml
