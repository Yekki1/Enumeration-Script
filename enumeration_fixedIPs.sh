#!/bin/bash                                                                                                                                               
                                                                                                                                                          
#This script can be run agaisnt a range of IPs to run a whole heap of enumeration.                                                                        
#This has been created by Yekki(@yekki_1) for the purpose of assisting with background enumeration.                                                       
#Useful for any time you have other things to do and a time limit. Like a certain exam.
#Timestamps are added to each screen output, to track how long it's taking
                                                                                                                                                          
#Usage Create a text file called "AvailableIPs.txt" in the same folder as the script
#Run: ./enumeration.sh                                                                                                                                                                                                                                                                          
                                                                                                                                                          
#The script goes through and creates folder structures for each IP which is up.                                                                           
#A full port nmap is run agaisnt the target                                                                                                               
#A -sC (all scripts) nmap is run agaisnt open ports on a target                                                                                           
#A vuln script nmap is run agaisnt all ports on a target                                                                                                  
#A UDP top 200 nmap is run agaisnt the target                                                                                                             
#If HTTP(s) is found, gobuster and nikto are run agaisnt the targets                                                                                      
#Nikto is run agaisnt all webservers                                                                                                               
#SMB is looked for on all targets & folder is created but no enumeration is done. 
                                                                                                           
                                                                                                                                                          
#Requirements - Wordlist needed at: /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt                                                          
#             - Nikto installed                                                                                                                           
#             - nmap installed                                                                                                                            
#             - smbmap installed                                                                                                                          
#             - Enum4Linux installed                                                                                                                      
# Bascially just use kali!                                                                                                                                
                                                                                                                                                          
                                                                                                                                                          
#Variables                                                                                                                                                
startip=$1                                                                                                                                                
endip=$2                                                                                                                                                  
                                                                                                                                                          
#Functions                                                                                                                                                
#check()                                                                                                                                                  
#{                                                                                                                                                        
#       if [[ $startip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ $endip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];                                                                                                                                                                                                   
#               then                                                                                                                                                                                                                                                                                                 
#                       return 0                                                                                                                          
#               else                                                                                                                                      
#                       echo  "Not a valid IP: Usage ./enumeration.sh <startip> <endip>"                                                                                                                                                                                                                             
#                       exit 1                                                                                                                                                                                                                                                                                       
#       fi                                                                                                                                                
#}                                                                                                                                                        
                                                                                                                                                          
