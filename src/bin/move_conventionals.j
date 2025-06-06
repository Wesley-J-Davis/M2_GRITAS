#!/usr/bin/csh

#SBATCH --time=0:30:00
##SBATCH --nodes=1 --ntasks-per-node=40
#SBATCH --constraint=cas
#SBATCH --account=g2538
#SBATCH --partition=datamove

setenv ExpID d5124_m2_jan10
setenv TAG  merra2

set DAY_TABLE = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
set WORK_DIR   = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/raw_obs_wjd
set OBS_DIR     = /home/dao_ops/$ExpID/run/.../archive/obs
#set WORK_DIR = /discover/nobackup/wjdavis5
set STORAGE_DIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/products_wjd
set RC_DIR      = /discover/nobackup/dao_ops/TEST/M2_GRITAS/GrITAS/src/Components/gritas/GIO
#mkdir -p $WORK_DIR
set INSTRUMENT_TABLE = "conv"
