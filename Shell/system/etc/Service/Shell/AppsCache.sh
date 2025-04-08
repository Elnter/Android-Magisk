#!/system/bin/xbin/busybox sh
#----------  Logic   ----------#
function CheckFileExists() {
    FilePath=${1}
    echo "[!] CheckFileExists:FilePath=${FilePath}" >> ${ServiceLog}
    if [ -f ${FilePath} ]; then
        echo "[!] CheckFileExists:return 0" >> ${ServiceLog}
        return 0
    else
        echo "[x] CheckFileExists:return 1" >> ${ServiceLog}
        return 1
    fi
}

function CheckDirectoryExists() {
    DirectoryPath=${1}
    if [ -d ${DirectoryPath} ]; then
        echo "[!] CheckDirectoryExists:DirectoryPath=${DirectoryPath} return 0" >> ${ServiceLog}
        return 0
    else
        echo "[x] CheckDirectoryExists:DirectoryPath=${DirectoryPath} return 1" >> ${ServiceLog}
        return 1
    fi
}

function CheckMountFlagStatus() {
    MountFlag=${1}
    if [ ${MountFlag} == 0 ]; then
        echo "[!] CheckMountFlagStatus:MountFlag=${MountFlag} return 0" >> ${ServiceLog}
        return 0
    else
        echo "[x] CheckMountFlagStatus:MountFlag=${MountFlag} return 1" >> ${ServiceLog}
        return 1
    fi
}

#----------  Action  ----------#
function CreateFile() {
    FilePath=${1}
    touch ${FilePath} >> ${ServiceLog}
    echo "[*] CreateFile:Create=${FilePath}" >> ${ServiceLog}
}

function CreateDirectory() {
    DirectoryPath=${1}
    mkdir ${DirectoryPath} >> ${ServiceLog}
    echo "[*] CreateDirectory:Create=${DirectoryPath}" >> ${ServiceLog}
}

function ChangePermissionsMode() {
    Object=${1}
    chmod 0777 ${Object} >> ${ServiceLog}
    echo "[*] ChangePermissionsMode:Change=${Object}" >> ${ServiceLog}

}

function DeleteObject() {
    Object=${1}
    rm -rf "${Object}/*" >> ${ServiceLog}
    echo "[*] DeleteObject:Delete=${Object}" >> ${ServiceLog}

}

function MountObject() {
    SourceObject=${1}
    TargetObject=${2}
    mount --bind ${SourceObject} ${TargetObject} >> ${ServiceLog}
    echo "[*]  MountObject:Mount=${SourceObject}---->${TargetObject}" >> ${ServiceLog}
}

#---------- Sequence ----------#
echo "######### File=AppCache.sh $(date) #########" >> ${ServiceLog}

CachePath=${ServiceCache}
echo "CachePath=${CachePath}" >> ${ServiceLog}
CodeCachePath=${ServiceCache}
echo "CodeCachePath=${CodeCachePath}" >> ${ServiceLog}

AppsListFile="/data/AppsList"
echo "AppsListFile=${AppsListFile}" >> ${ServiceLog}

if ! CheckFileExists ${AppsListFile}; then
    CreateFile ${AppsListFile}
fi

for AppName in $(cat ${AppsListFile}); do
    echo "----------------------" >> ${ServiceLog}
    AppDataPath="/data/data"
    echo "AppDataPath=${AppDataPath}" >> ${ServiceLog}
    AppNameData="${AppDataPath}/${AppName}"
    echo "AppNameData=${AppNameData}" >> ${ServiceLog}
    AppCache="${AppNameData}/cache"
    echo "AppCache=${AppCache}" >> ${ServiceLog}
    AppCodeCache="${AppNameData}/code_cache"
    echo "AppCodeCache=${AppCodeCache}" >> ${ServiceLog}

    if CheckDirectoryExists ${AppNameData}; then

        if ! CheckDirectoryExists ${AppCache}; then
            CreateDirectory ${AppCache}
        fi

        if ! CheckDirectoryExists ${AppCodeCache}; then
            CreateDirectory ${AppCodeCache}
        fi
        mountpoint -q ${AppCache}
        MountFlag=${?}
        if ! CheckMountFlagStatus ${MountFlag}; then
            ChangePermissionsMode ${AppCodeCache}
            ChangePermissionsMode ${AppCache}
            DeleteObject ${CodeCachePath}
            DeleteObject ${CachePath}
            echo "$(date) ${AppName}未挂载,现在执行挂载" >> ${ServiceLog}
            MountObject ${CodeCachePath} ${AppCodeCache}
            MountObject ${CachePath} ${AppCache}
            mountpoint -q ${AppCache}
            MountFlag=${?}
            if ! CheckMountFlagStatus ${MountFlag}; then
                echo "$(date) ${AppName}挂载失败" >> ${ServiceLog}
            fi
        else
            DeleteObject ${CodeCachePath}
            DeleteObject ${CachePath}
            echo "$(date) ${AppName}已挂载" >> ${ServiceLog}
        fi
    fi
done
