#!/system/bin/xbin/busybox sh
#
# mkdir vartmpfs cache
#
File="post-fs-data.sh"
MODDIR=${0%/*}
if [ "${MODDIR} == "${File} ]; then
  MODDIR=$(pwd)
  echo "MODDIR=${MODDIR}"
else
  echo "MODDIR=${MODDIR}"
fi
VarParh=/dev/var

if [ ! -d ${VarParh} ]; then
  mkdir "${VarParh}"
  mkdir "${VarParh}/run"
  mkdir "${VarParh}/log"
  mkdir "${VarParh}/cache"
  mkdir "${VarParh}/tmp"
  mkdir "${VarParh}/tmp/cache"
fi

chcon -R u:object_r:app_data_file:s0 "${VarParh}/tmp/cache"
chmod -R 0777 "${VarParh}/*"
chmod -R +X "${VarParh}/*"

chmod -R 0755 "${MODDIR}/*"
chmod -R +X "${MODDIR}/*"
