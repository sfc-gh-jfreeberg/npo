stage_name=npo_stage
npo_name=my_project

snow stage create $stage_name
snow stage copy --recursive --overwrite . @$stage_name
snow notebook project create $npo_name --source @$stage_name/ --overwrite
# snow notebook project execute my_project --main-file=src/main.py