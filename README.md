# M2_GRITAS comprehensive obs processing scripts
Finds obs
Copies them to work dir
Runs them through gritas
Moves gritas output to working dir
Changes metadata
Checks metadata
Combines gritas output
Changes metadata
Checks metadata

## Workflow

./run_M2_GRITAS.sh YYYY \n
  batch_wrapper.sh $YYYY \n
    INSTRUMENT_LIST = `cat $RC_DIR/instrument.list` \n
      for I in INSTRUMENT_LIST \n
        move data with slurm, capture jobID.datamove \n
        process gritas after jobID.datamove complete, capture jobID.gritas \n
        process combine files after jobID.gritas completes \n
