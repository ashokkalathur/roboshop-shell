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

mkdir /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
version $? "downloading shipping"

cd /app &>> $LOGFILE
version $? "changing to app dir"

unzip -o /tmp/shipping.zip &>> $LOGFILE
version $? "unzipping shipping"

mvn clean package &>> $LOGFILE
version $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
version $? "renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
version $? "copying shipping  service"

systemctl daemon-reload &>> $LOGFILE
version $? "demon reload"

systemctl enable shipping &>> $LOGFILE
version $? "enable shipping"

systemctl start shipping &>> $LOGFILE
version $? "start shipping"

dnf install mysql -y &>> $LOGFILE
version $? "installing mysql client"

mysql -h mysql.cloud6.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
version $? "loading shipping database"

systemctl restart shipping &>> $LOGFILE
version $? "restarting shipping"