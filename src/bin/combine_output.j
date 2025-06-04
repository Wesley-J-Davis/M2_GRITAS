#!/bin/csh
set echo
#SBATCH --time=0:30:00
#SBATCH --nodes=1 --ntasks-per-node=40
#SBATCH --constraint=cas
#SBATCH --account=g2538
#SBATCH --partition=preops

setenv ExpID d5124_m2_jan10
setenv TAG  merra2

set BinDir  = $NOBACKUP/TEST/M2_GRITAS/GrITAS/Linux/bin
source $BinDir/g5_modules
module load nco

setenv ESMADIR /home/dao_ops/GEOSadas-5_41_3/GEOSadas
set GEOS_BINDIR = $ESMADIR/install/bin

set DAY_TABLE = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
set WORK_DIR   = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/raw_obs_wjd
set OBS_DIR     = $WORK_DIR
set STORAGE_DIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/products_wjd
set RC_DIR      = /discover/nobackup/dao_ops/TEST/M2_GRITAS/GrITAS/src/Components/gritas/GIO
set HOST_DIR = /discover/nobackup/projects/gmao/merra2/data/obs/.WORK/products_wjd

#set YEAR_TABLE = ( 201803 )
#set INSTRUMENT_TABLE = "airs_aqua"
#set INSTRUMENT_TABLE = `cat  $RC_DIR/instrument.list`

set RC_TABLE         = `echo $INSTRUMENT_TABLE`
set RES = "d"

#set HOST_DIR     = $2
#set STORAGE_DIR  = $3
set TEMP_argv =  ( $argv )
set prod_date = `date`

set WAVELENGTH_TABLES = /discover/nobackup/rgovinda/Lucchesi/WAVELENGTH_TABLES

unset argv
setenv argv

#setenv ESMADIR /home/dao_ops/GEOSadas-5_41_3/GEOSadas
#source $ESMADIR/install/bin/g5_modules

set argv = ( $TEMP_argv )

# all 00 06 12 18
set SYNOP_TABLE = ( all 00 06 12 18)

# set INSTRUMENT_TABLE = `/bin/ls -1 $HOST_DIR`
# set INSTRUMENT_TABLE = 'amsua_metop-a'

set METADATA_TABLE = /discover/nobackup/dao_it/MEASURES/DEV/metadata.tbl
set PRODUCT_TABLE = /discover/nobackup/dao_it/MEASURES/DEV/M2_OPS_product_table.csv

