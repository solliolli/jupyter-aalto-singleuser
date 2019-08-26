jupyter nbextension disable --sys-prefix formgrader/main --section=tree
jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader
jupyter nbextension disable --sys-prefix create_assignment/main
# course
jupyter nbextension disable --sys-prefix course_list/main --section=tree
jupyter serverextension disable --sys-prefix nbgrader.server_extensions.course_list
