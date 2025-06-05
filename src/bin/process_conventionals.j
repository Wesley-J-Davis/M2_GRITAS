#!/bin/csh -f
set echo
#######################################################################
#                     Batch Parameters for Run Job
#######################################################################

#SBATCH --time=6:00:00
#SBATCH --nodes=1 --ntasks-per-node=40
##SBATCH --job-name=gritas_merra2-201801
#SBATCH --constraint=cas
#SBATCH --account=g2538
##@BATCH_NAME -o gcm_run.o@RSTDATE

#######################################################################
#                         System Settings
#######################################################################

umask 022

limit stacksize unlimited

#setenv RootDir  /discover/nobackup/dao_ops/TEST/M2_GRITAS/GrITAS
setenv RootDir  /gpfsm/dnb34/rgovinda/source_motel/SLES12/GrITAS-MERRA2_V2_SLES15/GrITAS
setenv BinDir   ${RootDir}/Linux/bin

setenv ExpID d5124_m2_jan10    
setenv TAG   merra2

#set YEAR_TABLE = ( 201801 )

#setenv Dir /gpfsm/dnb05/projects/p47/Ravi/MERRA-2/$ExpID
#source /gpfsm/dnb34/rgovinda/source_motel/SLES12/GrITAS-MERRA2_V2_SLES15/GrITAS/src/g5_modules
source $BinDir/g5_modules

set RC_DIR	= ${RootDir}/src/Components/gritas/GIO
set RC_File  =  ${RC_DIR}/rc_files2/gritas_upconv_merra2.rc
set RES      = 'd'
#set Gritas_Core_Opt  = "-nlevs 106 -rc $RC_File -hdf -res $RES -ncf -ospl -lb -nopassive"

#set RC_File          = ${RC_DIR}/rc_files/gritas_upconv_merra.rc
set Gritas_Core_Opt  = "-nlevs 50 -rc $RC_File -res d -ncf -ospl -lb -nopassive"
set ObsDir0      =   /discover/nobackup/projects/gmao/merra2/data/obs/.WORK
set ObsDir       =   /discover/nobackup/$user/$ExpID
set ObsDir       =   /gpfsm/dhome/dao_ops/$ExpID/run/.../archive/obs 

set Storage_Base =  $ObsDir0/products_wjd/conv/$RES
set Work_Base	 =  $ObsDir0/raw_obs_wjd/conv/$RES

set n4zip_file   = ${RC_DIR}/n4zip.csh

echo " RootDir  $RootDir"
echo " BinDir   $BinDir"
echo " RC_DIR   $RC_DIR"
echo " n4zip_dir $n4zip_file"

set gritas  = ${BinDir}/gritas.x
set grmeans = ${BinDir}/GFIO_mean_r8.x

set diag_BName = $ExpID.diag_conv_
## dmget ${ArchDir}/${diag_BName}*.${DateFrag}* &
#   wait
#   cp ${ArchDir}/${diag_BName}*.${DateFrag}* . 

set DAY_TABLE = ( 31 28 31 30 31 30 31 31 30 31 30 31 ) 
set SYNOP_TABLE = ( 00 06 12 18 )
set YEAR_TABLE = ( 201803 )
foreach YYYYMM ( `echo $YEAR_TABLE` )

   set YYYY = `echo $YYYYMM | cut -c 1-4`
   set MM   = `echo $YYYYMM | cut -c 5-6`
   set DateFrag = ${YYYY}${MM}

   set WorkDir     = ${Work_Base}/Y$YYYY/M$MM
   set STORAGE_DIR = ${Storage_Base}/Y$YYYY/M$MM

   mkdir -p $WorkDir
   mkdir -p $STORAGE_DIR

#  mkdir -p $ObsDir/obs/Y$YYYY/M$MM
#  nohup dmget $ArchDir/*conv_anl*bin $ArchDir/*conv_ges*bin 
#  nohup cp $ArchDir/*conv_anl*bin $ObsDir/obs/Y$YYYY/M$MM/
#  nohup cp $ArchDir/*conv_anl*bin $ObsDir/obs/Y$YYYY/M$MM/
#  wait

   set Day0 = 1
   set DAY_MAX = $DAY_TABLE[$MM] 

   if ( $MM == 02 ) then
    set leap = `/home/rgovinda//bin/get_leap $YYYY $MM`
    if ( $leap == 0 ) then
     set DAY_MAX = 29
    endif
   endif

   cd $WorkDir

   while ( $Day0 <= $DAY_MAX )
     set Day = $Day0
     if ( $Day0 < 10 ) then
       set Day = 0$Day0
     endif
     set Date = ${YYYY}${MM}${Day}

     set DayDir        = $STORAGE_DIR/D${Day}
     
     echo "DayDir $DayDir"
     mkdir -p ${DayDir}
     foreach Hour ( `echo $SYNOP_TABLE` )
      set DateHr = ${YYYY}${MM}${Day}_${Hour}z.bin
