#!/bin/bash

# 1.) Set Root password  ==> 
#!/bin/bash
cat <<EOF | sudo passwd root
root123
root123
EOF
echo "[TASK] Password root has been reset."
