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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment"

cd /app

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping payment"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "demon reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling reload" 

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting payment"




