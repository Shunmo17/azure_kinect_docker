#!/bin/sh

expect -c "
set timeout 10
spawn apt install -y libk4a1.3 libk4a1.3-dev k4a-tools
expect \"Do you accept the EULA license terms?\"
send \"yes\n\"
expect \"\\\$\"
exit 0
"