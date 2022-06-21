#! /bin/bash
sudo apt-get update
sudo apt-get install -y awscli
sudo apt-get install -y default-jdk
sudo apt-get install -y maven
sudo apt-get install -y git
sudo git clone https://github.com/htmldav/boxfuse-sample-java-war-hello.git && cd /home/ubuntu/boxfuse-sample-java-war-hello && mvn --batch-mode --quiet install && aws s3 cp /target/hello-1.0.war s3://test12062022/hello-1.0.war