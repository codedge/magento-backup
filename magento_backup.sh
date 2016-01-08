#!/bin/bash
#@version   0.3.0
#@author    Holger Lösken <holger.loesken@codedge.de>
 
# Configuration
projectName=MyProject
currentDir="$(pwd)"
backupDir="$currentDir/var/backups"

# The user and pass are stored in ~/.netrc on the web server
ftp_backup_host="11.22.33.44"
ftp_backup_dir="backups" # Put a "." to stay in the current folder

# Edit below only if you know what you are doing! 
dbXmlPath="app/etc/local.xml"
{
host="$(xmllint --xpath 'string(//default_setup/connection/host)' $dbXmlPath)"
username="$(xmllint --xpath 'string(//default_setup/connection/username)' $dbXmlPath)"
password="$(xmllint --xpath 'string(//default_setup/connection/password)' $dbXmlPath)"
dbName="$(xmllint --xpath 'string(//default_setup/connection/dbname)' $dbXmlPath)"
}


usage()
{
    echo "
Usage:  $0 -t <database|files|basesystem> -m <1|0> -b <1|0>
        -t: Backup type, either database only or files
        -m: If enabled you can skip media files (media directory) from being backuped.
            Files in includes/ and /var as well as .htaccess will always be excluded.
        -b: If enabled the backup files will be moved to an external ftp server.
            This can only be used with a .netrc file with username and password of the server.
" 1>&2;
    exit 1;
}


ftp_backup()
{
    f=$1

ftp $ftp_backup_host <<ENDFTP
cd $ftp_backup_dir
put $f
quit
ENDFTP
}


while getopts ":t:m:b:" o; do
    case "${o}" in
        t)
            t=${OPTARG}
            ((t == database || t == files || t == basesystem)) || usage
            ;;
        m)
            m=${OPTARG}
            ((m == 1 || m == 0)) || usage
            ;;
        b)
            b=${OPTARG}
            ((b == 1 || b == 0)) || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

backupType=$t
skipMedia=$m
makeFtpBackup=$b

fileName=$projectName-$(date +"%Y-%m-%d")


if [ "$backupType" == "database" ] || [ "$backupType" == "basesystem" ]; then
    echo "----------------------------------------------------"
    echo "Dumping MySQL to $fileName.sql.gz..."
    mysqldump -h$host -u$username -p$password $dbName | gzip > $fileName.sql.gz
    echo "Done!"
fi
 
if [ "$backupType" == "files" ] || [ "$backupType" == "basesystem" ]; then
    echo "----------------------------------------------------"
    echo "Archiving Files to $fileName.tar.gz..."

    if [ $skipMedia == 1 ]; then
        echo " -> Skipping media files (media directory)"
        tar -zcf $fileName.tar.gz --exclude=var --exclude=includes --exclude=media * .htaccess
    else
        echo " -> Include media files (media directory)"
        tar -zcf $fileName.tar.gz --exclude=var --exclude=includes * .htaccess
    fi
    echo "Done!"
    echo "----------------------------------------------------"
fi
 
if [ "$backupType" == "database" ] || [ "$backupType" == "files" ] || [ "$backupType" == "basesystem" ]; then
    echo "----------------------------------------------------"

    if [ ! -d $backupDir ]; then
        echo "$backupDir does not exist! Creating..."
        mkdir -p $backupDir;
        echo "Done!"
        echo "----------------------------------------------------"
    fi

    echo "Moving file to backup dir $backupDir..."
    if [ "$backupType" == "database" ] || [ "$backupType" == "basesystem" ]; then
        echo " -> $fileName.sql.gz"
        mv $fileName.sql.gz $backupDir
    fi
 
    if [ "$backupType" == "files" ] || [ "$backupType" == "basesystem" ]; then
        echo " -> $fileName.tar.gz"
        mv $fileName.tar.gz $backupDir
    fi
    echo "Done!"
    echo "----------------------------------------------------"
else
    usage
fi

if [ "$makeFtpBackup" == "1" ]; then
    echo "Copying files to ftp backup server ($ftp_backup_host)..."

    if [ "$backupType" == "database" ] || [ "$backupType" == "basesystem" ]; then
        echo " -> $fileName.sql.gz"
        cd $backupDir
        ftp_backup "$fileName.sql.gz"
        cd -
    fi

    if [ "$backupType" == "files" ] || [ "$backupType" == "basesystem" ]; then
        echo " -> $fileName.tar.gz"
        cd $backupDir
        ftp_backup "$fileName.tar.gz"
        cd -
    fi

    echo "Done!"
    echo "----------------------------------------------------"
fi
