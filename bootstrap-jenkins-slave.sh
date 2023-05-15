#!/bin/bash
set -e
# TODO - put all of this in a proper CM tool like ansible... ugh :(
# install jenkins
sudo yum update -y
sudo yum -y install curl
#sudo yum -y install java-1.8.0-openjdk
sudo yum -y install java-11-openjdk
echo "--------Java installed"
# some useful tools
sudo yum -y install wget telnet bind-utils nano git net-tools 
echo "--------Utilities installed"
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

export JAVA_HOME=/usr/lib/jvm/jre
export PATH=$JAVA_HOME/bin:$PATH
export PATH=/opt/rh/rh-python38/root/usr/bin:$PATH

echo "--------Python3,PIP,AWSCLI has been installed"
#setup timezone
sudo timedatectl set-timezone America/New_York
echo "--------Timezone has been set"

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

#slave setup...
sudo useradd --system -U -d /var/lib/jenkins -m -s /bin/bash jenkins
echo jenkins:1234 | sudo chpasswd
sudo usermod -aG wheel jenkins

sudo install -d -m 700 -o jenkins -g jenkins /var/lib/jenkins/.ssh
sudo touch /var/lib/jenkins/.ssh/authorized_keys
sudo chown jenkins.jenkins /var/lib/jenkins/.ssh/authorized_keys -R
sudo chmod 600 /var/lib/jenkins/.ssh/authorized_keys -R
echo "--------Jenkins slave user created and prepped for manual key entry from master"
echo "--------TODO: make sure you import keys from master into slave's authorized_keys file"
echo "--------TODO: /var/lib/jenkins-slave/.ssh/authorized_keys"
sudo cat >> /etc/hosts <<EOF
#jenkins servers - forced since no DNS
10.0.15.12      jenkins
10.0.15.13	jenkins-slave
EOF
echo "--------Added jenkins master/slave to hosts file"
# copy the id_rsa.pub from jenkins master to jenkins slave authorized keys (do manually for now)
#vi /var/lib/jenkins-slave/.ssh/authorized_keys
#   copy jenkinsmasterhost:/var/lib/jenkins/ssh/id_rsa.pub


