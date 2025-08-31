#!/bin/bash
# os tested debian 12 -13
# title             :firewall and vnc script
# description       :tigervnc-scraping-server, log in to the actual X session on display :0 and uncompliaced firewall for pia
# date              :2025
# version           :0.6
# notes             :install tigervnc-scraping-server w PIA VPN  ( with firewall on you will be totally blocked without PIA running and local allowed in PIA)
#
FW1="   " #setting var variable
FW2="you have not  FW checked status, so check status"
echo "$FW1" #displaying var variable on terminal
echo "$FW2" #displaying var variable on terminal
VNC1="unknown" #setting var variable
VNC2="not verifyed"
echo "$VNC1" #displaying var variable on terminal
echo "$VNC2" #displaying var variable on terminal
SCRIPTNAME="fWVNC"  # What's the script name
VNCSERVER="/usr/bin/x0vncserver"   #Where the x0vncserver executable is located, default:
HOMEDIR=${HOME}  # Set home directory
INTERFACE=$"192.168.0.120"   # Set home ip
VNCDIR="${HOMEDIR}/.vnc"   # Default VNC User directory
LOGFILE="${VNCDIR}/logfile"   # Set log file for debugging
PASSWDFILE="${VNCDIR}/passwd"   # The vnc passwd file. If it doesn't exist, you need to create it
GEOMETRY="1920x1080"   # What's the Geometry  -Geometry 1280x720
DISPLAY=":0"  # Leave this on ":0", since we want to log in to the actual session
VNCPORT="5900"    #Set the port (default 5900)
# PID of the actual VNC server running
# The PID is actually created this way, so it is compatible with the vncserver command
# if you want to kill the VNC server manually, just type 
# x0vncserver -kill :0
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
echo "vnc" "$VNC1" #displaying var variable on terminal
echo "vnc" "$VNC2" #displaying var variable on terminal

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

  local PS3='Please enter vnc option: 1start 2 restart 3stop 3-status 4-MM 5-q'
  local options=("Start vnc" "restart vnc" "stopvnc" "statusvnc" "mainmenu" "quit")
  local opt
  select opt in "${options[@]}"
  do
      case $opt in
      #
          "Start vnc")
              echo "startvnc"
                            echo -n "Starting VNC Server on display ${DISPLAY} "
              echo "${VNCSERVER} -Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT}"
              sleep 3
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
		VNC2="vnc failed start"
		echo
		fi

        fi

              ;;
#              
          "restart vnc")
              echo "restart vnc"
              echo -n "Restarting VNC Server on display ${DISPLAY} "
              echo "${VNCSERVER} -Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT}"
              sleep 3
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
                VNC1="vnc restarted"
               # exit 0
            else
                echo -e ${FAILED}
                echo "Couldn't stop VNC Server. Exiting."
                
		echo
		VNC1="vnc failed"
		VNC2="vnc fail start"
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
                VNC1="vnc failed"
                VNC2="vnc failed start"
		echo
               # exit 1
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
	    VNC1="vnc stopped"
	    VNC2="vnc killed"
        else
            echo -e ${FAILED}
            echo -e "VNC Server is not running."
            
	    echo
	    VNC1="vnc unkown fail stop"
	    VNC2="vnc fdailed"
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
            VNC1="some vnc running"
            VNC2="vnc running"
	    echo
            #exit 0
        else
            echo -e $NOTRUNNING
            VNC2="vnc not verifyed"
	    echo
        fi
              ;; 
#
             "mainmenu")
              echo "you chose sub item 3"
              mainmenu1
              ;; 
#
          "quit")
              exit
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}

# submenu firewall
firewallmenu () {
   echo "$FW"
   echo "$FW"
  local PS3='Please enter sub option: 1fw-u 2fw-d 3fw-d 4fw-s 5-q'
  local options=("firewall up" "firewalldown" "firewall reset" "firewall disable" "firewall status" "Sub menu quit")
  local opt
  select opt in "${options[@]}"
  do
      case $opt in
#      
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

                break
              ;;
#           
          "firewalldown")
              echo "firewalldown"
              FW1="firewall shutdown"
              sleep 3
              ;;
#         
          "firewall reset")
              echo "firewall reset"
              sleep 3
              sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
FW1="firewall reset to default not great"
FW2="firewall not verifyed"
echo " firewall reset"
echo; read -rsn1 -p "Press any key to continue . . ."
               # break
              ;;
#    
          "firewall status")
              echo "firewall status"
              sleep 3
              sudo ufw status
                echo; read -rsn1 -p "Press any key to continue . . ."
                FW2="firewall status checked"
               # break
              ;;
#             
          "firewall disable")
              echo "firewall disable"
              sleep 3
              sudo ufw disable
                echo; read -rsn1 -p "Press any key to continue . . ."
                FW1="firewall disabled"
                FW2="firewall not verifyed"
               # break
              ;;
#              
             "mainmenu item 3")
              echo "mainmenu"
              sleep 3
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

# main menu
mainmenu1 () {
echo "firewall" "$FW1" #displaying var variable on terminal
echo "firewall" "$FW2" #displaying var variable on terminal
echo "vnc" "$VNC1" #displaying var variable on terminal
echo "vnc" "$VNC2" #displaying var variable on terminal
PS3='Please enter main option: '
echo "1 Main menu 2 VNCmenu 3 firewall menu 4 Main menu 5 quit"
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
