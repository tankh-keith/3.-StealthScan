#!/bin/bash

# WELCOME TO STEALTHSCAN™ BY KEITH TAN

echo "WELCOME TO STEALTHSCAN™ BY KEITH TAN"
echo "Ensure machine is fully updated, by running the following Commands (before running this script):"
echo "sudo apt-get update"
echo "sudo apt-get upgrade"
echo "sudo apt-get dist-upgrade"
echo "Starting the script in 3 seconds..."
sleep 3
echo


# 1. INSTALLATIONS & ANONYMITY CHECK:
# 1. i)  Install the Needed Applications:
# 1. ii) If the Apps are Already Installed, don't Install Again:


# store installation code into parent function:
function install_tools() { 
	
	# installing geoipbin (for geoiplookup):
	function install_geoipbin() { 
		if ! command -v geoiplookup &> /dev/null
		then
			echo "[!] geoip-bin is not installed. Installing geoip-bin now..."
			echo "$(date) [!] geoip-bin is not installed. Installing geoip-bin now..." >> /home/kali/stealthscan.log
			if sudo apt-get install -y geoip-bin; then
				echo "[#] geoip-bin is successfully installed."
				echo "$(date) [#] geoip-bin is successfully installed." >> /home/kali/stealthscan.log
			else
				echo "[!] Failed to install geoip-bin."
				echo "$(date) [!] Failed to install geoip-bin." >> /home/kali/stealthscan.log
			fi
		else
			echo "[#] geoip-bin is already installed."
			echo "$(date) [#] geoip-bin is already installed." >> /home/kali/stealthscan.log
		fi
	}
	install_geoipbin
	
	# installing tor (to go anonymous with nipe):
	function install_tor() {
		if ! command -v tor &> /dev/null
		then
			echo "[!] tor is not installed. Installing tor now..."
			echo "$(date) [!] tor is not installed. Installing tor now..." >> /home/kali/stealthscan.log
			if sudo apt-get install -y tor > /dev/null; then
				echo "[#] tor is successfully installed."
				echo "$(date) [#] tor is successfully installed." >> /home/kali/stealthscan.log
			else
				echo "[Error] Failed to install tor."
				echo "$(date) [Error] Failed to install tor." >> /home/kali/stealthscan.log
			fi
		else
			echo "[#] tor is already installed."
			echo "$(date) [#] tor is already installed." >> /home/kali/stealthscan.log
		fi
	}
	install_tor

	# installing sshpass (to automate ssh into remote server):
	function install_sshpass() {
		if ! command -v sshpass &> /dev/null
		then
			echo "[!] sshpass is not installed. Installing sshpass now..."
			echo "$(date) [!] sshpass is not installed. Installing sshpass now..." >> /home/kali/stealthscan.log
			if sudo apt-get install -y sshpass > /dev/null; then
				echo "[#] sshpass is successfully installed."
				echo "$(date) [#] sshpass is successfully installed." >> /home/kali/stealthscan.log
			else
				echo "[Error] Failed to install sshpass."
				echo "$(date) [Error] Failed to install sshpass." >> /home/kali/stealthscan.log
			fi
		else
			echo "[#] sshpass is already installed."
			echo "$(date) [#] sshpass is already installed." >> /home/kali/stealthscan.log
		fi
	}
	install_sshpass

	# installing Nipe (to make Tor the default gateway and go anonymous):
	function install_nipe() {
		# checking if Nipe is already installed:
		if [ ! -f "nipe/nipe.pl" ] # checks if file 'nipe.pl' DOES NOT (!) exist within directory 'nipe'. If so, then ...
		then # ... then install Nipe
			echo "[!] Nipe is not installed. Installing Nipe now..."
			echo "$(date) [!] Nipe is not installed. Installing Nipe now..." >> /home/kali/stealthscan.log
			cd /home/kali  # navigate to /home/kali 
			if [ -d "nipe" ] # checks if the directory called 'nipe' exists. If yes, then ...
			then # ... then remove the existing 'nipe' directory
				echo "Removing existing 'nipe' repository..."
				echo "$(date) Removing existing 'nipe' repository..." >> /home/kali/stealthscan.log
				rm -rf nipe # force (-rf) removes the existing directory 'nipe' and all inner contents (all dir & files)
			fi
			# installing Nipe:
			git clone https://github.com/htrgouvea/nipe -q  # clones all files into newly-created "nipe" folder, cd into it
			cd nipe
			cpanm --installdeps . > /dev/null  # install dependencies for nipe, suppress output
			sudo cpan install Switch JSON LWP::UserAgent Config::Simple  # install additional dependencies for nipe
			sudo perl nipe.pl install -y > /dev/null  # install nipe: '-y' auto-answers "yes"; '> /dev/null' suppress outputs
			echo "[#] Nipe is successfully installed."
			echo "$(date) [#] Nipe is successfully installed." >> /home/kali/stealthscan.log
		else
			echo "[#] Nipe is already installed."
			echo "$(date) [#] Nipe is already installed." >> /home/kali/stealthscan.log
		fi
	}
	install_nipe
}
install_tools

	
	
