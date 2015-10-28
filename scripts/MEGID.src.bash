##
# 
##

# lookup meg id from subject list
# subject to change based on orgnization of google doc
# google doc location
#url=https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac

function getMEGID {
  scriptdir=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
  #scriptdir="$(cd $(dirname $0); pwd)"
  

  id=$1
  [ -z "$id" ] && echo "no id given to getMEGID!" && exit 1

  googleSheet="$scriptdir/SubjInfoGoogleSheet.txt"
  [ ! -r $googleSheet ] && echo "cannot find/open $googleSheet!" && exit 1


  #MEGID=$(curl -s "$url/export?format=tsv"| awk "(\$4==\"$id\"){print \$2}")
  #MEGID=$(awk "(\$4==\"$id\"){print \$2}" "$googleSheet" ) # awk doesn't care about white spaces, can mess up column num, 20150106WF
  #MEGID=$(perl -F"\t" -slane "print \$F[1] if(\$F[3]==\"$id\")" "$googleSheet" ) # WF20150225 -- someone updated the sheet, id is now 5th column?
  #MEGID=$(perl -F"\t" -slane "print \$F[1] if(\$F[4]==\"$id\")" "$googleSheet" )


  # 2015 07 31
  # header is
  # MEGDATE MEGID MRDATE   MRID  Task_Order_CB  WM_Response_CB Attention_Subtask_Order LunaCB   Cohort      Counts
  MEGIDidx=$(sed 1q $googleSheet | tr '	' '\n' | perl -lne 'print $.-1 and exit if /MEGID/')
     IDidx=$(sed 1q $googleSheet | tr '	' '\n' | perl -lne 'print $.-1 and exit if /MRID/')
  [ -z "$MEGIDidx" -o -z "$IDidx" ] && echo "cannot find MEGID or MRID in $googleSheet, something is wrong!" >&2 && exit 1

  MEGID=$(perl -F"\t" -slane "print \$F[$MEGIDidx] if(\$F[$IDidx]==\"$id\")" "$googleSheet" )


  ## check 
  if [[ -z "$MEGID" || ! $MEGID =~ [0-9]{4} ]]; then 
     echo "cannot find $id in sheet or '$MEGID' not as expected" >&2
     echo "see $googleSheet (pulled from google in 00_fetchData.bash)" >&2 
     exit 1
  fi


  echo $MEGID
  return 0
}
