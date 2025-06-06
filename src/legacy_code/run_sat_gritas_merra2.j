#!/bin/csh 
#!/bin/csh -f

#######################################################################
#                     Batch Parameters for Run Job
#######################################################################

#SBATCH --time=6:00:00
#SBATCH --nodes=1 --ntasks-per-node=40
#SBATCH --job-name=gritas_satmerra2-201801
#SBATCH --constraint=cas
#SBATCH --account=g0624
##@BATCH_NAME -o gcm_run.o@RSTDATE



  setenv ExpID d5124_m2_jan10
  setenv TAG  merra2

  set DAY_TABLE = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
# set YEAR_TABLE = ( 201806 201808 201809 201810 )
# set YEAR_TABLE = ( 201808 201809 201810 )
##  set YEAR_TABLE = ( 201801 )
##  set YEAR_TABLE = ( 201802 201803 )
##  set YEAR_TABLE = ( 201804 201805 )
##  set YEAR_TABLE = ( 201806 201807 201808 201809 201810 )
##  set YEAR_TABLE = ( 201811 201812 )
##  set YEAR_TABLE = ( 201901 201902 )
##  set YEAR_TABLE = ( 201903 201904 201905 201906 )
##  set YEAR_TABLE = ( 201907 201908 201909 )
##  set YEAR_TABLE = ( 201910 201911 201912 )
#  set YEAR_TABLE = ( 202001 202002 202003 )
#  set YEAR_TABLE = ( 202004 202005 202006 202007 202008 202009 )
#  set YEAR_TABLE = ( 202010 202011 202012 )
#  set YEAR_TABLE = ( 202101 202102 202103 202104 )
#  set YEAR_TABLE = ( 202106 202107 202108 202109 202110 202111 202112 )
#  set YEAR_TABLE = ( 202105 202110 202111 202112 )
#  set YEAR_TABLE = ( 202201 202202 202203 )
  set YEAR_TABLE = ( 202204 202205 202206 )

foreach Date ( `echo $YEAR_TABLE` )
  echo " ------ START TIME ------  " $Date
                    date
  echo " ---------------------------"
# set Date = 201002
  set DateE = $Date
  set YYYY = `echo $Date | cut -c 1-4`
  set   MM = `echo $Date | cut -c 5-6`
  set DD = 1
  set DAY_MAX = $DAY_TABLE[$MM]
  unsetenv argv
  unset argv
  setenv argv


  #set WORK_DIR    = $NOBACKUP/$ExpID/MERRA2/SAT
# set STORAGE_DIR = $NOBACKUP/$ExpID/MERRA2
  set WORK_DIR    = /discover/nobackup/$user/$ExpID/SAT
  set OBS_DIR     = /discover/nobackup/$user/$ExpID/obs
  set STORAGE_DIR = /discover/nobackup/$user/$ExpID/SAT
  set RC_DIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/src/GrITAS-MERRA2_V2_SLES12/GrITAS/src/Components/gritas/GIO
  mkdir -p $WORK_DIR

  cd $WORK_DIR


  set BinDir  = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/src/GrITAS-MERRA2_V2_SLES12/GrITAS/Linux/bin
  set gritas  = ${BinDir}/gritas.x

  source $BinDir/g5_modules


  set INSTRUMENT_TABLE = `cat  $RC_DIR/instrument.list`
# set INSTRUMENT_TABLE = "airs_aqua"
  set RC_TABLE         = `echo $INSTRUMENT_TABLE`

 #set INSTRUMENT_TABLE = ( "amsua_n15" "amsua_n18" "amsua_n19" "amsub_n16" "amsub_n17" "hirs3_n16" "hirs3_n17" "hirs4_metop-a" "hirs4_n18" "hirs4_n19" "iasi_metop-a" "mhs_metop-a" "mhs_n18" "mhs_n19" )
# set INSTRUMENT_TABLE = (  amsua_aqua  amsua_metop_a amsua_n15 amsua_n18 amsua_n19 atms_npp hirs4_metop_a hirs4_n18 hirs4_n19 iasi_metop_a iasi_metop_b mhs_n18 mls55_aura seviri_m08 sndrd1_g15 sndrd2_g15 sndrd3_g15 sndrd4_g15 )
  set RC_TABLE         = `echo $INSTRUMENT_TABLE`

 set kount = 0
 foreach INSTRUMENT ( `echo $INSTRUMENT_TABLE` )
  @ kount = $kount + 1
  set RCI        = $RC_TABLE[$kount]
  set INFILE     = diag_${INSTRUMENT}
  set RC_FILE    = "gritas_${RCI}_merra2.rc"
  echo $RC_FILE

  set RC_File = $RC_DIR/rc_files2/$RC_FILE
  set RES     = "d"
  if ( $INSTRUMENT == "o3lev_aura" ) then
   set Gritas_Core_Opt  = "-nlevs 48 -rc $RC_File -res $RES -ncf -ospl -lb -nopassive"
  else
   set Gritas_Core_Opt  = "-rc $RC_File -res $RES -ospl -lb -nopassive"

#      PASSIVE TEST
#  set Gritas_Core_Opt  = "-rc $RC_File -res $RES -ospl -lb "
  endif

# unlink obs
# ln -s /gpfsm/dnb02/projects/p53/merra2/intermediate/$ExpID/obs/Y$YYYY/M$MM/D$DD obs

    foreach Hour ( all 00 06 12 18 )

      if ( $Hour == all ) then
       set ods_Files = `ls -1 $OBS_DIR/Y$YYYY/M$MM/D*/*${INSTRUMENT}*ods`
       set syn_tag = ""
      else
       set ods_Files = `ls -1 $OBS_DIR/Y$YYYY/M$MM/D*/*${INSTRUMENT}*${Hour}z*ods`
       set syn_tag = "_${Hour}z"
      endif


      set out_fileo   = gritaso${Hour}
      /bin/rm -f ${out_fileo}.{bias,stdv,nobs}.nc4

      $gritas -obs -o $out_fileo $Gritas_Core_Opt ${ods_Files} & 
    
 #    ... for o-f data

      set out_filef   = gritasf${Hour}
      /bin/rm -f ${out_filef}.{bias,stdv,nobs}.nc4

      $gritas -omf -o $out_filef $Gritas_Core_Opt ${ods_Files} & 

 #    ... for o-a data

      set out_filea   = gritasa${Hour}
     /bin/rm -f ${out_filea}.{bias,stdv,nobs}.nc4

      $gritas -oma -o $out_filea $Gritas_Core_Opt ${ods_Files} &   

 #    ... for bias data

      set out_fileb   = gritasb${Hour}
     /bin/rm -f ${out_fileb}.{bias,stdv,nobs}.nc4

      $gritas -obias -o $out_fileb $Gritas_Core_Opt ${ods_Files} &     
      wait

      mkdir -p $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM

     if ($INSTRUMENT == "sbuv2_nim07" || $INSTRUMENT == "sbuv2_n07" || $INSTRUMENT == "sbuv2_n11" || $INSTRUMENT == "sbuv2_n14" || $INSTRUMENT == "sbuv2_n16" || $INSTRUMENT == "sbuv2_n17"  ) then
      mv  ${out_fileo}.bias.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      mv  ${out_fileo}.nobs.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc4 
      mv  ${out_fileo}.stdv.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc4

      mv  ${out_filef}.bias.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc4 
      mv  ${out_filef}.nobs.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      mv  ${out_filef}.stdv.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc4

      mv  ${out_filea}.bias.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc4 
      mv  ${out_filea}.nobs.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      mv  ${out_filea}.stdv.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc4

      mv  ${out_fileb}.bias.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      mv  ${out_fileb}.nobs.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      mv  ${out_fileb}.stdv.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
     else
      lats4d.sh -i ${out_fileo}.bias.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_fileo}.nobs.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_fileo}.stdv.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag} -zrev

      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc

      lats4d.sh -i ${out_filef}.bias.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_filef}.nobs.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_filef}.stdv.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag} -zrev

      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc

      lats4d.sh -i ${out_filea}.bias.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_filea}.nobs.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_filea}.stdv.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag} -zrev

      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc

      lats4d.sh -i ${out_fileb}.bias.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_fileb}.nobs.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag} -zrev
      lats4d.sh -i ${out_fileb}.stdv.nc4 -o $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag} -zrev

      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc
      $RC_DIR/run_ncrcat.csh $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv  ${out_fileo}.bias.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_fileo}.nobs.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_fileo}.stdv.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      endif


      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc ) then
        mv $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      else
        mv ${out_filef}.bias.nc4  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_filef}.nobs.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_filef}.stdv.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_filea}.bias.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_filea}.nobs.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_filea}.stdv.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_fileb}.bias.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_fileb}.nobs.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      endif

      if ( -e $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc ) then
       mv  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc  $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      else
       mv ${out_fileb}.stdv.nc4 $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      endif
     endif

      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_obs_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_obs_p.${YYYY}${MM}${syn_tag}.nc4


      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_omf_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_omf_p.${YYYY}${MM}${syn_tag}.nc4


      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_oma_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_oma_p.${YYYY}${MM}${syn_tag}.nc4

      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.mean3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.nobs3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
      n4zip $STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$TAG.${INSTRUMENT}.stdv3d_bias_p.${YYYY}${MM}${syn_tag}.nc4
  end
 end
# /bin/rm -rf $OBS_DIR/Y$YYYY/M$MM
  /bin/rm /gpfsm/dnb05/projects/p47/Ravi//MERRA-2/SAT/*nc4
  echo " ------ END  TIME ------  "
                    date
  echo " ---------------------------"
end
