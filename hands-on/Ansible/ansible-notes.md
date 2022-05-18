# command documentation

```bash
ansible-doc ping
ansible --help
ansible-playbook --help
ansible --list-host all
ansible --list-host dev
ansible --list-host webservers
ansible --list-host \!webservers
ansible --list-host webserver:devservers
```

# playbook info

```bash
# check mode
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --check --diff
# debugging
ansible-playbook playbook.yml -vvv
# limit selected host
ansible-playbook playbook.yml -l node1
# list host in playbook
ansible-playbook playbook.yml --list-hosts
# list tasks in playbook
ansible-playbook playbook.yml --list-tasks
```

# list inventory

```bash
ansible-inventory --list
ansible-inventory --graph
```

# list inventory plugins

```bash
ansible-doc -t inventory -l
# aws_ec2 plugin doc
ansible-doc -t inventory aws_ec2
# list dynamic inventory in yaml
ansible-inventory -i inventory_aws_ec2.yml --list --yaml
```

# list ansible facts

```bash
ansible all -m setup
ansible all -m gather_facts
ansible node3 -m setup | grep ansible_distribution_version
ansible node1:node2 -m setup | grep ansible_os_family
```
# Display facts from all hosts and store them indexed by I(hostname) at C(/tmp/facts).
```bash
ansible all -m setup --tree /tmp/facts
```

# Ansible Configuration Settings

```bash
ansible-config dump
ansible-config dump | grep ROLE
ansible-config list | grep -E 'HOST_KEY|true'

# view your "ansible.cfg" file
ansible-config view
```

# run multiple playbooks in one playbook

```yml
# playbooks.yml

- import_playbook: ping.yml
- import_playbook: shell.yml
- import_playbook: configure.yml
```