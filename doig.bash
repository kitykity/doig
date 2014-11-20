#!/bin/bash
# doig.bash by Susan Pitman
# Day One <- InstaGram
# Import Instagram photos into Day One.
# 11/19/2014: script created
thisDir=`pwd`

if ls ${thisDir}/links.done.doig > /dev/null  2>&1 ; then
  echo
 else
  echo "Images that have been imported:" > ${thisDir}/links.done.doig
fi
while read pageLink ; do
  if grep ${pageLink} ${thisDir}/links.done.doig >/dev/null ; then
    printf "This image has already been imported...\n"
    #sleep 1
   else
    curl -s ${pageLink} -o ${thisDir}/index.html
    imageLink=`grep "og:image" ${thisDir}/index.html | cut -d"=" -f3 | sed 's/\"//g' | sed 's/ \/>//g'`
    curl -s ${imageLink} -o ${thisDir}/photo.jpg
    imageCaption=`grep "\"caption\"" ${thisDir}/index.html | sed 's/.*caption\"\:\"//g' | cut -d"\"" -f1`
    epochDate=`grep "\"date\"" ${thisDir}/index.html | sed 's/.*\"date\"\://' | cut -d"." -f1`
    imageDate=`date -r ${epochDate} '+%m/%d/%Y %H:%m'`
    postHour=`echo ${imageDate} | cut -d" " -f2 | cut -d":" -f1`
    if [ ${postHour} -gt "12" ] ; then
      postAMPM="PM"
     else
      postAMPM="AM"
    fi
#    printf "  <item>\n    <pagelink>${pageLink}</pagelink>\n    <imagedate>${imageDate}</imagedate>\n    <imagelink>${imageLink}<imagelink>\n    <imagecaption>${imageCaption}</imagecaption>\n  </item>\n\n"
    printf "Importing image posted on ${imageDate} - `echo ${imageCaption} | cut -c1-50`\n"
    printf "${imageCaption} \n \n \nImported from Instagram.\n" | /usr/local/bin/dayone -d="${imageDate}${postAMPM}" -p="${thisDir}/photo.jpg" new > /dev/null
    echo "${pageLink}" >> ${thisDir}/links.done.doig
    sleep 5
  fi
done < ${thisDir}/links.doig
