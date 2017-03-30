#!/bin/bash - 
#===============================================================================
#
#          FILE: jj.sh
# 
#         USAGE: ./jj.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 03/30/17 16:49
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


echo "statting"
for i in $(seq -s " " 1 99999)
do
    echo $i
done

