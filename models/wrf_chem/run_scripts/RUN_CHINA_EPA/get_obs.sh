#!/bin/bash
YYYY=2014
MM=07
DD=26
HH=00
#
ondate=`date "+%Y%m%d%H" -d "$YYYY-$MM-$DD $HH"`
ondatey=`date "+%Y" -d "$YYYY-$MM-$DD $HH +8 hours"`
ondatem=`date "+%m" -d "$YYYY-$MM-$DD $HH +8 hours"`
ondated=`date "+%d" -d "$YYYY-$MM-$DD $HH +8 hours"`
ondateh=`date "+%H" -d "$YYYY-$MM-$DD $HH +8 hours"`

nextdate=`date "+%Y%m%d%H" -d "$YYYY-$MM-$DD $HH +1 hours"`
nextdatey=`date "+%Y" -d "$YYYY-$MM-$DD $HH +9 hours"`
nextdatem=`date "+%m" -d "$YYYY-$MM-$DD $HH +9 hours"`
nextdated=`date "+%d" -d "$YYYY-$MM-$DD $HH +9 hours"`
nextdateh=`date "+%H" -d "$YYYY-$MM-$DD $HH +9 hours"`

predate=`date "+%Y%m%d%H" -d "$YYYY-$MM-$DD $HH -1 hours"`
predatey=`date "+%Y" -d "$YYYY-$MM-$DD $HH +7 hours"`
predatem=`date "+%m" -d "$YYYY-$MM-$DD $HH +7 hours"`
predated=`date "+%d" -d "$YYYY-$MM-$DD $HH +7 hours"`
predateh=`date "+%H" -d "$YYYY-$MM-$DD $HH +7 hours"`

ftp -n 114.212.48.14<<EOF
user forecast FtpAQF123
binary
prompt off
cd zlzang
cd airquality
cd $ondatey
cd $ondatey$ondatem
cd $ondatey$ondatem$ondated
get $ondatey$ondatem$ondated${ondateh}.txt ${ondate}.txt
bye
EOF

if [ ! -e ${ondate}.txt ]; then
	ftp -n 114.212.48.14<<EOF
	user forecast FtpAQF123
	binary
	prompt off
	cd zlzang
	cd airquality
	cd $predatey
	cd $predatey$predatem
	cd $predatey$predatem$predated
	get $predatey$predatem$predated${predateh}.txt ${predate}.txt
	bye
EOF
	if [ ! -e ${predate}.txt ]; then
		ftp -n 114.212.48.14<<EOF
	        user forecast FtpAQF123
	        binary
	        prompt off
	        cd zlzang
	        cd airquality
	        cd $nextdatey
	        cd $nextdatey$nextdatem
	        cd $nextdatey$nextdatem$nextdated
	        get $nextdatey$nextdatem$nextdated${nextdateh}.txt ${nextdate}.txt
	        bye
EOF
		if [ ! -e ${nextdate}.txt ];then
			echo 0 > getobs.out
			exit 0
		else
			echo 3 > getobs.out
			exit 0
		fi
	else
		echo 1 > getobs.out
		exit 0
	fi

else
	echo 2 > getobs.out
	exit 0
fi
