cat lst | awk -F'[_\\-:.]' '{print $3 $4 $5 $6 $7 $8, $0}' #| sort -n | awk -F' ' '{print $2}'
