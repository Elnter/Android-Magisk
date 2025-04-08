#!/system/bin/xbin/busybox sh
#
# service init
#

export VarPath="/dev/var"
echo "VarPath=${VarPath}"

File=service.sh
echo "File=${File}"

if [[ ":${PATH}:" != *"/system//bin/xbin"* ]]; then
  export env PATH="${PATH}:/system/bin/xbin"
fi

MODDIR=${0%/*}
if [ ${MODDIR} == ${File} ]; then
  MODDIR="$(pwd)"
  echo "MODDIR=${MODDIR}"
else
  echo "MODDIR=${MODDIR}"
fi

export ModPath=${MODDIR}

ModuleLine=$(sed -n '2p' ${ModPath}/module.prop)
echo "ModuleLine=${ModuleLine}"

export ModName=${ModuleLine#*=}
echo "ModName=${ModName}"

export ModLog="${VarPath}/log/${ModName}.log"
echo "ModLog=${ModLog}"
echo "File=Service.sh" $(date) >${ModLog}

echo "ModName=${ModName}" >> ${ModLog}

echo "PATH=${PATH}" >> ${ModLog}

echo "ModPath=${ModPath}" >> ${ModLog}

export ModBin="${ModPath}/system/bin/xbin"
echo "ModBin=${ModBin}" >> ${ModLog}

export ModService="${ModPath}/system/etc/Service"
echo "ModService=${ModService}" >> ${ModLog}

export ModBusybox="${ModPath}/system/bin/xbin/busybox"
echo "ModBusybox=${ModBusybox}" >> ${ModLog}

export ModServicePID="${VarPath}/run/${ModName}.pid"

if [ ! -f "${ModBin}/${ModName}.Service" ]; then
  ln -s "${ModService}/${ModName}.Service" "${ModBin}/${ModName}.Service" >> ${ModLog}
  chmod 0755 "${ModService}/${ModName}.Service"
  chmod +X "${ModService}/${ModName}.Service"
fi

sleep 30

eval sh "${ModBin}/${ModName}.Service" "Restart" &
>> ${ModLog}
