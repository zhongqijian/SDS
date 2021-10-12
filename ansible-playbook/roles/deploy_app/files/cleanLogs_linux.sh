#!/bin/sh

#前置服务器日志
CLEANPATHS[0]=/home/ptd/logs
CLEANPATHS[1]=/home/ptd/tomcat7_cometDServer/logs
CLEANPATHS[2]=/home/ptd/tomcat7_postrade/logs
KEEPDAYS=$1

KEEPDAYSTMP=`echo $KEEPDAYS | bc 2>/dev/null`

#判断第一个参数是不是数字
if [ $KEEPDAYS != $KEEPDAYSTMP ]
then
  echo "The first parameter is not a number [$KEEPDAYS]"
  exit
fi

#main

for CLEANPATH in ${CLEANPATHS[@]}
do

	if [ ! -d $CLEANPATH ]
	then
		echo "$CLEANPATH is not exist in current host machine `hostname`"
		continue
	fi

	if [ -f "$CLEANPATH/catalina.out" ]
	then
		cp $CLEANPATH/catalina.out $CLEANPATH/catalina.out.`date +'%Y%m%d%H%M%S'`
		echo "" > $CLEANPATH/catalina.out
	fi
	TARFILE=""
	RMTAR=""
	cd $CLEANPATH
	for DIRFILE in `ls`
	do
	  if [ -d $DIRFILE ]
	  then
		 echo "$DIRFILE is dir,continue"
		 continue
	  fi
	  if [[ $DIRFILE =~ ".tar" ]]
	  then
		SEC=`stat -c %Y $DIRFILE | awk '{printf $0" ";system("date +%s")}' | awk '{print $2-$1}'`
		DAY=`expr ${SEC} / 86400`
		if [ $DAY -gt $KEEPDAYS ]
		then
		  RMTAR+=$DIRFILE
		  RMTAR+=" "
		fi
	  else
		SEC=`stat -c %Y $DIRFILE | awk '{printf $0" ";system("date +%s")}' | awk '{print $2-$1}'`
		DAY=`expr ${SEC} / 86400`
		if [ $DAY -ge 3 ]
		then
		  TARFILE+=$DIRFILE
		  TARFILE+=" "
		fi
	  fi
	done
	#清理打包文件
	echo "clean tar: $RMTAR"
	rm -rf $RMTAR

	TARFILECNT=`echo $TARFILE | sed 's/^ //;s/ $//' |wc -m`
	#echo "TARFILECNT $TARFILECNT"
	if [ $TARFILECNT -gt 1 ]
	then
	  #打包
	  TARNAME="LOG_"
	  TARNAME+=`date +'%Y%m%d%H%M%S'`
	  TARNAME+=".tar"
	  echo "tar: $TARFILE"
	  #rm -rf $TARNAME
	  tar -cf $TARNAME $TARFILE
	  gzip  $TARNAME
	  #清理昨天以前日志文件
	  rm -rf $TARFILE
	fi
done

