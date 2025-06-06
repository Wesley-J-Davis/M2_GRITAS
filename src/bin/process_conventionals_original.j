#!/bin/csh -f

#######################################################################
#                     Batch Parameters for Run Job
#######################################################################

#SBATCH --time=6:00:00
#SBATCH --nodes=1 --ntasks-per-node=40
#SBATCH --job-name=gritas_merra2-201801
#SBATCH --constraint=mil
#SBATCH --account=g0624
##@BATCH_NAME -o gcm_run.o@RSTDATE

#######################################################################
#                         System Settings
#######################################################################

umask 022

limit stacksize unlimited

setenv RootDir  /discover/nobackup/rgovinda/source_motel/SLES12/GrITAS-MERRA2_V2_SLES15/GrITAS
setenv RootDir  /discover/nobackup/dao_ops/TEST/M2_GRITAS/GrITAS
setenv BinDir   ${RootDir}/Linux/bin

setenv ExpID d5124_m2_jan10    
setenv TAG   merra2

set YEAR_TABLE = ( 2018 )
set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
set MONTH_TABLE = ( 01 )

#setenv Dir /gpfsm/dnb05/projects/p47/Ravi/MERRA-2/$ExpID

source $BinDir/g5_modules
set RC_DIR = ${RootDir}/src/Components/gritas/GIO
set RunDir   = `pwd`
set RC_File  =  ${RunDir}/rc_files2/gritas_upconv_merra2.rc
set RC_File  =  ${RC_DIR}/rc_files2/gritas_upconv_merra2.rc

set RES      = 'd'
set Gritas_Core_Opt  = "-nlevs 106 -rc $RC_File -hdf -res $RES -ncf -ospl -lb -nopassive"
 set ObsDir0      =  /discover/nobackup/$user/$ExpID
 set ObsDir0      =  /discover/nobackup/projects/gmao/merra2/data/obs/.WORK
 set ObsDir      =  /discover/nobackup/$user/$ExpID
 set ObsDir      =   /gpfsm/dnb05/projects/p47/Ravi/MERRA-2
set ObsDir       =   /gpfsm/dhome/dao_ops/$ExpID/run/.../archive

set PortArchDir =  $ObsDir0/conv/$RES
setenv Dir  $ObsDir0/conv/$RES

mkdir -p $PortArchDir

set Storage_Base =  $ObsDir0/products_wjd/conv/$RES
set Work_Base    =  $ObsDir0/raw_obs_wjd/conv/$RES


 set n4zip_file   = /home/rgovinda/bin/n4zip.csh0

 echo " RootDir  $RootDir"
 echo " BinDir   $BinDir"
 echo " RunDir   $RunDir"
 echo " n4zip_dir $n4zip_file"

 set gritas  = ${BinDir}/gritas.x
 set grmeans = ${BinDir}/GFIO_mean_r8.x

 set diag_BName = $ExpID.diag_conv_
## dmget ${ArchDir}/${diag_BName}*.${DateFrag}* &
#   wait
#   cp ${ArchDir}/${diag_BName}*.${DateFrag}* . 

set DAY_TABLE = ( 31 28 31 30 31 30 31 31 30 31 30 31 ) 
set SYNOP_TABLE = ( 00 06 12 18 )
foreach YYYY ( `echo $YEAR_TABLE` )
  foreach MM ( `echo $MONTH_TABLE` )
   set DateFrag = ${YYYY}${MM}
   set WorkDir     = $Dir/Y$YYYY/M$MM
   set STORAGE_DIR = $PortArchDir/Y$YYYY/M$MM
   set WorkDir     = ${Work_Base}/Y$YYYY/M$MM
   set STORAGE_DIR = ${Storage_Base}/Y$YYYY/M$MM
   mkdir -p $STORAGE_DIR

   mkdir -p $WorkDir

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

     set diag_anl_File = $ObsDir/obs/Y$YYYY/M$MM/D$Day/${ExpID}.diag_conv_anl.$DateHr
     set diag_ges_File = $ObsDir/obs/Y$YYYY/M$MM/D$Day/${ExpID}.diag_conv_ges.$DateHr
     nohup dmget ${diag_anl_File} 
     wait
     nohup dmget ${diag_ges_File}
     wait
     cp ${diag_anl_File} .
     cp ${diag_ges_File} .
     ls
     wait

      set out_fileo   = gritaso${Hour}
      /bin/rm -f ${out_fileo}.{bias,stdv,nobs}.nc4

#     echo $diag_anl_File $out_fileo
#      $gritas -obs -o $out_fileo $Gritas_Core_Opt ${diag_anl_File} 
#      wait
#      sleep 10
      $gritas -obs -o $out_fileo $Gritas_Core_Opt ${ExpID}.diag_conv_anl.$DateHr
      wait
      sleep 10
      exit


      set out_filef   = gritasf${Hour}
      /bin/rm -f ${out_filef}.{bias,stdv,nobs}.hdf
#     echo $diag_ges_File $out_filef
      $gritas -omf -o $out_filef $Gritas_Core_Opt ${diag_ges_File} &
      
      set out_filea   = gritasa${Hour}
     /bin/rm -f ${out_filea}.{bias,stdv,nobs}.hdf

#    echo $diag_anl_File $out_filea
     $gritas -oma -o $out_filea $Gritas_Core_Opt ${diag_anl_File} &
     wait

     

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
   csh -vx ${RunDir}/daoit_gritas2means.csh0 ${YYYY}${MM} -r means
   csh -vx ${RunDir}/daoit_gritas2means.csh0 ${YYYY}${MM} -r rms
   csh -vx ${RunDir}/daoit_gritas2means.csh0 ${YYYY}${MM} -r obrate
  end
