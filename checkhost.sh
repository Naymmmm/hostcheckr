#!/bin/bash

menu() {
    clear
    echo "hostcheckr"
    echo "----------"
    echo "1. Check the hosts file"
    echo "2. Display raw GitHub data"
    echo "3. Display Credits and Version"
    echo "4. Exit"
    echo ""
    read -p "Enter your choice: " -n 1 -r choice
    echo -e "\n"
    
    case $choice in
        1)
            check_hosts
            ;;
        2)
            display_raw_data
            ;;
        3)
            display_version_info
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3, or 4."
            echo ""
            read -p "Press Enter to continue..."
            menu
            ;;
    esac
}

check_hosts() {
    # Define the URL of the raw file on GitHub
    github_raw_url="https://a.dove.isdumb.one/list.txt"
    
    # Define the path to the hosts file
    hosts_file="/etc/hosts"
    
    # Initialize a variables to count total and missing lines
    total_count=0
    missing_hosts=()
    
    # Check for missing lines in the hosts file
    while IFS= read -r line; do
        # Skip comments
        if [[ "$line" == \#* ]]; then
            continue
        fi
        
        ((total_count++))
        
        # TODO: This will only look for an exact match; ideally, we should parse the hostname out and check for it
        if ! grep -q "$line" "$hosts_file"; then
            echo -e "\t'$line' is missing"
            missing_hosts+=("$line")
        fi
    done < <(curl -s "$github_raw_url")
    
    # If there are missing lines, display the count
    if [ "${#missing_hosts[@]}" -gt 0 ]; then
        echo "Looks like you are missing ${#missing_hosts[@]} of $total_count host values. Add them?"
        
        # If the user enters 'Y', update the hosts file
        if read -p "Press Y to continue..." -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            
            # Check if the script is running with root privileges
            if [[ $EUID -ne 0 ]]; then
                echo "Oops! You need to run this script as root to be able to read the hosts file."
                echo "Please run the script with sudo."
                echo ""
                read -p "Press Enter to continue..."
                menu
                return
            fi
            
            new_hosts=$(printf "%s\n" "${missing_hosts[@]}")
            echo "$new_hosts" | tee -a "$hosts_file" > /dev/null
            
            echo "Hosts file updated successfully."
        else
            echo -e "\nHosts file not updated."
        fi
    else
        echo "Your hosts file is up to date."
    fi
    
    # Pause to see the results
    echo ""
    read -p "Press Enter to continue..."
    menu
}

display_raw_data() {
    # Define the URL of the raw file on GitHub
    github_raw_url="https://a.dove.isdumb.one/list.txt"
    
    # Download and display the raw data from GitHub
    curl -s "$github_raw_url"
    
    # Pause to see the results
    echo ""
    read -p "Press Enter to continue..."
    menu
}

display_version_info() {
    # Display the script version information
    echo "You are running Host Checker Revived (Bash version)"
    echo "Developed by David Miles, inspired by Naymmm"
    echo "Hosts file by Ignacio"
    echo "Feel free to improve by opening a PR in the GitHub Repository!"
    
    # Pause to see the results
    echo ""
    read -p "Press Enter to continue..."
    menu
}

# Start the script by calling the menu function
menu