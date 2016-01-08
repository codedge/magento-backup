# Magento backup
With this shell script you can create backups of your Magento installation, either database or files.
The script is based on [MagePsychos](http://www.blog.magepsycho.com/backup-magento-project-files-db-using-bash-script/) script.


## Requirements / Prerequisites
- bash shell
- installed xmllint >=20901 (http://xmlsoft.org/xmllint.html)
- installed `tar` package
- installed `ftp` package
- make the script executable, i. e. via `chmod +x magento_backup.sh`
- place the script in your <Magento root> folder

## Notes
- Please specify a project name in the _configuration_ section of the [script](magento_backup.sh), see `projectName` variable
- The backup folder will be created in `<Magento root>/var/backups`

## Usage
`./magento-backup.sh -t <database|files|basesystem> -m <1|0> -b <1|0>`

You've got three options how to run the script:
* `-t`: type of backup
    * `database`: Only the datase will be backuped as a .sql.gz archive
    * `files`:  Only Magento files will be backuped as a .tar.gz archive.
                The folders var/ and includes/ as well as the .htaccess file are completly ignored and _will not_ be saved. Please see the parameter `-m` for more options.
    * `basesystem`: For both files and database a backup will be created and optinally transferred to an ftp server.
* `-m`: skip media files
    * `0`: Include all files in the media/ folder, product and category images, picture cache,...
    * `1`: Exlude the entire media/ folder from being backuped
* `-b`: backup on external FTP server
    * `0`: The backup file will not be transferred to any external ftp server
    * `1`: The backup file will be transferred to an ftp server specified in the _configuration_ section, see `ftp_backup_host` variable. Furthermore you need to have a `.netrc` with valid credentials for the ftp server.
    If you are unfamiliar with `.netrc` please see http://www.mavetju.org/unix/netrc.php for how to set up.

## Contact
* If you encounter any problems or bugs, please [create an issue](https://github.com/codedge/magento-backup/issues/new) on Github
* I am happy to merge in any improvements - just send me a pull request
* For any other things, send me a mail to holger.loesken@codedge.de



