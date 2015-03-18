#!/bin/bash
tmp_dir=$(mktemp -d)

rm_temp() {
rm -rf "${tmp_dir}"
rm /tmp/adblock.sed && return 0;
}

lista=/etc/squid3/adblock.acl

cat > /tmp/adblock.sed <<'EOF'
/.*\$.*/d;
/\n/d;
/.*\#.*/d;
/@@.*/d;
/^!.*/d;
s/\[\]/\[.\]/g;
s#http://#||#g;
s/\/\//||/g
s/^\[.*\]$//g;
s,[+.?&/|],\\&,g;
s#*#.*#g;
s,\$.*$,,g;
s/\\|\\|\(.*\)\^\(.*\)/\.\1\\\/\2/g;
s/\\|\\|\(.*\)/\.\1/g;
/^\.\*$/d;
/^$/d;
EOF

mv $lista "$lista".old
cd $tmp_dir
wget -nv https://easylist-downloads.adblockplus.org/easylist.txt || $(mv "$lista".old $lista && rm_temp)
sed -f /tmp/adblock.sed $(ls) >> $lista

rm_temp
