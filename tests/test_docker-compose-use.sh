#!/bin/sh

# This simple script tests the raw action of docker-compose-use

EXIT=1

cat > /tmp/dcu_services << 'END'
#Start
# Comment

#
## Output
1 \
# comment
  # indented comment
2 \
3
END

cat > /tmp/dcu_parameters_1 << 'END'
#2nd file appended as is
Appended
END

cat > /tmp/dcu_parameters_2 << 'END'
#3rd file prepended as is
Prepended
END

cat > /tmp/dcu_expected << 'END'
SERVER_FILE=/tmp/dcu_parameters_2
#3rd file prepended as is
Prepended
######################################################################
SERVICES_FILE=/tmp/dcu_services
## Output
1 2 3
######################################################################
PARAMETERS_FILE=/tmp/dcu_parameters_1
#2nd file appended as is
Appended
END


DCU_OUT=dcu_output ../docker-compose-use /tmp/dcu_services /tmp/dcu_parameters_1 /tmp/dcu_parameters_2

diff /tmp/dcu_expected dcu_output && echo "PASS" && EXIT=0

#echo "±±±"
#cat dcu_output
#echo "±±±"

rm /tmp/dcu_services /tmp/dcu_parameters_1 /tmp/dcu_parameters_2 /tmp/dcu_expected dcu_output

exit $EXIT