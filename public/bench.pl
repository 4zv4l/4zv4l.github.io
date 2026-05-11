#!/usr/bin/env perl
$|++;

$curl  = 'curl -o /dev/null -s -w "%{time_connect},%{time_starttransfer},%{time_total}\n"';
%urls  = (BE => 'https://pbgptest.odoo.com', CN => 'https://pbgptest.cn.odoo.com');
$fmt   = " (%s):\n  av. TTC:  %.5fs\n  av. TTFB: %.5fs\n  av. TT:   %.5fs\n";
$tries = 30;

print "Curling...\n";
for $country (sort keys %urls) {
    my @avg;
    for $i (1..$tries) {
        my @tmp = split(',', `$curl $urls{$country}`);
        $avg[$_] += $tmp[$_] / $tries for 0..2;
        print "\r$i/$tries tries for $country";
    }
    printf $fmt, $urls{$country}, @avg;
}
