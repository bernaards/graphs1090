#!/bin/sh
#set -eu

hostname="${COLLECTD_HOSTNAME:-localhost}"
interval="${COLLECTD_INTERVAL:-60}"

while true; do
   offset=U
   sys_jitter=U
   clk_jitter=U

   eval "$(
     curl -s http://192.168.86.235/ntp-data | perl -ne '@m = $_ =~ m/(offset|sys_jitter|clk_jitter)=(\S+)/xgc; while ($k=shift @m, $v=shift @m) {$v=~s/,$//g;printf("%s=%s\n", $k, $v);}'
   )"

   if [ "$offset" = U ] && [ "$sys_jitter" = U ] && [ "$clk_jitter" = U ]; then
      break
   fi

   echo "PUTVAL \"$hostname/ntpq/gauge-offset\" interval=$interval N:$offset"
   echo "PUTVAL \"$hostname/ntpq/gauge-sys_jitter\" interval=$interval N:$sys_jitter"
   echo "PUTVAL \"$hostname/ntpq/gauge-clk_jitter\" interval=$interval N:$clk_jitter"
   sleep "$interval"
done