foreach INSTRUMENT ( `echo $INSTRUMENT_TABLE` )
        if ( $INSTRUMENT != "conv" ) then
        # set YYYYMM_TABLE = `get_instrument_yyyymm.csh $INSTRUMENT`

                foreach YYYYMM ( `echo $YEAR_TABLE` )

                        set YYYY = `echo $YYYYMM | cut -c1-4`
                        set   MM = `echo $YYYYMM | cut -c5-6`
                        set CurrentMonth_FirstDay  = ${YYYY}${MM}01
                        set PreviousMonth_LastDay = `${GEOS_BINDIR}/tick ${CurrentMonth_FirstDay} 000000 -1 0 | cut -d' ' -f1`
                        set NextMonth             = `${GEOS_BINDIR}/tick ${CurrentMonth_FirstDay} 000000 32 0 | cut -d' ' -f1 | cut -c1-6`
                        set CurrentMonth_LastDay = `${GEOS_BINDIR}/tick ${NextMonth}01 000000 -1 0 | cut -d' ' -f1`

                        # Reformat dates
                        set yyyy = `echo ${CurrentMonth_FirstDay} | cut -c1-4`
                        set  mm  = `echo ${CurrentMonth_FirstDay} | cut -c5-6`
                        set  dd  = `echo ${CurrentMonth_FirstDay} | cut -c7-8`
                        set  CurrentMonth_FirstDay = "${yyyy}-${mm}-${dd}"

                        set yyyy = `echo ${PreviousMonth_LastDay} | cut -c1-4`
                        set   mm = `echo ${PreviousMonth_LastDay} | cut -c5-6`
                        set   dd = `echo ${PreviousMonth_LastDay} | cut -c7-8`
                        set PreviousMonth_LastDay = "${yyyy}-${mm}-${dd}"

                        set yyyy = `echo ${CurrentMonth_LastDay} | cut -c1-4`
                        set   mm = `echo ${CurrentMonth_LastDay} | cut -c5-6`
                        set   dd = `echo ${CurrentMonth_LastDay} | cut -c7-8`
                        set   CurrentMonth_LastDay = "${yyyy}-${mm}-${dd}"

                        set YKOUNT = 0
                        set IN_DIR  = $HOST_DIR/$INSTRUMENT/d/Y$YYYY/M$MM
                        set FIELD = "tb"

                        if ( $INSTRUMENT == "mhs_n18" || $INSTRUMENT == "mhs_n19" )       set FIELD = "tb_mhs"
                        if ( $INSTRUMENT == "mls55_aura" || $INSTRUMENT == "o3lev_aura" ) set FIELD = "o3"
                        if ( $INSTRUMENT == "sbuv2_n11" || $INSTRUMENT == "sbuv2_n14"  || $INSTRUMENT == "sbuv2_n16"  || $INSTRUMENT == "sbuv2_n17"  ) set FIELD = "ozone"
                        if ( $INSTRUMENT == "omieff_aura" )      set FIELD = "tco"
                        if ( $INSTRUMENT == "pcp_tmi_trmm_lnd" ) set FIELD = "pcrl"
                        if ( $INSTRUMENT == "pcp_tmi_trmm_ocn" ) set FIELD = "pcro"
                        if ( $INSTRUMENT == "sbuv2_nim07" )      set FIELD = "ozone"

                        set c = 0
                        if ( -d $IN_DIR ) then
                                set c = `ls -la $IN_DIR/ | wc -l`

                                if ($c != 2 ) then

                                        set OUT_DIR = $STORAGE_DIR/$INSTRUMENT/d/Y$YYYY/M$MM
                                        mkdir -p $OUT_DIR
                                        echo " ----------------------------"
                                        echo "      STARTING TIME          "
                                        echo "  SAT $INSTRUMENT $YYYY $MM  "
                                                     date
                                        echo " ----------------------------"

                                        foreach HOUR ( `echo $SYNOP_TABLE` )
                                                if ( $HOUR == "all" ) then
                                                        set SYNOP = ""
                                                else
                                                        set SYNOP = "_${HOUR}z"

                                                endif

                                                set kount = 0

                                                set file  = merra2.${INSTRUMENT}.${YYYY}${MM}${SYNOP}.nc4


                                                foreach MODE ( mean nobs stdv )

                                                        if (  $MODE != "nobs" ) then
                                                                time ncrename -h -O -v ${FIELD},${MODE}_bias $IN_DIR/merra2.${INSTRUMENT}.${MODE}3d_bias_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_bias_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncatted -h -O -a comments,,m,c,"bias" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_bias_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncatted -h -O -a units,${MODE}_bias,m,c,"K" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_bias_p.${YYYY}${MM}${SYNOP}.nc4
                                                        endif

                                                        time ncrename -h -O -v ${FIELD},${MODE}_obs  $IN_DIR/merra2.${INSTRUMENT}.${MODE}3d_obs_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_obs_p.${YYYY}${MM}${SYNOP}.nc4
                                                        time ncatted -h -O -a comments,,m,c,"obs" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_obs_p.${YYYY}${MM}${SYNOP}.nc4
                                                        time ncatted -h -O -a units,${MODE}_obs,m,c,"K" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_obs_p.${YYYY}${MM}${SYNOP}.nc4

                                                        if (  $MODE != "nobs" ) then
                                                                time ncrename -h -O -v ${FIELD},${MODE}_oma  $IN_DIR/merra2.${INSTRUMENT}.${MODE}3d_oma_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_oma_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncatted -h -O -a comments,,m,c,"oma" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_oma_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncatted -h -O -a units,${MODE}_oma,m,c,"K" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_oma_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncrename -h -O -v ${FIELD},${MODE}_omf $IN_DIR/merra2.${INSTRUMENT}.${MODE}3d_omf_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_omf_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncatted -h -O -a comments,,m,c,"omf" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_omf_p.${YYYY}${MM}${SYNOP}.nc4
                                                                time ncatted -h -O -a units,${MODE}_omf,m,c,"K" $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_omf_p.${YYYY}${MM}${SYNOP}.nc4

                                                                if ( $kount == 0 ) time ncrcat -h -O $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_bias_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/${file}
                                                                if ( $kount > 0 ) time ncrcat -h -A $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_bias_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/${file}
                                                        endif

                                                        time ncrcat -h -A $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_obs_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/${file}

                                                        if (  $MODE != "nobs" ) then
                                                                time ncrcat -h -A $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_oma_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/${file}
                                                                time ncrcat -h -A $OUT_DIR/merra2.${INSTRUMENT}.${MODE}3d_omf_p.${YYYY}${MM}${SYNOP}.nc4 $OUT_DIR/${file}
                                                        endif

                                                        #time ncrcat -h -O -A /discover/nobackup/rgovinda/Lucchesi/WAVELENGTH_TABLES/merra2.${INSTRUMENT}.freq_wave.*.nc4 $OUT_DIR/${file}
