#!/usr/bin/csh

#SBATCH --time=0:30:00
##SBATCH --nodes=1 --ntasks-per-node=40
#SBATCH --constraint=cas
#SBATCH --account=g2538
#SBATCH --partition=datamove

setenv ExpID d5124_m2_jan10
setenv TAG  merra2
set YEAR_TABLE = ( 201801 )
set DAY_TABLE = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
set WORK_DIR   = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/raw_obs_wjd
set OBS_DIR     = /home/dao_ops/$ExpID/run/.../archive/obs
#set WORK_DIR = /discover/nobackup/wjdavis5
#mkdir -p $WORK_DIR
set INSTRUMENT_TABLE = "conv"

foreach Date ( `echo $YEAR_TABLE` )
        echo " ------ START TIME ------  " $Date
                    date
        echo " ---------------------------"
        set DateE = $Date
        set YYYY = `echo $Date | cut -c 1-4`
        set   MM = `echo $Date | cut -c 5-6`
        set DD = 1
        set DAY_MAX = $DAY_TABLE[$MM]
        unsetenv argv
        unset argv
        setenv argv
        foreach INSTRUMENT ( `echo $INSTRUMENT_TABLE` )
                set RES     = "d"
                mkdir -p $WORK_DIR/$INSTRUMENT/$Date
                #cd $WORK_DIR/$INSTRUMENT
                foreach Hour ( all 00 06 12 18  )
                        #echo $YYYY
                        #echo $MM
                        #echo $OBS_DIR/Y$YYYY/M$MM
                        #ls -1 $OBS_DIR/Y$YYYY/M$MM
                        pwd
                        echo $OBS_DIR
                        #ls -1 $OBS_DIR/Y$YYYY/M$MM/*ods
			#ls -1 $OBS_DIR/Y$YYYY/M$MM/D*/H*/*${INSTRUMENT}*
			#exit
                        set ods_Files = `ls -1 $OBS_DIR/Y$YYYY/M$MM/D*/H${Hour}/*${INSTRUMENT}*`                   # d5124_m2_jan10.diag_airs_aqua.20180101_00z.ods
                        echo $ods_Files
                        foreach FILE ( $ods_Files )
                                echo $FILE
                                cp -r $FILE $WORK_DIR/$INSTRUMENT/$Date
                end
        end
end

