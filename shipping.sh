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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shipping"

cd /app &>> $LOGFILE
VALIDATE $? "changing to app dir"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping  service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "demon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql client"

mysql -h mysql.cloud6.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "loading shipping database"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"