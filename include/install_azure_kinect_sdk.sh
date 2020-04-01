#!/bin/sh

apt update && apt install -y expect
expect -c "
spawn apt install -y libk4a1.4 libk4a1.4-dev k4a-tools
expect \"Do you accept the EULA license terms?\"
send yes\n
expect $
exit
"