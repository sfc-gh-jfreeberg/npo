stage_name=npo_stage_scos
npo_name=my_scos_project

snow stage create $stage_name
snow stage copy --recursive --overwrite . @$stage_name
snow notebook project create $npo_name --source @$stage_name/ --overwrite
snow notebook project execute $npo_name --main-file=src/main.py