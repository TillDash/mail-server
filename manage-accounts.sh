#!/bin/bash

# Email Account Management Script

ACTION=$1
EMAIL=$2
PASSWORD=$3

case $ACTION in
    add)
        if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ]; then
            echo "Usage: ./manage-accounts.sh add email@tilldash.com password"
            exit 1
        fi
        docker compose exec mailserver setup email add "$EMAIL" "$PASSWORD"
        echo "Email account $EMAIL created successfully"
        ;;
    
    del)
        if [ -z "$EMAIL" ]; then
            echo "Usage: ./manage-accounts.sh del email@tilldash.com"
            exit 1
        fi
        docker compose exec mailserver setup email del "$EMAIL"
        echo "Email account $EMAIL deleted"
        ;;
    
    update)
        if [ -z "$EMAIL" ] || [ -z "$PASSWORD" ]; then
            echo "Usage: ./manage-accounts.sh update email@tilldash.com new_password"
            exit 1
        fi
        docker compose exec mailserver setup email update "$EMAIL" "$PASSWORD"
        echo "Password updated for $EMAIL"
        ;;
    
    list)
        echo "Email accounts on this server:"
        docker compose exec mailserver setup email list
        ;;
    
    *)
        echo "TillDash Mail Server - Email Account Management"
        echo ""
        echo "Usage:"
        echo "  ./manage-accounts.sh add email@tilldash.com password    - Create new account"
        echo "  ./manage-accounts.sh del email@tilldash.com             - Delete account"
        echo "  ./manage-accounts.sh update email@tilldash.com password - Update password"
        echo "  ./manage-accounts.sh list                               - List all accounts"
        exit 1
        ;;
esac
