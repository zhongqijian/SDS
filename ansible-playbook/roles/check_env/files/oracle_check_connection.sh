#check database connection
db_user=$1
db_pass=$2
db_sid=APP_PTRDDBSVC

sqlplus  -S ${db_user}/${db_pass}@${db_sid} <<EOF
      exit;
EOF
if [[ "$?" != 0 ]];then
  echo "LOG ERROR: Check env of oracle, order is wrong.."
  exit;

fi;

c1=`sqlplus  -S ${db_user}/${db_pass}@${db_sid} <<EOF
      set heading off verify off echo off feedback off pagesize 0
      SELECT 1 from dual;
      exit;
EOF`;


if [ `echo $c1 | sed 's/ //g'` != 1 ]; then
  echo "$c1"
  echo "ERROR: Check password of user ${db_user} in ${db_sid} is wrong."

else
  echo 0

fi;

