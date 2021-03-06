#!/bin/bash

# -----
# Usage
# -----
# $ . aosip.sh <device> <sync|nosync>
# Parameter 1: device (eg. angler, bullhead, shamu)
# Parameter 2: sync or nosync (decides whether or not to run repo sync)



# --------
# Examples
# --------
# $ . aosip.sh angler sync
# $ . aosip.sh angler nosync



# ----------
# Parameters
# ----------
DEVICE=${1}
SYNC=${2}



# ---------
# Variables
# ---------
ANDROIDDIR=${HOME}
SOURCEDIR=${ANDROIDDIR}/ROMs/AOSiP
OUTDIR=${SOURCEDIR}/out/target/product/${DEVICE}
ZIPMOVE=${HOME}/shared/ROMs/AOSiP/${DEVICE}



# ------
# Colors
# ------
RED="\033[01;31m"
RST="\033[0m"



# Export the COMPILE_LOG variable for other files to use (I currently handle this via .bashrc)
# export LOGDIR=${ANDROIDDIR}/Logs
# export COMPILE_LOG=${LOGDIR}/compile_log_`date +%m_%d_%y`.log



# Clear the terminal
clear



# Start tracking time
echo -e ${RED}
echo -e "---------------------------------------"
echo -e "SCRIPT STARTING AT $(date +%D\ %r)"
echo -e "---------------------------------------"
echo -e ${RST}

START=$(date +%s)



# Change to the source directory
echo -e ${RED}
echo -e "--------------------------"
echo -e "MOVING TO SOURCE DIRECTORY"
echo -e "--------------------------"
echo -e ${RST}

cd ${SOURCEDIR}



# Sync the repo if requested
if [ "${SYNC}" == "sync" ]
then
   echo -e ${RED}
   echo -e "----------------------"
   echo -e "SYNCING LATEST SOURCES"
   echo -e "----------------------"
   echo -e ${RST}
   echo -e ""

   repo sync --force-sync
fi



# Setup the build environment
echo -e ${RED}
echo -e "----------------------------"
echo -e "SETTING UP BUILD ENVIRONMENT"
echo -e "----------------------------"
echo -e ${RST}
echo -e ""

. build/envsetup.sh



# Prepare device
echo -e ${RED}
echo -e "----------------"
echo -e "PREPARING DEVICE"
echo -e "----------------"
echo -e ${RST}
echo -e ""

breakfast ${DEVICE}



# Clean up
echo -e ${RED}
echo -e "-------------------------"
echo -e "CLEANING UP OUT DIRECTORY"
echo -e "-------------------------"
echo -e ${RST}
echo -e ""

make clobber



# Start building
echo -e ${RED}
echo -e "---------------"
echo -e "MAKING ZIP FILE"
echo -e "---------------"
echo -e ${RST}
echo -e ""

time mka bacon



# If the above was successful
if [ `ls ${OUTDIR}/AOSiP-*-${DEVICE}-*.zip 2>/dev/null | wc -l` != "0" ]
then
   BUILD_RESULT_STRING="BUILD SUCCESSFUL"



   # Remove exisiting files in ZIPMOVE
   echo -e ""
   echo -e ${RED}
   echo -e "--------------------------"
   echo -e "CLEANING ZIPMOVE DIRECTORY"
   echo -e "--------------------------"
   echo -e ${RST}

   rm "${ZIPMOVE}"/*${DEVICE}*.zip
   rm "${ZIPMOVE}"/*${DEVICE}*.zip.md5sum



   # Copy new files to ZIPMOVE
   echo -e ${RED}
   echo -e "---------------------------------"
   echo -e "MOVING FILES TO ZIPMOVE DIRECTORY"
   echo -e "---------------------------------"
   echo -e ${RST}

   mv ${OUTDIR}/AOSiP-*-${DEVICE}-*.zip "${ZIPMOVE}"
   mv ${OUTDIR}/AOSiP-*-${DEVICE}-*.zip.md5sum "${ZIPMOVE}"



   # Upload the files
   echo -e ${RED}
   echo -e "---------------"
   echo -e "UPLOADING FILES"
   echo -e "---------------"
   echo -e ${RST}
   echo -e ""

   . ${HOME}/upload.sh



   # Clean up out directory to free up space
   echo -e ""
   echo -e ${RED}
   echo -e "-------------------------"
   echo -e "CLEANING UP OUT DIRECTORY"
   echo -e "-------------------------"
   echo -e ${RST}
   echo -e ""

   make clobber



   # Go back home
   echo -e ${RED}
   echo -e "----------"
   echo -e "GOING HOME"
   echo -e "----------"
   echo -e ${RST}

   cd ${HOME}

# If the build failed, add a variable
else
   BUILD_RESULT_STRING="BUILD FAILED"

fi



# Stop tracking time
END=$(date +%s)
echo -e ${RED}
echo -e "-------------------------------------"
echo -e "SCRIPT ENDING AT $(date +%D\ %r)"
echo -e ""
echo -e "${BUILD_RESULT_STRING}!"
echo -e "TIME: $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')"
echo -e "-------------------------------------"
echo -e ${RST}

# Add line to compile log
echo -e "`date +%H:%M:%S`: ${BASH_SOURCE} ${DEVICE}" >> ${COMPILE_LOG}
echo -e "${BUILD_RESULT_STRING} IN $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')\n" >> ${COMPILE_LOG}

echo -e "\a"