# 1. iii)  Check if Network Connection is Anonymous. If Not, Alert the User and Exit:
echo
function go_anonymous() {
	cd /home/kali/nipe
	sudo perl nipe.pl start # start the nipe service to use TOR and exit local network using another router
	nipe_status=$(sudo perl nipe.pl status)
	if echo "$nipe_status" | grep -q "ERROR"; then
		echo "[Error] An error occurred with Nipe service, you are not anonymous, restarting Nipe service."
		echo "$(date) [Error] An error occurred with Nipe service, you are not anonymous, restarting Nipe service." >> /home/kali/stealthscan.log
		sudo perl nipe.pl restart
		if echo "$nipe_status" | grep -q "ERROR"; then
			echo "[Error] Unable to connect to Nipe. Please check that Nipe is running, before re-running this script."
			echo "$(date) [Error] Unable to connect to Nipe. Please check that Nipe is running, before re-running this script." >> /home/kali/stealthscan.log
			exit 1
		fi
    elif echo "$nipe_status" | grep -q "false"; then
		echo "[Error] Nipe service status is 'false', you are not anonymous, restarting Nipe service."
		echo "$(date) [Error] Nipe service status is 'false', you are not anonymous, restarting Nipe service." >> /home/kali/stealthscan.log
		sudo perl nipe.pl restart
		if echo "$nipe_status" | grep -q "ERROR"; then
			echo "[Error] Unable to connect to Nipe. Please check that Nipe is running, before re-running this script."
			echo "$(date) [Error] Unable to connect to Nipe. Please check that Nipe is running, before re-running this script." >> /home/kali/stealthscan.log
			exit 1
		fi
# 1. iv)  If Network Connection is Anonymous, display the Spoofed Country Name:
    elif echo "$nipe_status" | grep -q "true"; then
		anon_ip=$(sudo perl nipe.pl status | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}')
		spoofed_cty=$(geoiplookup $anon_ip | awk -F: '{print $2}')
		if [ -z "$spoofed_cty" ]; then # If spoofed_cty is empty, execute whois command
            spoofed_cty=$(whois -I $anon_ip | grep -i cty)
        fi
		echo "[*] You have successfully gone anonymous (powered by Nipe):"
		echo "$(date) [*] You have successfully gone anonymous (powered by Nipe):" >> /home/kali/stealthscan.log
		echo "[*] Your Spoofed IP Address: $anon_ip"
		echo "$(date) [*] Your Spoofed IP Address: $anon_ip" >> /home/kali/stealthscan.log
		echo "[*] Your Spoofed Country: $(geoiplookup $anon_ip | awk -F, '{print $2}')"
		echo "$(date) [*] Your Spoofed Country: $(geoiplookup $anon_ip | awk -F, '{print $2}')" >> /home/kali/stealthscan.log
	fi
}
go_anonymous

	

# 1. v)  Alert User to Specify Target Domain/IP Address (to whois from Remote Server) - Save result into a Variable:
echo
echo -n "[?] Specify your target Domain/IP Address to scan: " # ask user to input target Domain/IP Address (-n stops new lines)
read -r victim_input # save user input to new variable victim_input (-r treats '\' as literal character)
victim_ip="" # define new variable in global scope for use in the function called connect_remoteserver
ipv4_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