#    ... input observation files
#    ---------------------------
#    set diag_anl_File = /discover/nobackup/rgovinda/$ExpID/obs/Y$YYYY/M$MM/${ExpID}.diag_conv_anl.$DateHr
#    set diag_ges_File = /discover/nobackup/rgovinda/$ExpID/obs/Y$YYYY/M$MM/${ExpID}.diag_conv_ges.$DateHr
# d5124_m2_jan10.diag_conv.20180331_18z.ods
     set diag_anl_File = $ObsDir/Y$YYYY/M$MM/D$Day/${ExpID}.diag_conv_anl.$DateHr
     set diag_ges_File = $ObsDir/Y$YYYY/M$MM/D$Day/${ExpID}.diag_conv_ges.$DateHr
     nohup dmget $diag_anl_File $diag_ges_File &
#     nohup dmget  d5124_m2_jan10.diag_conv.${Date}_${Hour}z.ods &

     wait
#     cp $ObsDir/Y$YYYY/M$MM/D$Day/H${Hour}/d5124_m2_jan10.diag_conv.${Date}_${Hour}z.ods .
     cp $diag_anl_File .
#    cp $diag_ges_File . 

     set out_fileo   = gritaso${Hour}
     /bin/rm -f ${out_fileo}.{bias,stdv,nobs}.nc4

#    echo $diag_anl_File $out_fileo
#     $gritas -obs -o $out_fileo $Gritas_Core_Opt ${diag_anl_File} &
     $gritas -obs -o $out_fileo $Gritas_Core_Opt ${ExpID}.diag_conv_anl.$DateHr &
#      $gritas -obs -o $out_fileo $Gritas_Core_Opt d5124_m2_jan10.diag_conv.${Date}_${Hour}z.ods &

     wait
     exit

#     $gritas -obs -o $out_fileo $Gritas_Core_Opt d5124_m2_jan10.diag_conv.${Date}_${Hour}z.ods &

     set out_filef   = gritasf${Hour}
     /bin/rm -f ${out_filef}.{bias,stdv,nobs}.hdf
#    echo $diag_ges_File $out_filef
     $gritas -omf -o $out_filef $Gritas_Core_Opt ${diag_ges_File} &
     $gritas -omf -o $out_filef $Gritas_Core_Opt ${ExpID}.diag_conv_ges.$DateHr &

      
     set out_filea   = gritasa${Hour}
     /bin/rm -f ${out_filea}.{bias,stdv,nobs}.hdf

#    echo $diag_anl_File $out_filea
     $gritas -oma -o $out_filea $Gritas_Core_Opt ${diag_anl_File} &
     $gritas -oma -o $out_filea $Gritas_Core_Opt ${ExpID}.diag_conv_anl.$DateHr &

     wait
     ls
     ls $diag_anl_File
     ls $diag_ges_File
     ls /gpfsm/dhome/dao_ops/d5124_m2_jan10/run/.../archive/obs/Y$YYYY/M$MM/D01/d5124_m2_jan10*
     exit

     

     mv ${out_fileo}.bias.hdf ${DayDir}/$TAG.mean3d_obs_p.${Date}_${Hour}z.nc4
     mv ${out_fileo}.stdv.hdf ${DayDir}/$TAG.stdv3d_obs_p.${Date}_${Hour}z.nc4
     mv ${out_fileo}.nobs.hdf ${DayDir}/$TAG.nobs3d_obs_p.${Date}_${Hour}z.nc4


     mv ${out_filef}.bias.hdf ${DayDir}/$TAG.mean3d_omf_p.${Date}_${Hour}z.nc4
     mv ${out_filef}.stdv.hdf ${DayDir}/$TAG.stdv3d_omf_p.${Date}_${Hour}z.nc4
     mv ${out_filef}.nobs.hdf ${DayDir}/$TAG.nobs3d_omf_p.${Date}_${Hour}z.nc4

     mv ${out_filea}.bias.hdf ${DayDir}/$TAG.mean3d_oma_p.${Date}_${Hour}z.nc4
     mv ${out_filea}.stdv.hdf ${DayDir}/$TAG.stdv3d_oma_p.${Date}_${Hour}z.nc4
     mv ${out_filea}.nobs.hdf ${DayDir}/$TAG.nobs3d_oma_p.${Date}_${Hour}z.nc4

     nohup  $n4zip_file ${DayDir}/*.nc4
    end
    @ Day0 = $Day0 + 1
   end
   csh -vx ${RC_DIR}/daoit_gritas2means.csh0 ${YYYY}${MM} -r means
   csh -vx ${RC_DIR}/daoit_gritas2means.csh0 ${YYYY}${MM} -r rms
   csh -vx ${RC_DIR}/daoit_gritas2means.csh0 ${YYYY}${MM} -r obrate
end
