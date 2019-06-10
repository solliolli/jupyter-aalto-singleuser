# Touch /course/gradebook.db if it does not exist.

# This is needed because sqlite3 will always make the gradebook
# without g+w permissions, which breaks our sharing of courses.  Our
# solution is to touch and chmod the gradebook.db before we start.

if [ -d /course ] ; then
    if [ ! -e /course/gradebook.db ] ; then
        touch /course/gradebook.db
        chmod 660 /course/gradebook.db
    fi
fi
