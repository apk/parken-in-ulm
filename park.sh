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
	ln -f $i-n.png $dir/day-$n-s.png
	d=`echo $n * 86400 | bc`
	d="`date -r $d +'%Y-%m-%d'`"
	case "$n" in
	0)
		echo '<p>('"$d"') Heute:'
		;;
	1)
		echo '<p>('"$d"') Gestern:'
		;;
	2)
		echo '<p>('"$d"') Vorgestern:'
		;;
	*)
		echo "<p>('"$d"') Vor $n Tagen:"
		;;
	esac
	echo '<p><img src="'"day-$n.png"'">'
	n=`expr $n + 1`
done) >>$dir/index.new
mv -f $dir/index.new $dir/index.html
