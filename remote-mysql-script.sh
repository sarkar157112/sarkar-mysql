#!/bin/bash

# Prompt the user for the remote host IP address or hostname
echo "Enter the remote host IP address or hostname:"
read -r remote_host

# Prompt the user for database name, username, and password
echo "Enter the database name:"
read -r database_name

# Loop to prompt the user for a unique username
while true; do
    echo "Enter the username:"
    read -r username
    echo "Enter the password:"
    read -r password

    # Check if the user already exists
    if mysql -h "$remote_host" -u root -p"$1" -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '${username}')" | grep -q '1'; then
        echo "User ${username} already exists. Please enter a different username."
    else
        # Check if the database already exists
        if mysql -h "$remote_host" -u root -p"$1" -e "use ${database_name}" &> /dev/null; then
            echo "Using existing database ${database_name}."
        else
            # SQL script to create database and user
            sql_script="
            CREATE DATABASE ${database_name};
            CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';
            GRANT ALL PRIVILEGES ON ${database_name}.* TO '${username}'@'%';
            FLUSH PRIVILEGES;
            "

            # Execute the SQL script
            echo "$sql_script" | mysql -h "$remote_host" -u root -p"$1"

            echo "Database ${database_name} created. User ${username} created and granted privileges."
        fi
        break
    fi
done
