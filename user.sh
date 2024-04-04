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

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user application"

cd /app 
unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboroboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "copying user.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user demon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? "loading user data into MongoDB"
