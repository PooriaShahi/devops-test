#!/bin/bash/

# Fetch remote server IP
read -p "Enter your server's ip with root user: " serverIp
echo $serverIp

# install ansible
pip3 install ansible

# config ansible hosts file
cat <<EOF >>ansible/hosts
[all]
`echo $serverIp` ansible_user=root
EOF

# Prepare kubespray
cp -rfp ./kubespray/inventory/sample ./kubespray/inventory/myCluster
declare -a IPS=(`echo $serverIp`)
CONFIG_FILE=kubespray/inventory/myCluster/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}

# Install kubespray requirements
pip3 install -r kubespray/requirements.txt

# Using flannel instead of calico
sed -i -e 's/calico/flannel/g' ./kubespray/inventory/myCluster/group_vars/k8s_cluster/k8s-cluster.yml

# Run initializer ansible for update and upgrade ubuntu
ansible-playbook -i ansible/hosts ansible/initializer.yaml

# Run kubespray for provisioning the cluster
cd kubespray
ansible-playbook -i inventory/myCluster/hosts.yaml -u root -b -v cluster.yml

# Run main-course ansible for make things ready
cd ../
ansible-playbook -i ansible/hosts ansible/main-course.yaml

# Visit website
echo "PHPmyadmin is ready at https://`grep host wart/values.yaml | awk '{print $2}'`/dbadmin"
echo "Wordpress is ready at https://`grep host wart/values.yaml | awk '{print $2}'`/wordpress"