#!/bin/bash

# Read FTP password from Docker secrets
if [ -f /run/secrets/ftp_password ]; then
    export FTP_PASSWORD=$(cat /run/secrets/ftp_password)
fi

# 1. Create the FTP user (if not exists)
if ! id "ftp_user" &>/dev/null; then
    # Create user with home directory pointing to WordPress files
    useradd -m -d /var/www/html -s /bin/bash ftp_user
    echo "ftp_user:$FTP_PASSWORD" | chpasswd

    # Add the user to the www-data group so they can edit files
    usermod -aG www-data ftp_user
    chown -R ftp_user:www-data /var/www/html
fi

# 2. Configure vsftpd (Write config file on the fly)
cat << EOF > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21100
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
EOF

# 3. Add user to the allowed list
echo "ftp_user" > /etc/vsftpd.userlist

echo "FTP Server started on port 21"
exec /usr/sbin/vsftpd /etc/vsftpd.conf
