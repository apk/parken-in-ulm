#!/bin/sh
cd `dirname $0`
LANG=C
export LANG
exec >>park.log 2>&1

mkdir -p data
touch data/flist

/usr/bin/ruby pick.rb

dir=../../html/parken

n=0
(for i in `cat data/flist`; do
	ln -f $i.png $dir/day-$n.png
	ln -f $i-n.png $dir/day-$n-s.png
	# Needs gnu date, not darwin's date
	# (and of course not solaris')
	d="~ `TZ=GMT date -r $i.png +'%Y-%m-%d'`"
	case "$n" in
	0)
		echo '<p>('"$d"') (<a href=".">Nur</a>) Heute:'
		;;
	1)
		echo '<p>('"$d"') Gestern:'
		;;
	2)
		echo '<p>('"$d"') Vorgestern:'
		;;
	*)
		echo "<p>($d) Vor $n Tagen:"
		;;
	esac
	echo '<p><img src="'"day-$n.png"'">'
	n=`expr $n + 1`
done
echo '<p><a href="http://github.com/apk/parken-in-ulm/">Quellen/Wie'"'"'s geht</a> (Github)'
) >>$dir/archive.new
mv -f $dir/archive.new $dir/archive.html

n=0
(for i in `cat data/flist`; do
	# Needs gnu date, not darwin's date
	# (and of course not solaris')
	d="~ `TZ=GMT date -r $i.png +'%Y-%m-%d'`"
	case "$n" in
	0)
		echo '<p>('"$d"') Heute:'
		;;
	*)
		echo '<p><a href="archive.html">Vergangene Tage...</a>'
		echo '&middot; <a href="http://github.com/apk/parken-in-ulm/">Quellen/Wie'"'"'s geht</a> (Github)'
		break;
		;;
	esac
	echo '<p><img src="'"day-$n.png"'">'
	n=`expr $n + 1`
done) >>$dir/index.new
mv -f $dir/index.new $dir/index.html
