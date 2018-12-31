# Touch /course/gradebook.db if it does not exist.

if [ -d /course ] ; then
    if [ ! -e /course/gradebook.db ] ; then
	touch /course/gradebook.db
	chmod 660 /course/gradebook.db
    fi
fi
