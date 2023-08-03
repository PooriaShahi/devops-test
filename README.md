# Document for this devops test
## Topics
- Run the test
- Provision Kubernetes Cluster
- Creating Helm Charts
- Create Single Executator File

### Run the test
First you must clone this repository with the command below and change directory to it:
```
git clone https://github.com/PooriaShahi/devops-test.git
cd devops-test
```
Then make sure you have **pip3** installed on your system. you can check that with the command below:
```
pip3 -V
```
If it's not installed on your system then do the below:
Python installation
```
python -m pip3 install --upgrade pip
```
Ubuntu installation
```
sudo apt install python3-pip
```
MacOS installation
```
brew install pip3
```

Then make sure that you have a server with **root user** and you have a **ssh-key based** authentication with it.

For your domain, please **change value of host in wart/values.yaml** file.

Then run the command below:
```
bash constructor.sh
```

Enter you server's IP and _go make some snack and some coffee until magic completely happen_ ;)

When magic ends, you can see 2 different url based on your domain that defined in the **wart/values.yaml** file. Copy the urls and see the results.

### Provision Kubernetes Cluster
For this challenge i use [**kubespray**](https://kubespray.io) as recommended and provision a single node (CP+Worker) k8s cluster. I using **Flannel** CNI plugin for overlay k8s network. First creating my variables with the command below:
```
cp -rfp ./kubespray/inventory/sample ./kubespray/inventory/myCluster
```
then declare the ip of remote server and create hosts file for kubespray's ansible:
```
declare -a IPS=(<IP>)
CONFIG_FILE=kubespray/inventory/myCluster/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py ${IPS[@]}
```
for using flannel network instead of calico, change **kube_network_plugin** field in the path below:
```
sed -i -e 's/calico/flannel/g' ./kubespray/inventory/myCluster/group_vars/k8s_cluster/k8s-cluster.yml
```
and then running the command below for provisioning the k8s cluster:
```
ansible-playbook -i inventory/myCluster/hosts.yaml -u root -b -v cluster.yml
```

### Creating Helm Charts
Used the [**wart**](https://github.com/PooriaShahi/wart) helm chart created by [Pooria Shahi](https://github.com/PooriaShahi).

In this chart for every services, manifest written and we deploy the chart with the command below:
```
helm upgrade --install wp-app wart
```

### Create Single Executator File
For this purpose we write 2 seprate ansible playbooks for initialize the server include update and upgrade the server and the main-course playbook for after provision cluster and using that for install ingress-nginx and initialize wordpress.
All this will be done with a **constructor.sh** file which is a bash script file for implementing all together.