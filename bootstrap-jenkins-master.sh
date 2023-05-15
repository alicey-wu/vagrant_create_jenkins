#!/bin/bash
set -e
# install jenkins
sudo yum update -y
sudo yum -y install wget
sudo yum -y install curl
#sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
#sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#sudo yum -y install java-1.8.0-openjdk jenkins -y
sudo yum install java-11-openjdk -y
sudo yum install jenkins -y
echo "--------Jenkins,Java installed"
#uncomment the below if you want to lock to a certain version of jenkins 
#sudo yum-config-manager --disable jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "--------Jenkins enabled and started"
# some useful tools
sudo yum install telnet bind-utils nano git net-tools -y
echo "--------Utilities have been installed"
#sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
#sudo yum -y install python36u python36u-pip
#sudo pip3.6 install awscli





sudo yum install git gcc gcc-c++ unixODBC-devel Cython libffi-dev openssl-devel -y
#sudo curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/microsoft.repo
sudo bash -c "curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/microsoft.repo"

#echo "proxy=http://proxyprd.scotia-capital.com:8080" >> /etc/yum.repos.d/microsoft.repo
sudo ACCEPT_EULA=Y yum install msodbcsql17 -y

sudo yum install tree -y
sudo yum install centos-release-scl -y
sudo yum install rh-python38 rh-python38-python-devel -y

#any Python commands executed within that session will use the Python 3.8 version provided by the software collection
sudo scl enable rh-python38 bash
sudo cat >> /etc/profile.d/java.sh <<EOF
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/jre
export PATH=$JAVA_HOME/bin:$PATH
export PATH=/opt/rh/rh-python38/root/usr/bin:$PATH
EOF
#python3 -V



echo "--------Python3,PIP,AWSCLI has been installed"
#setup timezone
sudo timedatectl set-timezone America/New_York
echo "--------Timezone has been set"

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

#setup keys for jenkins
sudo usermod -s /bin/bash jenkins
echo jenkins:1234 | sudo chpasswd
sudo usermod -aG wheel jenkins

sudo -i su -c "ssh-keygen -b 2048 -t rsa -f /var/lib/jenkins/.ssh/id_rsa -q -N \"\"" -m "jenkins"
echo "--------Jenkins user ssh keys generated"
sudo cat >> /etc/hosts <<EOF
#jenkins servers - forced since no DNS
10.0.15.12      jenkins
10.0.15.13	jenkins-slave
EOF
echo "--------Added jenkins master/slave to hosts file"




