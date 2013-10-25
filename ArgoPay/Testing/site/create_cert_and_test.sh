openssl x509 -in PushCertificate.cer -inform der -out PushCertificate.pem
openssl pkcs12 -nocerts -in PushKey.p12 -out PushKey.pem
cat PushCertificate.pem PushKey.pem > PushCertificateAndKey.pem

read -n1 -r -p "Certificate created, now test with gateway.sandbox at apple.com (press any key...)" key
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert PushCertificate.pem -key PushKey.pem
