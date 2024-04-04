#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%T)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

MONGODB_HOST=mongodb.cloud6.online

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R failed $N"
        exit 1
    else
        echo -e "$2...$G success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: please run this script with root access $N"
    exit 1
else
    echo "you are root user"
fi

dnf install nginx -y
VALIDATE $? "installing Nginx"

systemctl enable nginx
VALIDATE $? "enabling Nginx"

systemctl start nginx
VALIDATE $? "starting Nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removed default html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "downloaded web application"

cd /usr/share/nginx/html
VALIDATE $? "moving to nginx html directory"

unzip -o /tmp/web.zip
VALIDATE $? "unziping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "copied roboshop reverse proxy config'

systemctl restart nginx
VALIDATE $? "restarted Nginx"




