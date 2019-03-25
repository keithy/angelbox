#!/bin/sh

cat > /tmp/dcu_fixture << 'END'
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

cat > /tmp/dcu_fixture2 << 'END'
#2nd file appended as is

Appended
END

cat > /tmp/dcu_expected << 'END'
##From: /tmp/dcu_fixture
## Output
1 2 3
##From: /tmp/dcu_fixture2
#2nd file appended as is

Appended
END

../docker-compose-use /tmp/dcu_fixture /tmp/dcu_fixture2 dcu_output

diff /tmp/dcu_expected dcu_output && echo "PASS"

rm /tmp/dcu_fixture /tmp/dcu_fixture2 /tmp/dcu_expected dcu_output
