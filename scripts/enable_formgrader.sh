# main formgrader
jupyter nbextension enable --sys-prefix formgrader/main --section=tree
jupyter serverextension enable --sys-prefix nbgrader.server_extensions.formgrader
# create assignment notebook UI
jupyter nbextension enable --sys-prefix create_assignment/main
# course list (not used right now)
#jupyter nbextension enable --sys-prefix course_list/main --section=tree
#jupyter serverextension enable --sys-prefix nbgrader.server_extensions.course_list
