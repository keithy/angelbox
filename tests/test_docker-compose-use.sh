#!/bin/sh


cat > /tmp/dcu_fixture << 'END'
#Start
# Comment

#
## Output
1 \
# comment

2 \
3
END

cat > /tmp/dcu_expected << 'END'
#Start
## Output
1 2 3
END


../docker-compose-use /tmp/dcu_fixture dcu_output

diff /tmp/dcu_expected dcu_output && echo "PASS"

rm /tmp/dcu_fixture /tmp/dcu_expected dcu_output