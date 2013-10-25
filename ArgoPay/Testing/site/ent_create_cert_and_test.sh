openssl x509 -in EntPushCertificate.cer -inform der -out EntPushCertificate.pem
openssl pkcs12 -nocerts -in EntPushKey.p12 -out EntPushKey.pem
cat EntPushCertificate.pem EntPushKey.pem > EntPushCertificateAndKey.pem

read -n1 -r -p "Certificate created, now test with gateway.sandbox at apple.com (press any key...)" key
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert EntPushCertificate.pem -key EntPushKey.pem
