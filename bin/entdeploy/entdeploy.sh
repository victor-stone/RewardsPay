
echo Build: > buildinfo.txt
/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ../../ArgoPay/ArgoPay-Info.plist >> buildinfo.txt
echo "<br /> Uploaded: " >> buildinfo.txt
date >> buildinfo.txt

git log -n 5 > gitlog
grep "^[D ].*$" gitlog > buildlog.txt

FTP_SITE=ftp://timbregr@timbregroove.org/apps/daily
FTP_IPA=ftp://timbregr@timbregroove.org/apps/daily/ipa

ftp -u $FTP_SITE/buildinfo.txt buildinfo.txt;type=A
ftp -u $FTP_SITE/buildlog.txt  buildlog.txt;type=A
ftp -u $FTP_SITE/appIcon.png ../../appIcon.png
ftp -u $FTP_SITE/appIcon@2x.png ../../appIcon@2x.png
ftp -u $FTP_SITE/ArgoPay.plist entdeploy.plist;type=A
ftp -u $FTP_IPA/ArgoPay.ipa ArgoPay.ipa

