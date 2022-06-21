#! /bin/bash
sudo apt-get update
sudo apt-get install -y awscli
sudo apt-get install -y default-jdk
sudo apt-get install -y tomcat9
aws s3 cp s3://test12062022/hello-1.0.war /var/lib/tomcat9/webapps
aws s3 rm s3://test12062022/hello-1.0.war