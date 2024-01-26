#!/bin/bash

# Configuration
AWS_ACCESS_KEY="#"
AWS_SECRET_KEY="#"
S3_BUCKET="#"
LOCAL_SOURCE_DIR="#"

# Display Menu
echo "Select an option:"
echo "1. Backup"
echo "2. Restore"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        # Backup
        TIMESTAMP=$(date +"%Y%m%d%H%M%S")
        BACKUP_FILE="backup_$TIMESTAMP.tar.gz"

        # Create a tar archive of the specified directory
        tar -czvf "/tmp/$BACKUP_FILE" -C "$LOCAL_SOURCE_DIR" .

        # Upload the backup to S3
        aws s3 cp "/tmp/$BACKUP_FILE" "s3://$S3_BUCKET/"

        # Clean up local backup file
        rm "/tmp/$BACKUP_FILE"

        echo "Backup completed and uploaded to S3."
        ;;
    2)
        # Restore
        echo "Available backup files:"
        aws s3 ls "s3://$S3_BUCKET/"

        read -p "Enter the backup file name for restore: " BACKUP_FILE

        # Download the backup from S3
        aws s3 cp "s3://$S3_BUCKET/$BACKUP_FILE" "/tmp/"

        # Restore the backup
        tar -xzvf "/tmp/$BACKUP_FILE" -C "$LOCAL_SOURCE_DIR"

        echo "Restore completed."
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
