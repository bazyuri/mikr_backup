#!/bin/bash
routers=( 192.168.0.1 192.168.0.2 )
backupdir="/home/backup/mikrotik/temp/"
privatekey="/root/.ssh/id_dsa"
login="admin"
fulldir="${backupdir}"
.
for r in ${routers[@]}; do
    cmd_backup="/system backup save name=${r}.backup"
    ssh ${login}@$r -i $privatekey "${cmd_backup}" > /dev/null
    cmd_backup="/export file=${r}"
    ssh ${login}@$r -i $privatekey "${cmd_backup}" > /dev/null
    sleep 5
    mkdir -p $fulldir
    #wget -qP $fulldir ftp://${login}:${passwd}@${r}/${r}.backup
    #wget -qP $fulldir ftp://${login}:${passwd}@${r}/${r}.rsc
    scp -i $privatekey ${login}@${r}:${r}.backup ${backupdir}
    scp -i $privatekey ${login}@${r}:${r}.rsc ${backupdir}
    ssh ${login}@$r -i $privatekey "/file remove \"${r}.backup\""
    ssh ${login}@$r -i $privatekey "/file remove \"${r}.rsc\""
done

# Папка, куда будем складывать архивы

syst_dir=/home/backup/mikrotik

# Создаем папку для инкрементных бэкапов

mkdir -p /home/backup/mikrotik/increment/

# Запускаем непосредственно бэкап с параметрами

/usr/bin/rsync -ax --delete ${backupdir} ${syst_dir}/current/ --backup --backup-dir=${syst_dir}/increment/`date +%F--%H-%M`/

# Чистим папки с инкрементными архивами старше 366-ти дней

/usr/bin/find ${syst_dir}/increment/ -maxdepth 1 -type d -mtime +366 -exec rm -rf {} \;
