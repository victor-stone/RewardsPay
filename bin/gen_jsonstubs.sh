#!/bin/bash

LOCALHOST=http://testingargo.192.168.1.2.xip.io

NAMES=(ConsumerLogin ConsActivateOffer ConsumerGetAvailableOffers ConsActivateReward \
       ConsumerGetAvailableRewards ConsumerTransactionStart ConsumerTransactionStatus \
       ConsumerTransactionApprove ConsumerStatementSummary ConsumerStatementDetail \
       MerchantLocationSearch MerchantLocationDetail)

for arg in ${NAMES[@]}
do
   curl $LOCALHOST/$arg >../ArgoPay/Testing/stubs/$arg.js
done   