#!/bin/bash

Threahold_Mem=80
Threahold_CPU=50
Threahold_Disk=80

isHeathCheckGood=true

mem_value=$(free | grep Mem | awk '{print int($3/$2*100)}')
echo $mem_value
if((mem_value > Threahold_Mem)); then
	echo 'Memory is running beyond your threshold'
	isHeathCheckGood=false
fi

cpu_value=$(top -n1 | grep 'Cpu' | awk '{print int($2)}')
echo $cpu_value
if((cpu_value > Threahold_CPU)); then
	echo 'CPU is running beyond your threshold'
	isHeathCheckGood=false
fi	

disk_value=$(df / | tail -1 | awk '{gsub("%",""); print $5}')
echo $disk_value
if((disk_value > Threahold_Disk)); then
	echo 'Disk is running beyond your threshold'
	isHeathCheckGood=false
fi

if($isHeathCheckGood); then
    echo "The automated tests can run now as the health check is positive"
else
	echo "Restarting the AWS Instance"
	aws ec2 reboot-instances --instance-ids i-0d7c2d3b0e61562cb
fi

#!/bin/bash

# Function to check if given command exist !!
is_Command_Exist() {
    local arg="$1"
    type "$arg" &> /dev/null
    if [ $? -eq 0 ]; then
        return 0
    else
        dpkg -l | grep "$arg"
        return $?
    fi
}
# Install Function
install_package(){
    local arg="$1"
    sudo apt install "$arg"
}

# Check Java exist or not?
if is_Command_Exist "java"; then
    echo "Java is installed in this ubuntu"
else
    echo "Java is not installed"
    install_package "openjdk-8-jdk";
fi

# Check Maven exist or not?
if is_Command_Exist "mvn"; then
    echo "Maven is installed in this ubuntu"
else
    echo "mvn is not installed"
    install_package "mvn";
fi

# Check XVFB exist or not?
if is_Command_Exist "xvfb"; then
    echo "xvfb is installed"
else
    echo "xvfb is not installed"
    sudo apt install xvfb
fi

# Check Chrome exist or not?
if is_Command_Exist "chrome"; then
    echo "chrome is installed"
else
    echo "xcfb is not installed"
    wget http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.198-1_amd64.deb
    sudo dpkg -i google-chrome-stable_114.0.5735.198-1_amd64.deb
fi

mvn clean test 
aws s3 sync reports/ s3://reports-ubuntu-devops

