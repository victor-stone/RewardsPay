#BASEFILE=ArgoPayDebugPush
#PUSHSERVER=gateway.sandbox

#BASEFILE=ArgoPayDistPush

BASEFILE=ArgoPayStore
PUSHSERVER=gateway

openssl x509 -in $BASEFILE.cer -inform der -out $BASEFILE.pem
openssl pkcs12 -nocerts -in $BASEFILE.p12 -out $BASEFILE.key
cat $BASEFILE.pem $BASEFILE.key > $BASEFILE.key.pem

read -n1 -r -p "Certificate created, now test with gateway at apple.com (press any key...)" keystroke
openssl s_client -connect $PUSHSERVER.push.apple.com:2195 -cert $BASEFILE.pem -key $BASEFILE.key
