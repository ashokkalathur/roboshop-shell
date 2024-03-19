#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%T)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R failed $N"
    else
        echo -e "$2...$R success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: please run this script with root access $N"
    exit 1
else
    echo "you are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied MongoDB Repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "enabling mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongoDB"

sed -i 's/127.0.0.0/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to mongoDB"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restarting mongoDB"