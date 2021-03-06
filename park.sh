#!/bin/sh
cd `dirname $0`
LANG=C
export LANG
exec >>park.log 2>&1

mkdir -p data
touch data/flist

/usr/bin/ruby pick.rb

dir=../../html/parken

header() {
cat <<\EOF
<html>
<head>
<title>Parken in Ulm</title>
<link rel="stylesheet" type="text/css" href="http://ken.apk.li/ken.css">
</head>
<body bgcolor="white">
<ul class="blkhd"><li class="blk act">Parken</li><li class="blk"><a class="undec" href="http://tanken.apk.li/">Tanken</li></a>&nbsp;&bullet;&nbsp;<li class="blk green"><a class="undec" href="http://apk.li/">apk.li</a></li></ul>
<div class="bodybox">
<h3>Parken</h3>
EOF
}

footer() {
cat <<\EOF
</div>
</body>
</html>
EOF
}

n=0
(
 header
 for i in `cat data/flist`; do
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
footer
) >>$dir/archive.new
mv -f $dir/archive.new $dir/archive.html

n=0
(
 header
 for i in `cat data/flist`; do
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
 done
 cat tmp.frag
 footer
) >>$dir/index.new
mv -f $dir/index.new $dir/index.html
