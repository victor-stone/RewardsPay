echo Build: > buildinfo.txt
/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ../../ArgoPay/ArgoPay-Info.plist >> buildinfo.txt
echo "<br /> Uploaded: " >> buildinfo.txt
date >> buildinfo.txt
ftp -u ftp://timbregr@timbregroove.org/apps/buildinfo.txt buildinfo.txt
ftp -u ftp://timbregr@timbregroove.org/apps/appIcon.png ../../appIcon.png
ftp -u ftp://timbregr@timbregroove.org/apps/appIcon@2x.png ../../appIcon@2x.png
ftp -u ftp://timbregr@timbregroove.org/apps/ArgoPay.plist entdeploy.plist
ftp -u ftp://timbregr@timbregroove.org/apps/ipa/ArgoPay.ipa ArgoPay.ipa