#                                                        time ncrcat -h -A $WAVELENGTH_TABLES/merra2.${INSTRUMENT}.freq_wave.*.nc4 $OUT_DIR/${file}

                                                        @ kount = $kount + 1
                                                end    #MODE
                                                time ncrcat -h -A $WAVELENGTH_TABLES/merra2.${INSTRUMENT}.freq_wave.*.nc4 $OUT_DIR/${file}


                                                # UPDATE GLOBAL METADTA
                                                # Extract values from lookup tables

                                                # Title
                                                set title = "`grep Title ${METADATA_TABLE} | cut -d: -f2` ${INSTRUMENT}"
                                                # ShortName
                                                set shortname = `grep $INSTRUMENT ${PRODUCT_TABLE} | cut -d, -f3`
                                                # LongName
                                                set  longname = `grep $INSTRUMENT ${PRODUCT_TABLE} | cut -d, -f2`
                                                # VersionID
                                                set versionid = `grep VersionID ${METADATA_TABLE} | cut -d: -f2`
                                                # Format
                                                set format = `grep Format ${METADATA_TABLE} | cut -d: -f2`
                                                # ProcessingLevel
                                                set  processing_lev = `grep ProcessingLevel ${METADATA_TABLE} | cut -d: -f2`
                                                # Conventions
                                                set conventions = `grep Conventions ${METADATA_TABLE} | cut -d: -f2`
                                                # Source
                                                set  dsource = `grep Source ${METADATA_TABLE} | cut -d: -f2`
                                                # DataSetQuality
                                                set quality = `grep DataSetQuality ${METADATA_TABLE} | cut -d: -f2`
                                                # Special Comment
                                                set comment = `grep Comment ${METADATA_TABLE} | cut -d: -f2`
                                                # RelatedURL
                                                set url = `grep RelatedURL ${METADATA_TABLE} | cut -d: -f2-3`
                                                # MapProjection
                                                set projection = `grep MapProjection ${METADATA_TABLE} | cut -d: -f2-3`
                                                # Datum
                                                set datum = `grep Datum ${METADATA_TABLE} | cut -d: -f2-3`

                                                # These need to be NEW values.  Delete the old names.
                                                # IdentifierProductDOIAuthority
                                                set doiauthority = `grep IdentifierProductDOIAuthority ${METADATA_TABLE} | cut -d: -f2-3`
                                                # IdentifierProductDOI
                                                set doi = `grep $INSTRUMENT ${PRODUCT_TABLE} | cut -d, -f4`

                                                #NEXT:

                                                # Adjust "units" for observation attributes.  Change from "none" to "count".
                                                # Build new long names for each variable.
                                               if ( $FIELD == "tb" ) then
                                                        set LABEL = "brightness temperature"
                                                else
                                                        set LABEL = "$FIELD"
                                                endif

                                                set ln_mean_obs = "$INSTRUMENT $LABEL mean observations"
                                                set ln_mean_oma = "$INSTRUMENT $LABEL mean O-minus-A"
                                                set ln_mean_omf = "$INSTRUMENT $LABEL mean O-minus-F"
                                                set ln_mean_bias = "$INSTRUMENT $LABEL mean bias"

                                                set ln_nobs_obs = "$INSTRUMENT $LABEL number observations"
                                                set ln_nobs_oma = "$INSTRUMENT $LABEL number O-minus-A"
                                                set ln_nobs_omf = "$INSTRUMENT $LABEL number O-minus-F"
                                                set ln_nobs_bias = "$INSTRUMENT $LABEL number bias"

                                                set ln_stdv_obs = "$INSTRUMENT $LABEL square root of variance observations"
                                                set ln_stdv_oma = "$INSTRUMENT $LABEL square root of variance O-minus-A"
                                                set ln_stdv_omf = "$INSTRUMENT $LABEL square root of variance O-minus-F"
                                                set ln_stdv_bias = "$INSTRUMENT $LABEL square root of variance bias"

                                                if ( $INSTRUMENT == "mls55_aura" || $INSTRUMENT == "o3lev_aura" ) then
                                                        set FIELD = "o3"
                                                endif

                                                if ( $INSTRUMENT == "sbuv2_n11" || $INSTRUMENT == "sbuv2_n14"  || $INSTRUMENT == "sbuv2_n16"  || $INSTRUMENT == "sbuv2_n17"  ) set FIELD = "ozone"
                                                if ( $INSTRUMENT == "omieff_aura" )      set FIELD = "tco"
                                                if ( $INSTRUMENT == "pcp_tmi_trmm_lnd" ) set FIELD = "pcrl"
                                                if ( $INSTRUMENT == "pcp_tmi_trmm_ocn" ) set FIELD = "pcro"
                                                if ( $INSTRUMENT == "sbuv2_nim07" )      set FIELD = "ozone"

                                                if ( $HOUR  == "00" ) then
                                                        echo "00"
                                                        set begin_date = ${PreviousMonth_LastDay}
                                                        set end_date = ${CurrentMonth_LastDay}
                                                        set begin_time = "21:00:00.000000"
                                                        set end_time = "02:59:59.999999"
                                                else if ( $HOUR == "06" ) then
                                                        echo "06"
                                                        set begin_date=${CurrentMonth_FirstDay}
                                                        set end_date = ${CurrentMonth_LastDay}
                                                        set begin_time = "03:00:00.000000"
                                                        set end_time = "08:59:59.999999"
                                                else if ( $HOUR == 12 ) then
                                                        echo "12"
                                                        set begin_date = ${CurrentMonth_FirstDay}
                                                        set end_date = ${CurrentMonth_LastDay}
                                                        set begin_time = "09:00:00.000000"
                                                        set end_time = "14:59:59.999999"
                                                else if ( $HOUR == 18 ) then
                                                        echo "18"
                                                        set begin_date = ${CurrentMonth_FirstDay}
                                                        set end_date = ${CurrentMonth_LastDay}
                                                        set begin_time = "15:00:00.000000"
                                                        set end_time = "20:59:59.999999"
                                                endif
                                                  set HOUR0   = $HOUR
                                                if ( "$HOUR" == "all" ) then
                                                        set HOUR0 = "00"
                                                        set granule = "$OUT_DIR/merra2.${INSTRUMENT}.${YYYY}${MM}.nc4"
                                                        set granuleid = merra2.${INSTRUMENT}.${YYYY}${MM}.nc4
                                                        set begin_date = ${PreviousMonth_LastDay}
                                                        set end_date = ${CurrentMonth_LastDay}
                                                        set begin_time = "21:00:00.000000"
                                                        set end_time = "20:59:59.999999"
                                                        echo $granule
                                                else
                                                        set granule =  "$OUT_DIR/merra2.${INSTRUMENT}.${YYYY}${MM}${SYNOP}.nc4"
                                                        set granuleid = merra2.${INSTRUMENT}.${YYYY}${MM}${SYNOP}.nc4
                                                        echo $granule
                                                endif
                                                echo " Adding metta data"
                                                ncatted -h  -O ${granule}   \
                                                        -a Title,global,o,c,"${title}" \
                                                        -a ShortName,global,o,c,"${shortname}" \
                                                        -a LongName,global,o,c,"${longname}" \
                                                        -a VersionID,global,o,c,"${versionid}" \
                                                        -a Format,global,o,c,"${format}" \
                                                        -a ProcessingLevel,global,o,c,"${processing_lev}" \
                                                        -a Conventions,global,o,c,"${conventions}" \
                                                        -a Source,global,o,c,"${dsource}" \
                                                        -a DataSetQuality,global,o,c,"${quality}" \
                                                        -a Comment,global,o,c,"${comment}" \
                                                        -a RelatedURL,global,o,c,"${url}" \
                                                        -a MapProjection,global,o,c,"${projection}" \
                                                        -a Datum,global,o,c,"${datum}" \
                                                        -a ProductionDateTime,global,o,c,"${prod_date}" \
                                                        -a Filename,global,o,c,"$granuleid" \
                                                        -a SpatialCoverage,global,o,c,"global" \
                                                        -a Institution,global,o,c,"NASA Global Modeling and Assimilation Office" \
                                                        -a WesternmostLongitude,global,o,c,"-180.0" \
                                                        -a EasternmostLongitude,global,o,c,"179.375" \
                                                        -a SouthernmostLatitude,global,d,c, \
                                                        -a SouthernmostLatitude,global,o,c,"-90.0" \
                                                        -a NorthernmostLatitude,global,d,c, \
                                                        -a NorthernmostLatitude,global,o,c,"90.0" \
                                                        -a LatitudeResolution,global,o,c,"0.5" \
                                                        -a LongitudeResolution,global,o,c,"0.625" \
                                                        -a DataResolution,global,o,c,"0.5x0.625" \
                                                        -a identifier_product_doi_authority,global,d,c, \
                                                        -a IdentifierProductDOIAuthority,global,o,c,"${doiauthority}" \
                                                        -a identifier_product_doi,global,d,c, \
                                                        -a IdentifierProductDOI,global,o,c,"${doi}" \
                                                        -a IdentifierProductDOI,global,o,c,"${doi}" \
                                                        -a GranuleID,global,o,c,"${granuleid}" \
                                                        -a RangeBeginningDate,global,o,c,"${begin_date}" \
                                                        -a RangeBeginningTime,global,o,c,"${begin_time}" \
                                                        -a RangeEndingDate,global,o,c,"${end_date}" \
                                                        -a RangeEndingTime,global,o,c,"${end_time}" \
                                                        -a long_name,mean_obs,o,c,"${ln_mean_obs}" \
                                                        -a long_name,mean_oma,o,c,"${ln_mean_oma}" \
                                                        -a long_name,mean_omf,o,c,"${ln_mean_omf}" \
                                                        -a long_name,mean_bias,o,c,"${ln_mean_bias}" \
                                                        -a long_name,nobs_obs,o,c,"${ln_nobs_obs}" \
                                                        -a long_name,stdv_obs,o,c,"${ln_stdv_obs}" \
                                                        -a long_name,stdv_oma,o,c,"${ln_stdv_oma}" \
                                                        -a long_name,stdv_omf,o,c,"${ln_stdv_omf}" \
                                                        -a long_name,stdv_bias,o,c,"${ln_stdv_bias}" \
                                                        -a _FillValue,mean_obs,o,f,"1.e+15" \
                                                        -a _FillValue,mean_oma,o,f,"1.e+15" \
                                                        -a _FillValue,mean_omf,o,f,"1.e+15" \
                                                        -a _FillValue,mean_bias,o,f,"1.e+15" \
                                                        -a _FillValue,nobs_obs,o,f,"1.e+15" \
                                                        -a _FillValue,stdv_obs,o,f,"1.e+15" \
                                                        -a _FillValue,stdv_oma,o,f,"1.e+15" \
                                                        -a _FillValue,stdv_omf,o,f,"1.e+15" \
                                                        -a _FillValue,stdv_bias,o,f,"1.e+15" \
                                                        -a units,nobs_obs,o,c,"count" \
                                                        -a long_name,time,o,c,"time" \
                                                        -a calendar,time,o,c,"standard" \
                                                        -a standard_name,time,o,c,"time" \
                                                        -a calendar,time,o,c,"standard" \
                                                        -a units,time,o,c,"minutes since ${CurrentMonth_FirstDay} ${HOUR0}:00:00"
                                                        # -a _FillValue,frequency,o,f,"1.e+15" \
                                                        # -a _FillValue,wavelength,o,f,"1.e+15" \
                                                        # $ESMADIR/install/bin/n4zip  $granule
							if ( `ncks -m -M ${granule} | wc -l ` == 167  ) then
							        echo "$file post combine_files.j attr edit check passes"
							else
								echo "$file post combine_files.j attr edit check FAILS"
								exit
                                                        $NOBACKUP/TEST/M2_GRITAS/GrITAS/src/Components/gritas/GIO/n4zip.csh $granule

                                                        echo " ----------------------------"
                                                        echo "      $SYNOP  TIME           "
                                                        echo "      $INSTRUMENT $YYYY $MM  "
                                                                date
                                                        echo " ----------------------------"

                                                        echo " ----------------------------"
                                                        echo "      ENDING  TIME           "
                                                        date
                                                        echo " ----------------------------"
                                        end    # HOUR
                                endif   # directory empty check
                        endif   # directory check
                /bin/rm $OUT_DIR/*tmp
                end      # YYYYMM
        endif    # conv check
end       # INSTRUMENT
/bin/rm /$OUT_DIR/*_p.*
