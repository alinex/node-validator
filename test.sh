#!/bin/bash
X=555

for server in `seq 537 544`; do
  max=3
  if test "$server" = 543; then max=4; fi
  if test "$server" = 544; then max=4; fi
  for tomcat in `seq 1 $max`; do
    echo "server $erver tomcat $tomcat"
  done
done

