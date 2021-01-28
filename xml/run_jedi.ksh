#!/bin/ksh --login

set -e
source /home/rtrr/PARM_EXEC/modulefiles/modulefile.jet.ROCOTO

rocotorun -w /mnt/lfs4/BMC/rtwbl/mhu/jedi/system/xml/RRFS_JEDI.xml -d /mnt/lfs4/BMC/rtwbl/mhu/jedi/system/xml/RRFS_JEDI.db

exit 0
