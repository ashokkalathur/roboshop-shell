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

dnf module disable nodejs -y

VALIDATE $? "disabling default nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "enableing nodejs:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "installing NodeJs:18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catalogue application" &>> $LOGFILE

cd /app 
unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install

VALIDATE $? "installing dependencies" &>> $LOGFILE

#use obsolute path
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogue.service file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "catalouge demon reload" &>> $LOGFILE

systemctl enable catalogue
systemctl start catalogue

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "loading data into mongoDB" &>> $LOGFILE