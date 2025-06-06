#!/usr/bin/bash
INSTRUMENT=$1
YYYY=$2
PWD=$(pwd)
YEAR_TABLE=( ${YYYY}01 ) 
#YEAR_TABLE=( ${YYYY}01 ${YYYY}02 ${YYYY}03 ${YYYY}04 ${YYYY}05 ${YYYY}06 ${YYYY}07 ${YYYY}08 ${YYYY}09 ${YYYY}10 ${YYYY}11 ${YYYY}12 )
#YEAR_TABLE=( ${YYYY}10 ${YYYY}11 ${YYYY}12 )
for YT in ${YEAR_TABLE[@]}
do
	if [ "$INSTRUMENT" != "conv" ]; then

		echo "Executing script for: $YT $INSTRUMENT obs"
		move_data=$(sbatch -W --parsable -J ${YT}.${INSTRUMENT}.M2datamove -o ${YT}.${INSTRUMENT}.datamove.log --export=YEAR_TABLE=${YT},INSTRUMENT_TABLE=$INSTRUMENT ${PWD}/move_data.j)
	        do_gritas=$(sbatch --parsable --dependency=afterok:${move_data} -J ${YT}.${INSTRUMENT}.M2gritas -o ${YT}.${INSTRUMENT}.Gprocess.log --export=YEAR_TABLE=${YT},INSTRUMENT_TABLE=$INSTRUMENT ${PWD}/process_gritas.j)
	        sbatch --dependency=afterok:${do_gritas} -J ${YT}.${INSTRUMENT}.M2combine -o ${YT}.${INSTRUMENT}.combine.log --export=YEAR_TABLE=${YT},INSTRUMENT_TABLE=$INSTRUMENT ${PWD}/combine_output.j

	else

		echo "Executing script for $YT conventional obs"
		move_conv=$(sbatch -W --parsable -J ${YT}.${INSTRUMENT}.M2datamove -o ${YT}.${INSTRUMENT}.datamove.log --export=YEAR_TABLE=${YT},INSTRUMENT_TABLE=$INSTRUMENT ${PWD}/move_conventionals.j)
                sbatch --dependency=afterok:${move_conv} -J ${YT}.${INSTRUMENT}.M2gritas -o ${YT}.${INSTRUMENT}.Gprocess.log --export=YEAR_TABLE=${YT},INSTRUMENT_TABLE=$INSTRUMENT ${PWD}/process_conventionals.j
		exit
	fi
	echo "$YT Complete"
done
