#! /bin/bash
sudo apt-get update
sudo apt-get install -y python3-pip
sudo pip install boto3
sudo pip install botocore
sudo apt-get install -y awscli
sudo apt-get install -y default-jdk
sudo apt-get install -y maven
sudo apt-get install -y git
sudo mkdir -p /home/ubuntu/dir1806
# git clone https://github.com/htmldav/boxfuse-sample-java-war-hello.git
# cd boxfuse-sample-java-war-hello/
# mvn --batch-mode --quiet install
# cd target/
# aws s3 cp hello-1.0.war s3://test12062022/hello-1.0.war