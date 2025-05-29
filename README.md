# M2_GRITAS comprehensive obs processing scripts

```
Finds obs
Copies them to work dir
Runs them through gritas
Moves gritas output to working dir
Changes metadata
Checks metadata
Combines gritas output
Changes metadata
Checks metadata
```

## Workflow

```
./run_M2_GRITAS.sh YYYY 
  batch_wrapper.sh $YYYY 
    INSTRUMENT_LIST = `cat $RC_DIR/instrument.list` 
      for I in INSTRUMENT_LIST 
        move data with slurm, capture jobID.datamove 
        process gritas after jobID.datamove complete, capture jobID.gritas 
        process combine files after jobID.gritas completes 
```
