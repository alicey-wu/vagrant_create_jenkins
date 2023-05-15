sudo yum check-update
sudo yum install git -y
sudo yum install curl -y
sudo yum install wget -y

wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin
#sudo yum install java-11-openjdk -y




git clone https://github.com/sandervanvugt/cka
#git clone https://github.com/codedx/codedx-kubernetes.git


sudo timedatectl set-timezone America/New_York
echo "--------Timezone has been set"

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

#sudo yum –y install openssh-server openssh-clients


##############################################################

echo setting up CentOS 7 with Docker
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        # notice that only verified versions of Docker may be installed
        # verify the documentation to check if a more recent version is available
sudo yum install -y docker-ce

# sudo yum list docker-ce --showduplicates | sort –r
# sudo yum install docker-ce-<VERSION STRING>

[ ! -d /etc/docker ] && sudo mkdir /etc/docker

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo touch /etc/docker/daemon.json

sudo sh -c 'cat > /etc/docker/daemon.json <<- EOF
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF'


sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

sudo systemctl disable --now firewalld



#######################################################################################################

echo RUNNING CENTOS CONFIG
sudo sh -c 'cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'

        # Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

        # disable swap (assuming that the name is /dev/centos/swap
sudo sed -i 's/^\/swapfile/#\/swapfile/' /etc/fstab
#sudo sed -i 's/^\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/' /etc/fstab
sudo swapoff /swapfile
sudo swapoff -a

sudo yum install -y kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
#sudo systemctl start kubelet

#sudo hostnamectl set-hostname master-node


sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
sudo firewall-cmd --reload

#worker node
#sudo hostnamectl set-hostname worker-node1
#sudo firewall-cmd --permanent --add-port=10251/tcp
#sudo firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --reload


sudo sh -c 'cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward                 = 1
EOF'
sudo sysctl --system


cp /vagrant/scripts/containerd-1.6.15-linux-amd64.tar.gz .
tar xvf containerd-1.6.15-linux-amd64.tar.gz
sudo mv bin/* /usr/bin/
	# Configure containerd
sudo mkdir -p /etc/containerd
sudo sh -c 'cat <<- TOML | sudo tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      discard_unpacked_layers = true
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
TOML'

	# Restart containerd
sudo systemctl daemon-reload
sudo systemctl restart containerd	


#sudo kubeadm init --pod-network-cidr=10.244.0.0/16
#  MASTER_IP="10.0.15.20"
#  NODENAME=$(hostname -s)
#  POD_CIDR="172.16.2.0/12"
#  sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name "$NODENAME" --ignore-preflight-errors Swap

#sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml