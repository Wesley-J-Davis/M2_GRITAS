#!/bin/csh


   set ESMADIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/src/GrITAS-MERRA2_V2_SLES12/GrITAS/src/Components/gritas/GIO
   set HOST_DIR =  /gpfsm/dnb05/projects/p53/merra2/data/obs/products
   set STORAGE_DIR = /discover/nobackup/$user/d5124_m2_jan10
#  set STORAGE_DIR = /discover/nobackup/$user/SAT
   set YYYY = 1980
   set YYYYe = 2017

   set YYYY = 2003
   set YYYYe = 2003

   set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
   while ( $YYYY <= $YYYYe )
    set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
    if ( $YYYY == 2003 ) set MONTH_TABLE = ( 01 )
    foreach MM ( `echo $MONTH_TABLE` )

       set YYYYMM = ${YYYY}${MM}
    
       echo $YYYYMM
       $ESAMADIR/run_merra2_conv_ncrcat.csh $YYYYMM $HOST_DIR $STORAGE_DIR
    end
    @ YYYY = $YYYY + 1
  end
