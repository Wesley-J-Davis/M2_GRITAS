#!/usr/bin/csh
file=$1
#$STORAGE_DIR/$INSTRUMENT/$RES/Y$YYYY/M$MM/$file.nc4
ncdump -h $file | grep levels: | awk -F: ' { print $NF } ' | awk -F= ' { print $NF } ' | cut -d';' -f 1 > $file.attrcheck.txt
sed -i 's/"//g' $file.attrcheck.txt
cat $file.attrcheck.txt

# if check for initial gritas output
foreach line ( `awk '{print}' $file.attrcheck.txt` )
        set LINE = `echo $line`
        echo $LINE
        if ( $LINE =~ "level" ) then
                echo "run_ncrcat succeeded for $line in $file.nc4 "
        else if ( $LINE =~ "satellite" || $LINE =~ "channel" ) then
                echo "run_ncrcat succeeded for $LINE in $file.nc4 "
        else if ( $LINE =~ "channels" ) then
                echo "run_ncrcat succeeded for $LINE in $file.nc4 "
        else if ( $LINE =~ "up" ) then
                echo "run_ncrcat succeeded for $LINE in $file.nc4 "
        else
                echo "run_ncrcat failed to edit metadata properly for $file.nc4 "
                cat $file.attrcheck.txt
        endif
        unset LINE
end

# else if check for combined gritas output

ncdump -h $file > $file.attrcheck.txt
sed -i 's/"//g' $file.attrcheck.txt
cat $file.attrcheck.txt

#-a Title,global,o,c,"${title}" \
#-a ShortName,global,o,c,"${shortname}" \
#-a LongName,global,o,c,"${longname}" \
#-a VersionID,global,o,c,"${versionid}" \
#-a Format,global,o,c,"${format}" \
#-a ProcessingLevel,global,o,c,"${processing_lev}" \
#-a Conventions,global,o,c,"${conventions}" \
#-a Source,global,o,c,"${dsource}" \
#-a DataSetQuality,global,o,c,"${quality}" \
#-a Comment,global,o,c,"${comment}" \
#-a RelatedURL,global,o,c,"${url}" \
#-a MapProjection,global,o,c,"${projection}" \
#-a Datum,global,o,c,"${datum}" \
#-a ProductionDateTime,global,o,c,"${prod_date}" \
#-a Filename,global,o,c,"$granuleid" \
#-a SpatialCoverage,global,o,c,"global" \
#-a Institution,global,o,c,"NASA Global Modeling and Assimilation Office" \
#-a WesternmostLongitude,global,o,c,"-180.0" \
#-a EasternmostLongitude,global,o,c,"179.375" \
#-a SouthernmostLatitude,global,d,c, \
#-a SouthernmostLatitude,global,o,c,"-90.0" \
#-a NorthernmostLatitude,global,d,c, \
#-a NorthernmostLatitude,global,o,c,"90.0" \
#-a LatitudeResolution,global,o,c,"0.5" \
#-a LongitudeResolution,global,o,c,"0.625" \
#-a DataResolution,global,o,c,"0.5x0.625" \
#-a identifier_product_doi_authority,global,d,c, \
#-a IdentifierProductDOIAuthority,global,o,c,"${doiauthority}" \
#-a identifier_product_doi,global,d,c, \
#-a IdentifierProductDOI,global,o,c,"${doi}" \
#-a IdentifierProductDOI,global,o,c,"${doi}" \
#-a GranuleID,global,o,c,"${granuleid}" \
#-a RangeBeginningDate,global,o,c,"${begin_date}" \
#-a RangeBeginningTime,global,o,c,"${begin_time}" \
#-a RangeEndingDate,global,o,c,"${end_date}" \
#-a RangeEndingTime,global,o,c,"${end_time}" \
#-a long_name,mean_obs,o,c,"${ln_mean_obs}" \
#-a long_name,mean_oma,o,c,"${ln_mean_oma}" \
#-a long_name,mean_omf,o,c,"${ln_mean_omf}" \
#-a long_name,mean_bias,o,c,"${ln_mean_bias}" \
#-a long_name,nobs_obs,o,c,"${ln_nobs_obs}" \
#-a long_name,stdv_obs,o,c,"${ln_stdv_obs}" \
#-a long_name,stdv_oma,o,c,"${ln_stdv_oma}" \
#-a long_name,stdv_omf,o,c,"${ln_stdv_omf}" \
#-a long_name,stdv_bias,o,c,"${ln_stdv_bias}" \
#-a _FillValue,mean_obs,o,f,"1.e+15" \
#-a _FillValue,mean_oma,o,f,"1.e+15" \
#-a _FillValue,mean_omf,o,f,"1.e+15" \
#-a _FillValue,mean_bias,o,f,"1.e+15" \
#-a _FillValue,nobs_obs,o,f,"1.e+15" \
#-a _FillValue,stdv_obs,o,f,"1.e+15" \
#-a _FillValue,stdv_oma,o,f,"1.e+15" \
#-a _FillValue,stdv_omf,o,f,"1.e+15" \
#-a _FillValue,stdv_bias,o,f,"1.e+15" \
#-a units,nobs_obs,o,c,"count" \
#-a long_name,time,o,c,"time" \
#-a calendar,time,o,c,"standard" \
#-a standard_name,time,o,c,"time" \
#-a calendar,time,o,c,"standard" \
#-a units,time,o,c,"minutes since ${CurrentMonth_FirstDay} ${HOUR0}:00:00"