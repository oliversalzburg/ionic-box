#!/usr/bin/env bash

ANDROID_SDK_FILENAME=android-sdk_r23.0.2-linux.tgz
ANDROID_SDK=http://dl.google.com/android/$ANDROID_SDK_FILENAME
NODE_FILENAME=node-latest.tar.gz
NODE=http://nodejs.org/dist/$NODE_FILENAME

#sudo apt-get install python-software-properties
#sudo add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install -y git openjdk-7-jdk ant expect build-essential

# Install latest version of Node
if ! hash node 2>&-; then
    echo Installing NodeJS...
    mkdir /tmp/src && cd $_
    wget -N $NODE
    tar xzf $NODE_FILENAME && cd node-v*
    ./configure
    make && sudo make install
    cd
fi

echo Installing Android SDK...
curl -O $ANDROID_SDK
tar -xzvf $ANDROID_SDK_FILENAME
sudo chown -R vagrant android-sdk-linux/

echo "ANDROID_HOME=~/android-sdk-linux" >> /home/vagrant/.bashrc
echo "PATH=\$PATH:~/android-sdk-linux/tools:~/android-sdk-linux/platform-tools" >> /home/vagrant/.bashrc

echo Installing Ionic Framework...
npm install -g cordova
npm install -g ionic

echo Updating Android SDK...
expect -c '
set timeout -1   ;
spawn /home/vagrant/android-sdk-linux/tools/android update sdk -u --all --filter platform-tool,android-19,build-tools-19.1.0
expect { 
    "Do you accept the license" { exp_send "y\r" ; exp_continue }
    eof
}
'

sudo /home/vagrant/android-sdk-linux/platform-tools/adb kill-server
sudo /home/vagrant/android-sdk-linux/platform-tools/adb start-server
sudo /home/vagrant/android-sdk-linux/platform-tools/adb devices

echo Done.
