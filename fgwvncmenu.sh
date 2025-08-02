#!/bin/bash
# title             :startvnc
# description       :This script was written for the debian package tigervnc-scraping-server, in order to log in to the actual X session on display :0 and to sew the firewall
# date              :2025
# version           :0.1
# usage             :bash startvnc
# notes             :install tigervnc-scraping-server (debian stretch)
# What's the script name
FW1="   " #setting var variable
FW2="you have not  FW checked status, so check status"
echo "$Fw1" #displaying var variable on terminal
echo "$Fw2" #displaying var variable on terminal
VNC1="unknown" #setting var variable
VNC2="no idea"
echo "$VNC1" #displaying var variable on terminal
echo "$VNC2" #displaying var variable on terminal


SCRIPTNAME="startvnc"

# Where the x0vncserver executable is located, default:
VNCSERVER="/usr/bin/x0vncserver"

# Set home directory
HOMEDIR=${HOME}

# Set home ip
INTERFACE=$"192.168.0.120"

# Default VNC User directory
VNCDIR="${HOMEDIR}/.vnc"

# Set log file for debugging
LOGFILE="${VNCDIR}/logfile"

# The vnc passwd file. If it doesn't exist, you need to create it
PASSWDFILE="${VNCDIR}/passwd"

# What's the Geometry  -Geometry 1280x720
GEOMETRY="1920x1080"

# Leave this on ":0", since we want to log in to the actual session
DISPLAY=":0"

# Set the port (default 5900)
VNCPORT="5900"

# PID of the actual VNC server running
# The PID is actually created this way, so it is compatible with the vncserver command
# if you want to kill the VNC server manually, just type 
# vncserver -kill :0
PIDFILE="${VNCDIR}/${HOSTNAME}${DISPLAY}.pid"

# Add some color to the script
OK="[\033[1;32mok\033[0m]"
FAILED="[\033[1;31mfailed\033[0m]"
RUNNING="[\033[1;32mrunning\033[0m]"
NOTRUNNING="[\033[1;31mnot running\033[0m]"

# Function to get the process id of the VNC Server
fn_pid() {
    CHECKPID=$(ps -fu ${USER} | grep "[x]0vncserver" | awk '{print $2}')
    if [[ ${CHECKPID} =~ ^[0-9]+$ ]] 
    then
        VAR=${CHECKPID}
        return 0
    else
        return 1
    fi
}



# vncmenu
vncmenu () {
echo "$VNC1" #displaying var variable on terminal
echo "$VNC2" #displaying var variable on terminal

if [ ! -d ${VNCDIR} ]
then
    echo -e "Directory ${VNCDIR} doesn't exist. Create it first." ${FAILED}
    echo
    exit 1
fi

if [ ! -f ${PASSWDFILE} ]
then
    echo -e "${PASSWDFILE} doesn't exist. Create VNC password first. ${FAILED}"
    echo "Type \"vncpasswd\" to create passwd file."
    echo
    exit 1
fi

  local PS3='Please enter vnc option: '
  local options=("Start vnc" "restart vnc" "stopvnc" "statusvnc" "Sub menu quit")
  local opt
  select opt in "${options[@]}"
  do
      case $opt in
          "Start vnc")
              echo "startvnc"
              sleep 3
              echo -n "Starting VNC Server on display ${DISPLAY} "
        fn_pid
        if [ $? -eq 0 ]
        then
            echo -e ${FAILED}
            echo -e "VNC Server is running (pid: ${VAR})"
	    echo
        else
            ${VNCSERVER} -Geometry ${GEOMETRY} -localhost=0 -interface 192.168.0.130 -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT} >> ${LOGFILE} 2>&1 &
	    if [ $? -eq 0 ]
	    then
            	fn_pid
            	echo ${VAR} > ${PIDFILE}
            	VNC1="vnc running"
            	echo -e ${OK}
	    	echo
	else
		echo -e $FAILED
		echo
		fi

        fi

              ;;
          "restart vnc")
              echo "restart vnc"
              sleep 3
              echo -n "Restarting VNC Server on display ${DISPLAY} "
        fn_pid
        if [ $? -eq 0 ]
        then
            kill -9 ${VAR}

            if [ $? -eq 0 ]
            then 
                ${VNCSERVER} -Geometry ${GEOMETRY} -localhost=0 -interface 192.168.0.130 -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT} >> ${LOGFILE} 2>&1 &
                echo -e ${OK}
		echo
                fn_pid 
                echo ${VAR} > ${PIDFILE}
               # exit 0
            else
                echo -e ${FAILED}
                echo "Couldn't stop VNC Server. Exiting."
		echo
               # exit 1
            fi

        else

            ${VNCSERVER} -Geometry ${GEOMETRY} -localhost=0 -interface 192.168.0.130 -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT} >> ${LOGFILE} 2>&1 &
            if [ $? -eq 0 ]
            then
                echo -e ${OK}
		echo
                fn_pid
                echo ${VAR} > ${PIDFILE}
            else
                echo -e ${FAILED}
                echo "Couldn't start VNC Server. Exiting."
		echo
                exit 1
            fi
        fi
              ;;
              #
              "stopvnc")
              echo "stopvnc"
              sleep 3
              echo -n "Stopping VNC Server: "
        fn_pid
        if [ $? -eq 0 ]
        then
        x0vncserver -kill :0
            kill -9 ${VAR}
            echo -ne ${OK}
            echo -e " (pid: ${VAR})"
	    echo
        else
            echo -e ${FAILED}
            echo -e "VNC Server is not running."
	    echo
            #exit 1
        fi
              ;; 
              #
              "statusvnc")
              echo "status vnc"
              sleep 3
              echo -n "Status of the VNC server: "
        fn_pid
        if [ $? -eq 0 ]
        then
            echo -e "$RUNNING (pid: $VAR)"
	    echo
            #exit 0
        else
            echo -e $NOTRUNNING
	    echo
        fi
              ;; 
              #
             "mainmenu item 3")
              echo "you chose sub item 3"
              mainmenu1
              ;; 
              #
          "Sub menu quit")
              exit
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}

