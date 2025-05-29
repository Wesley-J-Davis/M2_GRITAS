#!/usr/bin/bash

RC_DIR=$NOBACKUP/TEST/M2_GRITAS/GrITAS/src/Components/gritas/GIO
#INSTRUMENT_TABLE=$(cat  ${RC_DIR}/instrument.list)
YYYY=$1
INSTRUMENT_TABLE="airs_aqua"
#INSTRUMENT_TABLE=( "hirs4_n19" "iasi_metop-a" "iasi_metop-b" "mhs_metop-a" "mhs_metop-b" "mhs_n18" "mhs_n19" "mls55_aura" "msu_n06" "msu_n07" "msu_n08" "msu_n09" "msu_n10" "msu_n11" "msu_n12" "msu_n14" "msu_tirosn" "o3lev_aura" "omieff_aura" "pcp_ssmi_dmsp08" "pcp_ssmi_dmsp10" "pcp_ssmi_dmsp11" "pcp_ssmi_dmsp13" "pcp_ssmi_dmsp14" "pcp_tmi_trmm_lnd" "pcp_tmi_trmm_ocn" "sbuv2_n11" "sbuv2_n14" "sbuv2_n16" "sbuv2_n17" "sbuv2_nim07" "seviri_m08" "seviri_m09" "seviri_m10" "sndrd1_g11" "sndrd1_g12" "sndrd1_g13" "sndrd1_g14" "sndrd1_g15" "sndrd2_g11" "sndrd2_g12" "sndrd2_g13" "sndrd2_g14" "sndrd2_g15" "sndrd3_g11" "sndrd3_g12" "sndrd3_g13" "sndrd3_g14" "sndrd3_g15" "sndrd4_g11" "sndrd4_g12" "sndrd4_g13" "sndrd4_g14" "sndrd4_g15" "sndr_g08_prep" "sndr_g10_prep" "sndr_g11_prep" "sndr_g12_prep" "ssmi_f08" "ssmi_f10" "ssmi_f11" "ssmi_f13" "ssmi_f14" "ssmi_f15" "ssu_n06" "ssu_n07" "ssu_n08" "ssu_n09" "ssu_n11" "ssu_n14" "ssu_tirosn" )
for I in ${INSTRUMENT_TABLE[@]}
do
	echo "Executing script for: $I"
	/usr/bin/bash $NOBACKUP/TEST/M2_GRITAS/batch_wrapper.sh $I $YYYY
done
