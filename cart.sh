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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloading cart application"

cd /app 
unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

#use obsolute path
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "copying cart.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "cart demon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart"