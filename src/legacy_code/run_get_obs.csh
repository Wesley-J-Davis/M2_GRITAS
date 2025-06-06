#!/bin/csh 

  set EXPNO = d5124_m2_jan10
  set ARCHIVE_DIR = /home/dao_ops/$EXPNO/run/.../archive/obs
#  set EXPNO = d5294_geosit_jan18
# set ARCHIVE_DIR = /discover/nobackup/projects/gmao/geos-it/dao_ops/archive/$EXPNO/obs 
  set STORAGE_DIR = /discover/nobackup/$user/$EXPNO/obs

  set WORKING_DIR = `pwd`

#    set YEAR_TABLE = ( 2018 )
#    set YEAR_TABLE = ( 2019 )
#    set YEAR_TABLE = ( 2020 )
#    set YEAR_TABLE = ( 2021 )
    set YEAR_TABLE = ( 2022 )
##  set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 )
#  set MONTH_TABLE = ( 01 )
#  set MONTH_TABLE = ( 12 )
 
  foreach YYYY ( `echo $YEAR_TABLE` )
##    set MONTH_TABLE = ( 01 02 03 04 05 06 07 08 09 10 11 12 )
##    set MONTH_TABLE = ( 01 )
##    set MONTH_TABLE = ( 06 07)
##    set MONTH_TABLE = ( 08 09)
#    set MONTH_TABLE = ( 10 ) #    set MONTH_TABLE = ( 11 )
#    set MONTH_TABLE = ( 12 )
#    set MONTH_TABLE = ( 01 02 03)
#    set MONTH_TABLE = ( 04 05 06 07 08 09)
#    set MONTH_TABLE = ( 10 11 12 )
#    set MONTH_TABLE = ( 01 02 03 04)
###### NOTE #########################################
## Y2021 M06 to M09 has some issue, revisit these months
##   set MONTH_TABLE = ( 06 07 08 09 )
### #################################################
#    set MONTH_TABLE = ( 06 07 08 09 )
#    set MONTH_TABLE = ( 10 11 12)
     set MONTH_TABLE = ( 01 02 03 )
        set ARCHIVE_DIR = /home/dao_ops/$EXPNO/run/.../archive/obs

#  foreach MM ( `echo $MONTH_TABLE` )
#   cd $ARCHIVE_DIR/Y$YYYY/M$MM
#   nohup dmget D*/H*/$EXPNO.diag_conv_anl*bin  D*/H*/$EXPNO.diag_conv_ges*bin &
#  end
#  wait

   foreach MM ( `echo $MONTH_TABLE` )
    cd $ARCHIVE_DIR/Y$YYYY/M$MM
       set DD = 1
    while ( $DD <= 31 )
     set DDe = $DD
     if ( $DD < 10 ) then
      set DDe = 0$DD
     endif
     echo  month is: $MM day is: $DDe

#     nohup dmget D$DDe/H*/$EXPNO.diag_*ods D$DDe/H*/$EXPNO.diag_*ges* D$DDe/H*/$EXPNO.diag_*anl* &
     nohup dmget D$DDe/H*/$EXPNO.diag_*ods D$DDe/H*/$EXPNO.diag_*ges* D$DDe/H*/$EXPNO.diag_*anl* &
     wait

     mkdir -p $STORAGE_DIR/Y$YYYY/M$MM/D$DDe
     nohup cp  D$DDe/H*/$EXPNO.diag_*ges* $STORAGE_DIR/Y$YYYY/M$MM/D$DDe/  &
     nohup cp  D$DDe/H*/$EXPNO.diag_*anl* $STORAGE_DIR/Y$YYYY/M$MM/D$DDe/  &
     nohup cp  D$DDe/H*/$EXPNO.diag_*ods* $STORAGE_DIR/Y$YYYY/M$MM/D$DDe/  &
     wait

     @ DD = $DD + 1
    end
  end
