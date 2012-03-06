#!/bin/sh
cd `dirname $0`
LANG=C
export LANG
exec >>park.log 2>&1
/usr/bin/ruby pick.rb

n=0
dir=../httproot/default/parken
touch $dir/index.new
for i in `cat data/flist`; do
	ln -f $i.png $dir/day-$n.png
	echo '<p><img src="'"day-$n.png"'">' >>$dir/index.new
	n=`expr $n + 1`
done
# Actually, after a few days the index will never change again...
mv -f $dir/index.new $dir/index.html
