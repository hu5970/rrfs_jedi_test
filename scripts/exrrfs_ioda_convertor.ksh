#!/bin/ksh --login

# loading modules and set common unix commands from outside
#   in jobs/launch.sh and/or modulefile
set -x

# Make sure DATAHOME is defined and exists
if [ ! "${SYSTEM_ID}" ]; then
  ${ECHO} "ERROR: $SYSTEM_ID is not defined!"
  SYSTEM_ID="RAP"
fi

if [ ! "${DATAHOME}" ]; then
  ${ECHO} "ERROR: \$DATAHOME is not defined!"
  exit 1
fi

if [ ! "${GSIDATAHOME}" ]; then
  ${ECHO} "ERROR: \$GSIDATAHOME is not defined!"
  exit 1
fi

# Make sure START_TIME is defined and in the correct format
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not defined!"
  exit 1
else
  if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
    START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
  elif [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
    ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
    exit 1
  fi
  START_TIME=`${DATE} -d "${START_TIME}"`
fi

echo "Running system: ${SYSTEM_ID}"
# Compute date & time components for the analysis time
YYYYJJJHH00=`${DATE} +"%Y%j%H00" -d "${START_TIME}"`
YYYYJJJHH=`${DATE} +"%Y%j%H" -d "${START_TIME}"`
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`
YYYYMMDD=`${DATE} +"%Y%m%d" -d "${START_TIME}"`
YYJJJHH=`${DATE} +"%y%j%H" -d "${START_TIME}"`
YYYY=`${DATE} +"%Y" -d "${START_TIME}"`
MM=`${DATE} +"%m" -d "${START_TIME}"`
DD=`${DATE} +"%d" -d "${START_TIME}"`
HH=`${DATE} +"%H" -d "${START_TIME}"`

# Create the working directory and cd into it
workdir=${DATAHOME}
rm -rf ${workdir}
mkdir -p ${workdir}
cd ${workdir}

  mkdir ncdiagges
  mkdir diag_ioda
  mkdir diag_geoval
  cp ${GSIDATAHOME}/ncdiag_*_ges.nc4.* ./ncdiagges

  source /misc/whome/Guoqing.Ge/modulefile.python
  python ${EXEC_ROOT}/proc_gsi_ncdiag.py -o diag_ioda -g diag_geoval -n 4 ncdiagges

  ls diag_ioda/sfc_*_obs_${YYYYMMDDHH}.nc4 > filelist_obs
  numobsfile=`more filelist_obs | wc -l`
  numobsfile=$((numobsfile - 3 ))
  if [[ ${numobsfile} -gt 1 ]]; then
     python ${EXEC_ROOT}/combine_files.py -o ioda_sfc_${YYYYMMDDHH}.nc4 -g diag_geoval -i diag_ioda/sfc_*_obs_${YYYYMMDDHH}.nc4
  fi

  ls diag_ioda/sondes_*_obs_${YYYYMMDDHH}.nc4 > filelist_obs
  numobsfile=`more filelist_obs | wc -l`
  numobsfile=$((numobsfile - 3 ))
  if [[ ${numobsfile} -gt 1 ]]; then
     python ${EXEC_ROOT}/combine_files.py -o ioda_sondes_${YYYYMMDDHH}.nc4 -g diag_geoval -i diag_ioda/sondes_*_obs_${YYYYMMDDHH}.nc4
  fi


exit 0
