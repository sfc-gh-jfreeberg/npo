stage_name=npo_stage2
npo_name=my_project2

snow stage create $stage_name
snow stage copy --recursive --overwrite . @$stage_name
snow notebook project create $npo_name --source @$stage_name/ --overwrite
snow notebook project execute $npo_name --main-file=src/udf_example.py