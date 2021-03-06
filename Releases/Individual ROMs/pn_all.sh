#!/bin/bash


# -----
# Usage
# -----
# $ . pn_all.sh <mod>

if [[ -n ${1} ]]
then
   . pn.sh angler sync ${1}
   . pn.sh shamu sync ${1}
   . pn.sh bullhead sync ${1}
   . pn.sh hammerhead sync ${1}
else
   . pn.sh angler sync
   . pn.sh shamu sync
   . pn.sh bullhead sync
   . pn.sh hammerhead sync
fi

cat ${COMPILE_LOG}
cd ${HOME}
