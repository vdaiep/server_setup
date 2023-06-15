#!/bin/bash

# Prompt for hostname
while true; do
  read -p "Enter the hostname (leave empty to skip): " hostname
  if [[ -z "$hostname" || $hostname =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$ ]]; then
    break
  else
    echo "Invalid hostname, please try again."
  fi
done

current_timezone=$(timedatectl show --format='value' --property=Timezone)

# Prompt for timezone change
while true; do
  echo "Current timezone is $current_timezone."
  read -p "Change the server's timezone? (Y/n): " changetimezone_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  changetimezone_input=$(echo "$changetimezone_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $changetimezone_input == "y" || $changetimezone_input == "yes" ]]; then
    changetimezone=true
    break
  elif [[ $changetimezone_input == "n" || $changetimezone_input == "no" ]]; then
    changetimezone=false
    break
  fi
done

if [ "$changetimezone" = true ]; then
  # Prompt for the new timezone
  while true; do
    read -p "Enter the desired timezone (ex. 'America/Los_Angeles'): " new_timezone
    if timedatectl list-timezones | grep -q "^$new_timezone$"; then
      break
    else
      echo "Invalid timezone, please try again."
    fi
  done
fi

# Prompt for creating a sudo user
while true; do
  read -p "Create a sudo user? (Y/n): " createsudouser_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  createsudouser_input=$(echo "$createsudouser_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $createsudouser_input == "y" || $createsudouser_input == "yes" ]]; then
    createsudouser=true
    break
  elif [[ $createsudouser_input == "n" || $createsudouser_input == "no" ]]; then
    createsudouser=false
    break
  fi
done

if [ "$createsudouser" = true ]; then
  # Prompt for username
  while true; do
    read -p "Enter the username: " username
    if [[ $username =~ ^[a-z_][a-z0-9_]{0,30}$ ]]; then
      if id -u "$username" >/dev/null 2>&1; then
        echo "User already exists. Please enter a different username."
      else
        break
      fi
    else
      echo "Invalid username, please try again."
    fi
  done

  # Prompt for password
  while true; do
    read -s -p "Enter the password (8 characters minimum): " password
    echo
    if [ ${#password} -ge 8 ]; then
      read -s -p "Confirm password: " password_confirm
      echo
      if [ "$password" = "$password_confirm" ]; then
        break
      else
        echo "Passwords do not match. Please try again."
      fi
    else
      echo "Password must be at least 8 characters long."
    fi
  done

else
  # Prompt for root password
  while true; do
    read -s -p "Enter the root password (8 characters minimum): " root_password
    echo
    if [ ${#root_password} -ge 8 ]; then
      read -s -p "Confirm password: " root_password_confirm
      echo
      if [ "$root_password" = "$root_password_confirm" ]; then
        break
      else
        echo "Passwords do not match. Please try again."
      fi
    else
      echo "Password must be at least 8 characters long."
    fi
  done
fi

# Prompt for changing default SSH port
while true; do
  read -p "Change the default SSH port? (Y/n): " changesshport_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  changesshport_input=$(echo "$changesshport_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $changesshport_input == "y" || $changesshport_input == "yes" ]]; then
    changesshport=true
    break
  elif [[ $changesshport_input == "n" || $changesshport_input == "no" ]]; then
    changesshport=false
    break
  fi
done

# Prompt for installing Docker
while true; do
  read -p "Install Docker and Docker Compose? (Y/n): " installdocker_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  installdocker_input=$(echo "$installdocker_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $installdocker_input == "y" || $installdocker_input == "yes" ]]; then
    installdocker=true
    break
  elif [[ $installdocker_input == "n" || $installdocker_input == "no" ]]; then
    installdocker=false
    break
  fi
done

# Prompt for web server installation
while true; do
  read -p "Install a web server? (Y/n): " installwebserver_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  installwebserver_input=$(echo "$installwebserver_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $installwebserver_input == "y" || $installwebserver_input == "yes" ]]; then
    installwebserver=true
    break
  elif [[ $installwebserver_input == "n" || $installwebserver_input == "no" ]]; then
    installwebserver=false
    break
  fi
done

if [ "$installwebserver" = true ]; then
  while true; do
    read -p "Choose a web server: Nginx (default), Apache: " webserver_input

    # Normalize input (convert to lowercase and remove leading/trailing spaces)
    webserver_input=$(echo "$webserver_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

    if [[ -z $webserver_input || $webserver_input == "nginx" ]]; then
      webserver="nginx"
      break
    elif [[ $webserver_input == "apache" ]]; then
      webserver="apache"
      break
    fi
  done
fi

# Prompt for installing Certbot
if [[ "$webserver" == "apache" || "$webserver" == "nginx" ]]; then
  while true; do
    read -p "Install Certbot for SSL certificates? (Y/n): " installcertbot_input

    # Normalize input (convert to lowercase and remove leading/trailing spaces)
    installcertbot_input=$(echo "$installcertbot_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

    if [[ $installcertbot_input == "y" || $installcertbot_input == "yes" ]]; then
      installcertbot=true
      break
    elif [[ $installcertbot_input == "n" || $installcertbot_input == "no" ]]; then
      installcertbot=false
      break
    fi
  done
fi

# Prompt for installing a firewall
while true; do
  read -p "Install a firewall? (Y/n): " installfirewall_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  installfirewall_input=$(echo "$installfirewall_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $installfirewall_input == "y" || $installfirewall_input == "yes" ]]; then
    installfirewall=true
    break
  elif [[ $installfirewall_input == "n" || $installfirewall_input == "no" ]]; then
    installfirewall=false
    break
  fi
done

if [ "$installfirewall" = true ]; then
  # Prompt for firewall selection
  while true; do
    read -p "Choose a firewall: UFW (default), iptables, or Firewalld: " firewall_input

    # Normalize input (convert to lowercase and remove leading/trailing spaces)
    firewall_input=$(echo "$firewall_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

    if [[ -z $firewall_input || $firewall_input == "ufw" ]]; then
      firewall="ufw"
      break
    elif [[ $firewall_input == "iptables" ]]; then
      firewall="iptables"
      break
    elif [[ $firewall_input == "firewalld" ]]; then
      firewall="firewalld"
      break
    fi
  done
fi

while true; do
  read -p "Install additional packages? (Y/n): " installadditional_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  installadditional_input=$(echo "$installadditional_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $installadditional_input == "y" || $installadditional_input == "yes" ]]; then
    installadditional=true
    break
  elif [[ $installadditional_input == "n" || $installadditional_input == "no" ]]; then
    installadditional=false
    break
  fi
done

# Update and upgrade
apt update
apt upgrade -y

# Change hostname if provided
if [ -n "$hostname" ]; then
  hostnamectl set-hostname "$hostname"
  if ! grep -q "$hostname" /etc/hosts; then
    echo "127.0.0.1   $hostname" >> /etc/hosts
  fi
fi

# Change timezone if required
if [ "$changetimezone" = true ]; then
  timedatectl set-timezone "$new_timezone"
  echo "Timezone changed to $new_timezone"
fi

# Change SSH port if requested
if [ "$changesshport" = true ]; then
  # Generate a random port between 49152 and 65535 (ephemeral ports range)
  ssh_port=$(( (RANDOM % 16384) + 49152 ))
  sed -i "s/^#*Port .*/Port $ssh_port/" /etc/ssh/sshd_config
  systemctl restart sshd
  echo "SSH port changed to $ssh_port"
fi

# Install Docker and Docker Compose if required
if [ "$installdocker" = true ]; then
  # Install Docker
  apt update
  apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io

  # Install Docker Compose
  curl -sSL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Install web server if required
if [ "$installwebserver" = true ]; then
  if [ "$webserver" = "apache" ]; then
    apt update
    apt install -y apache2

    # Install Certbot if requested
    if [ "$installcertbot" = true ]; then
      apt install -y certbot python3-certbot-apache
    fi
  elif [ "$webserver" = "nginx" ]; then
    apt update
    apt install -y nginx

    # Install Certbot if requested
    if [ "$installcertbot" = true ]; then
      apt install -y certbot python3-certbot-nginx
    fi
  fi
fi

if [ "$installfirewall" = true ]; then
  # Install and enable the chosen firewall
  if [ "$firewall" = "ufw" ]; then
    apt update
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    if [ "$changesshport" = true ]; then
      ufw allow $ssh_port
    else
      ufw allow OpenSSH
    fi
    if [ "$webserver" = "nginx" ]; then
      ufw allow in "Nginx Full"
    fi
    if [ "$webserver" = "apache" ]; then
      ufw allow in "Apache Full"
    fi
    ufw --force enable
  elif [ "$firewall" = "iptables" ]; then
    apt update
    apt install -y iptables-persistent
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p icmp -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    if [ "$webserver" = "apache" ] || [ "$webserver" = "nginx" ]; then
      iptables -A INPUT -p tcp --dport 80 -j ACCEPT
      iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    fi
    iptables-save > /etc/iptables/rules.v4
  elif [ "$firewall" = "firewalld" ]; then
    apt update
    apt install -y firewalld
    systemctl enable firewalld
    systemctl start firewalld
    firewall-cmd --zone=public --add-service=ssh --permanent
    if [ "$webserver" = "apache" ]; then
      firewall-cmd --zone=public --add-service=http --permanent
      firewall-cmd --zone=public --add-service=https --permanent
    elif [ "$webserver" = "nginx" ]; then
      firewall-cmd --zone=public --add-service=http --permanent
      firewall-cmd --zone=public --add-service=https --permanent
    fi
    firewall-cmd --reload
  fi
fi

# Install additional packages if required
if [ "$installadditional" = true ]; then
  apt install build-essential git python3-pip curl wget unzip htop vim tmux tree net-tools nmap fail2ban tcpdump python-is-python3 apache2-utils
  systemctl enable fail2ban
  apt-get install auditd audispd-plugins
  touch /etc/audit/rules.d/audit_commands.rules
  echo -e '-a always,exit -F arch=b64 -S execve -k executed_commands\n-a always,exit -F arch=b32 -S execve -k executed_commands\n-w /var/log/wtmp -p wa -k logins\n-w /var/run/faillock/ -p wa -k logins' | sudo tee /etc/audit/rules.d/audit_commands.rules > /dev/null
fi

# Create sudo user or change root password
if [ "$createsudouser" = true ]; then
  # Create a sudo user with the provided username and password
  useradd -m -s /bin/bash -G sudo "$username"
  echo "$username:$password" | chpasswd
  passwd -l root

  # Add sudo user to Docker group if installing Docker
  if [ "$installdocker" = true ]; then
    usermod -aG docker "$username"
  fi
else
  # Change root password to the provided password
  echo "root:$root_password" | chpasswd
fi

if [ "$changesshport" = true ]; then
  echo "IMPORTANT: Your SSH port was changed to $ssh_port. Make sure to note it down for future reference, or you may find yourself locked out of SSH."
fi

# Finish installation and reboot
while true; do
  read -p "System reboot is required to complete the setup. Reboot now? (Y/n): " reboot_input

  # Normalize input (convert to lowercase and remove leading/trailing spaces)
  reboot_input=$(echo "$reboot_input" | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')

  if [[ $reboot_input == "y" || $reboot_input == "yes" ]]; then
    reboot
    break
  elif [[ $reboot_input == "n" || $reboot_input == "no" ]]; then
    echo "Please remember to reboot your system later to complete the setup."
    break
  fi
done