if [[ $victim_input =~ $ipv4_pattern ]]; then # if user keyed in an IP Address, then...
    victim_ip="$victim_input" # ... save this IP Address to new variable victim_ip
    echo "[*] You entered Target IP address of $victim_ip"
    echo "$(date) [?] You specified target of $victim_ip" >> /home/kali/stealthscan.log
else # else, the victim keyed in a Domain Name
	# nslookup to get the Domain Name's IP Address, save it to new variable victim_ip:
    victim_ip=$(nslookup "$victim_input" | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n1) 
    if [ ! -z "$victim_ip" ]; then # if the user input is not empty, then...
        echo "(The IP Address of $victim_input is $victim_ip)" # inform user of their inputs
        echo "$(date) [?] You specified target of $victim_ip" >> /home/kali/stealthscan.log
    else
		# error-handling: inform user of failed retrieval, guide user with suggestions:
        echo "[Error] Failed to get IP addr for specified Domain. Check typos/specify IP Address." 
        echo "$(date) [Error] Failed to get IP addr for specified Domain. Check typos/specify IP Address." >> /home/kali/stealthscan.log
    fi
fi
echo


# 2 Automatically Scan the Remote Server for Open Ports:
# Remote Server Details:
remote_user="kali"
remote_ip="172.16.156.129"
remote_pw="kali"

# 3. i) Save the Whois and Nmap data on the Remote Computer:
# SSH into the remote server and execute 
# perform 'whois' scan, save the scan output into whoisVictim.txt
# perform 'nmap' scan, save the scan output into nmapVictim.txt
echo "[*] Connecting to Remote Server:"
sshpass -p "$remote_pw" ssh "$remote_user"@"$remote_ip" "bash -s" << EOF
   echo "Uptime: $(uptime)"
   echo "IP Address (Remote Server): $remote_ip"
   echo "Country: Singapore"
   
   touch remotescan.log

   echo "[*] Whois-ing victim's address:"
   echo "$(date) [*] Whois-ing victim's address" >> remotescan.log
   whois $victim_ip > whoisVictim.txt
   echo "$(date) [*] Finished Whois-ing victim's address" >> remotescan.log

   echo "[*] Scanning victim's address:"
   echo "$(date) [*] Scanning victim's address" >> remotescan.log
   nmap $victim_ip > nmapVictim.txt
   echo "$(date) [*] Finished scanning victim's address" >> remotescan.log

EOF
echo



# Transferring and combining log from remote server remotescan.log, with stealthscan.log on local machine:
wget -q --ftp-user="$remote_user" --ftp-password="$remote_pw" "ftp://$remote_ip/remotescan.log" -O "/home/kali/remotescan.log"
cat /home/kali/remotescan.log >> /home/kali/stealthscan.log



# 3. ii) Download and transfer the File from Remote Computer to Local Machine via FTP (using wget command):
# transferring whoisVictim.txt to local machine at ~/whoisVictim.txt :
wget -q --ftp-user="$remote_user" --ftp-password="$remote_pw" "ftp://$remote_ip/whoisVictim.txt" -O "/home/kali/whoisVictim.txt"
echo "[@] Whois data was saved into /home/kali/whoisVictim.txt"
echo "$(date) [@] Whois data was saved into /home/kali/whoisVictim.txt" >> /home/kali/stealthscan.log
# transferring nmapVictim.txt to local machine at ~/nmapVictim.txt :
wget -q --ftp-user="$remote_user" --ftp-password="$remote_pw" "ftp://$remote_ip/nmapVictim.txt" -O "/home/kali/nmapVictim.txt"
echo "[@] Nmap scan was saved into /home/kali/nmapVictim.txt"
echo "$(date) [@] Nmap scan was saved into /home/kali/nmapVictim.txt" >> /home/kali/stealthscan.log
echo

# 3. iii) & iv) stealthscan.log is saved to local machine and outputs are printed to the terminal:
echo "[*] Displaying Your STEALTHSCAN™ Event Log:"
cat /home/kali/stealthscan.log
