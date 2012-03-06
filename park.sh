#!/bin/sh
cd `dirname $0`
LANG=C
export LANG
exec >>park.log 2>&1
/usr/bin/ruby pick.rb

n=0
dir=../httproot/default/parken
touch $dir/index.new
(for i in `cat data/flist`; do
	ln -f $i.png $dir/day-$n.png
	case "$n" in
	0)
		echo '<p>Heute:'
		;;
	1)
		echo '<p>Gestern:'
		;;
	2)
		echo '<p>Vorgestern:'
		;;
	*)
		echo "<p>Vor $n Tagen:"
		;;
	esac
	echo '<p><img src="'"day-$n.png"'">'
	n=`expr $n + 1`
done) >>$dir/index.new
# Actually, after a few days the index will never change again...
mv -f $dir/index.new $dir/index.html