#initial_nmap()                                                                                                                                           
#{                                                                                                                                                        
#endingip=`echo $endip | cut -d "." -f4`                                                                                                                  
#               nmap -sP -oG $startip-$endingip $startip-$endingip > /dev/null 2>&1                                                                       
#               return 0                                                                                                                                  
#}                                                                                                                                                        
create_folders()                                                                                                                                          
{                                                                                                                                                         
#       awk '/Up/ {print $2}' $startip-$endingip > AvailableIPs.txt                                                                                                                                                                                                                                                  
                for i in $( cat AvailableIPs.txt ); do                                                                                                    
                        mkdir -p $i/nmap                                                                                                                  
        done                                                                                                                                                                                                                                                                                                         
        return 0                                                                                                                                                                                                                                                                                                     
}                                                                                                                                                         
full_port_nmap()                                                                                                                                          
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt ); do                                                                                                            
                nmap -sS -p- -oG $i/nmap/allports $i > /dev/null 2>&1                                                                                     
                echo $(date +%k:%M) " - Full port scan on $i complete"                                                                                    
        done                                                                                                                                              
        return 0                                                                                                                                          
}                                                                                                                                                                                                                                                                                                                    
full_nmap()                                                                                                                                                                                                                                                                                                          
{                                                                                                                                                                                                                                                                                                                    
        for i in $( cat AvailableIPs.txt ); do                                                                                                            
        sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/open/ {print $1}' | sed -z 's/\n/,/g' > $i/nmap/nmapports.txt                                                                                                                                                                                               
                nmap -sC -sV -O -oN $i/nmap/fullscan $i -p "$(cat $i/nmap/nmapports.txt)" > /dev/null 2>&1                                                                                                                                                                                                           
                nmap -sV --script=vuln -oN $i/nmap/vulnscan $i -p "$(cat $i/nmap/nmapports.txt)" > /dev/null 2>&1                                                                                                                                                                                                    
                echo $(date +%k:%M) " - Full scripts scan on $i complete"                                                                                 
        rm $i/nmap/nmapports.txt                                                                                                                          
        done                                                                                                                                              
        return 0                                                                                                                                          
}                                                                                                                                                         
udp_nmap()                                                                                                                                                
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                nmap -sU -n --top-ports=200 -oN $i/nmap/UDPScan $i > /dev/null 2>&1                                                                       
                echo $(date +%k:%M) " - UDP scan on $i complete"                                                                                          
        done                                                                                                                                              
        return 0                                                                                                                                          
}                                                                                                                                                         
create_webserver_folder()                                                                                                                                 
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                for j in $(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/http|https/ {print $1}'); do                                                                                                                                                                                                             
                        if [ -d $i/webservers ];then                                                                                                      
                                return 0                                                                                                                  
                                else                                                                                                                      
                                mkdir $i/webservers                                                                                                       
                        fi                                                                                                                                
                done                                                                                                                                      
        done                                                                                                                                              
        return 0                                                                                                                                          
}                                                                                                                                                         
check_webservers()                                                                                                                                        
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                        if [ -d $i/webservers ]; then                                                                                                     
                                echo "Webservers found"                                                                                                   
                                return 0                                                                                                                  
                        else                                                                                                                              
                                echo "No Webservers found. Exiting"                                                                                       
                                create_smb_folder                                                                                                         
                        fi                                                                                                                                
        done                                                                                                                                              
}                                                                                                                                                         
gobuster_http()                                                                                                                                           
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                for j in $(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/http/ {print $1}'); do                                                        
                        if [ $j  == 80 ]                                                                                                                  
                                then                                                                                                                      
                                sudo gobuster dir -u $i:$j -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e .php,.txt,.html,.htm,.bak -t 50 -o $i/webservers/gobuster-$j > /dev/null 2>&1                                                                                                          
                                echo $(date +%k:%M) " - HTTP gobuster on $i complete"                                                                     
                                else                                                                                                                      
                                protocol=$(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/http/ {print $5}' | sort -u | tr -d '\n')                                                                                                                                                                                
                                sudo gobuster dir -u $i:$j -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e .php,.txt,.html,.htm,.bak -t 50 -o $i/webserver/gobuster-$j > /dev/null 2>&1                                                                                                           
                                echo $(date +%k:%M) " - HTTP gobuster on $i complete"                                                                     
                        fi                                                                                                                                
                done                                                                                                                                      
        done                                                                                                                                              
} 
gobuster_https()                                                                                                                                          
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                for j in $(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/https/ {print $1}'); do                                                       
                        if [ $j == 443 ]                                                                                                                  
                                then                                                                                                                      
                                sudo gobuster dir -u $i:$j -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e .php,.txt,.html,.htm,.bak -t 50 -o $i/webservers/gobuster-$j > /dev/null 2>&1                                                                                                          
                                echo $(date +%k:%M) " - HTTPs gobuster on $i complete"                                                                    
                                else                                                                                                                      
                                protocol=$(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/https/ {print $5}' | sort -u | tr -d '\n')                                                                                                                                                                               
                                sudo gobuster dir -u $protocol://$i:$j -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e .php,.txt,.html,.htm,.bak -t 50 -o $i/webservers/gobuster-$j > /dev/null 2>&1                                                                                              
                                echo $(date +%k:%M) " - HTTPs gobuster on $i complete"                                                                    
                        fi                                                                                                                                
                done                                                                                                                                      
        done                                                                                                                                              
}                                                                                                                                                         
nikto()                                                                                                                                                   
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                for j in $(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/http|https/ {print $1}'); do                                                                                                                                                                                                             
                                protocol=$(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/https/ {print $5}' | sort -u | tr -d '\n')                                                                                                                                                                               
                                nikto -url $protocol://$i:$j -output $i/webservers/nikto-$j.txt > /dev/null 2>&1                                                                                                                                                                                                     
                                echo $(date +%k:%M) " - Nikto on $i complete"                                                                             
                done                                                                                                                                                                                                                                                                                                 
        done                                                                                                                                                                                                                                                                                                         
        return 0                                                                                                                                                                                                                                                                                                     
}                                                                                                                                                         
                                                                                                                                                          
                                                                                                                                                          
create_smb_folder()                                                                                                                                       
{                                                                                                                                                         
        for i in $( cat AvailableIPs.txt); do                                                                                                             
                for j in $(sed -e 's/ /\n/g' $i/nmap/allports | awk -F \/ '/smb/ {print $1}'); do                                                         
                        if [ -d $i/smb ];then                                                                                                             
                                return 0                                                                                                                  
                                else                                                                                                                      
                                mkdir $i/smb                                                                                                              
                        fi                                                                                                                                
                done                                                                                                                                      
        done                                                                                                                                              
        return 0                                                                                                                                          
}                                                                                                                                                         
#check_smb()                                                                                                                                                                                                                                                                                                         
#{                                                                                                                                                        
#        for i in $( cat AvailableIPs.txt); do                                                                                                            
#                        if [ -d $i/smb ]; then                                                                                                           
#                                echo "SMB found on $i would be worth checking SMB Map"                                                                   
#                                return 0                                                                                                                 
#                        else                                                                                                                             
#                                echo "No SMB found."                                                                                                     
#                                exit 1                                                                                                                   
#                        fi                                                                                                                               
#        done                                                                                                                                             
#}                                                                                                                                                        
                                                                                                                                                          
function run {                                                                                                                                            
#       check                                                                                                                                             
#               echo $(date +%k:%M) " - Initial nmap Scan"                                                                                                
#       initial_nmap                                                                                                                                      
#               echo $(date +%k:%M) " - Initial nmap finished. Creating folders"                                                                          
        create_folders                                                                                                                                    
                echo $(date +%k:%M) " - Folders Created"                                                                                                  
                echo $(date +%k:%M) " - Running full nmap port scan over:"                                                                                
                 cat AvailableIPs.txt                                                                                                                     
        full_port_nmap                                                                                                                                    
                echo $(date +%k:%M) " - Full Port Scan Finished"                                                                                          
                echo $(date +%k:%M) " - Starting Full Script Scan"                                                                                        
        full_nmap                                                                                                                                         
                echo $(date +%k:%M) " - Full script scan Finished"                                                                                        
                echo $(date +%k:%M) " - Starting UDP scan"                                                                                                
        udp_nmap                                                                                                                                                                                                                                                                                                     
                echo $(date +%k:%M) " - UDP Scan Finished"                                                                                                
                echo $(date +%k:%M) " - Checking for webservers"                                                                                          
        create_webserver_folder                                                                                                                                                                                                                                                                                      
        check_webservers                                                                                                                                                                                                                                                                                             
                echo $(date +%k:%M) " - Webserver Folders Created"                                                                                        
                echo $(date +%k:%M) " - Running Gobuster"                                                                                                 
        gobuster_http                                                                                                                                     
        gobuster_https                                                                                                                                    
                echo $(date +%k:%M) " - Gobuster Finished running"                                                                                        
                echo $(date +%k:%M) " - Running nikto on all webservers"                                                                                  
        nikto                                                                                                                                             
                echo $(date +%k:%M) " - Nikto Finished running"                                                                                           
                echo $(date +%k:%M) " - Checking for SMB"                                                                                                 
        create_smb_folder                                                                                                                                 
#       check_smb                                                                                                                                         
                echo $(date +%k:%M) " - SMB Folder Created as a reminder!"                                                                                                                                                                                                                                           
                echo $(date +%k:%M) " - All Finished"                                                                                                     
                exit 1                                                                                                                                    
}                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                     
run 
