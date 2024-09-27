awk -F'[_\\-:.]' '{print $3 $5 $5 $6 $7 $8, $0}' lst | sort -n -r
