/opt/conda/bin/jupyter nbextension disable --sys-prefix formgrader/main --section=tree
/opt/conda/bin/jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader
/opt/conda/bin/jupyter nbextension disable --sys-prefix create_assignment/main
# course
/opt/conda/bin/jupyter nbextension disable --sys-prefix course_list/main --section=tree
/opt/conda/bin/jupyter serverextension disable --sys-prefix nbgrader.server_extensions.course_list