# submenu firewall
firewallmenu () {
   echo "$var"
    echo "$var2"
  local PS3='Please enter sub option: '
  local options=("firewall up" "firewalldown" "firewall reset" "firewall disable" "Sub menu quit")
  local opt
  select opt in "${options[@]}"
  do
      case $opt in
          "firewall up")
              echo "firewall up1"
              sleep 3
              sudo ufw --force reset
#sudo ufw allow out on tun0 from any to any  pia is seperate
#
echo "deny all in-out"
sudo ufw default deny incoming
sudo ufw default deny outgoing
#ssh
echo "ssh in"
sudo ufw allow from 192.168.0.0/24 to any port 22
sudo ufw allow from 192.168.2.0/24 to any port 22
sudo ufw allow from 192.168.1.0/24 to any port 22
#vnc
echo "vnc in"
sudo ufw allow from 192.168.0.0/24 to any port 5900
sudo ufw allow from 192.168.2.0/24 to any port 5900
sudo ufw allow from 192.168.0.0/24 to any port 5901
sudo ufw allow from 192.168.2.0/24 to any port 5901
sudo ufw allow from 192.168.1.0/24 to any port 5900
sudo ufw allow from 192.168.1.0/24 to any port 5901

#radicale  http://dlcdnet.asus.com/pub/ASUS/LiveUpdate/Release/Wireless/Discovery.zip
echo "radicale in"
sudo ufw allow from 192.168.0.0/24 to any port 5232 
sudo ufw allow from 192.168.1.0/24 to any port 5232
#radicle
#sudo ufw allow from 192.168.0.0/24 to any port 5232
#sudo ufw allow from 192.168.2.0/24 to any port 5232
#webdav
echo "webdav in"
sudo ufw allow from 192.168.0.0/24 to any port 8585
sudo ufw allow from 192.168.1.0/24 to any port 8585
#qbit
echo "qbit in"
sudo ufw allow from 192.168.0.0/24 to any port 8080
sudo ufw allow from 192.168.1.0/24 to any port 8080
#
echo "dns in"
sudo ufw allow dns
#
#tun0
echo "tun0"
sudo ufw allow out on tun0 from any to any

echo "turning it all on"
sudo ufw enable
FW1="firewall on pirate ready"
echo; read -rsn1 -p "Press any key to continue . . ."
######################################
                break
              ;;
              
          "firewalldown")
              echo "firewalldown"
              sleep 3
              ;;
          "firewall reset")
              echo "firewall reset"
              sleep 3
              sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
FW1="firewall reset to default"
echo " firewall reset"
echo; read -rsn1 -p "Press any key to continue . . ."
#############################################
                break
              ;;
          "firewall status")
              echo "firewall status"
              sleep 3
              sudo ufw status
                echo; read -rsn1 -p "Press any key to continue . . ."
                FW2="firewall status checked"
                break
              ;;
          "firewall disable")
              echo "firewall disable"
              sleep 3
              sudo ufw disable
                echo; read -rsn1 -p "Press any key to continue . . ."
                FW1="firewall disabled"
                break
              ;;
             "mainmenu item 3")
              echo "mainmenu"
              sleep 3
              mainmenu1
              ;; 
          "Sub menu quit")
              exit
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}

# main menu
mainmenu1 () {
PS3='Please enter main option: '
options=("Main menu" "VNCmenu" "firewall menu" "Main menu quit")
select opt in "${options[@]}"
do
    case $opt in
        "Main menu")
            echo "you chose main item 1"
            ;;
        "VNCmenu")
            vncmenu
            ;;
        "firewall menu")
            firewallmenu
            ;;
        "Main menu quit")
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

mainmenu1
