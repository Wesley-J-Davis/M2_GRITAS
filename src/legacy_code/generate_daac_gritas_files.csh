#!/bin/csh

    set WORK_DIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/src/GrITAS-MERRA2_V2_SLES12/GrITAS/src/Components/gritas/GIO
##   set HOST_DIR =  /gpfsm/dnb05/projects/p53/merra2/data/obs/products
# set host dir for new data starting 2018:
   set HOST_DIR = /discover/nobackup/mkarki/d5124_m2_jan10/SAT 
   set HOST_DIR = /discover/nobackup/mkarki/d5124_m2_jan10/SAT
   set HOST_DIR = /gpfsm/dnb05/projects/p53/merra2/data/obs/.WORK/products_wjd
#   set STORAGE_DIR = /gpfsm/dnb05/projects/p47/Ravi
   set STORAGE_DIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/products_wjd
#  set STORAGE_DIR = /discover/nobackup/$user/SAT
#   set YYYY = 1979
#   set YYYYe = 2023
#   set YYYY = 2001
#   set YYYYe = 2002
#   set YYYY = 2004
#   set YYYYe = 2006
#   set YYYY = 2007
#   set YYYYe = 2009
#   set YYYY = 2010
#   set YYYYe = 2015
#   set YYYY = 2016
#   set YYYYe = 2020
#   set YYYY  = 2019
#   set YYYYe = 2019
#   set YYYY  = 2000
#   set YYYYe = 2000
#   set YYYY  = 1996
#   set YYYYe = 1999
#   set YYYY  = 1990
#   set YYYYe = 1995
##   set YYYY  = 1979
##  set YYYYe = 1989
#   set YYYY  = 2018
#   set YYYYe = 2018
#   set YYYY  = 2019
#   set YYYYe = 2019
#   set YYYY  = 2020
#   set YYYYe = 2020
   set YYYY  = 2018
   set YYYYe = 2018
#   set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
#   set MONTH_TABLE = ( 01 )
   while ( $YYYY <= $YYYYe )
    set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
#    set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 )
#    set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
#    set MONTH_TABLE = ( 01 02 03 04 05 10 11 12 )

    if ( $YYYY == 1979 ) set MONTH_TABLE = ( 02 03 04 05 06 07 08 09 10 11 12 )
    if ( $YYYY == 2023 ) set MONTH_TABLE = ( 01 02 )
    foreach MM ( `echo $MONTH_TABLE` )

       set YYYYMM = ${YYYY}${MM}
    
       echo $YYYYMM
       $WORK_DIR/run_merra2_ncrcat.csh $YYYYMM $HOST_DIR $STORAGE_DIR |& tee $WORK_DIR/gritas.$YYYYMM.log
    end
    @ YYYY = $YYYY + 1
  end
