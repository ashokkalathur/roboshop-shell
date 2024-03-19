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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling default nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enableing nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing NodeJs:18" 

useradd roboshop &>> $LOGFILE

VALIDATE $? "creating roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue application"

cd /app 
unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

#use obsolute path
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue.service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalouge demon reload"

systemctl enable catalogue &>> $LOGFILE
systemctl start catalogue &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading data into mongoDB"