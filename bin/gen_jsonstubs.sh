#!/bin/bash

LOCALHOST=http://testingArgo.10.0.1.8.xip.io

NAMES=(ConsumerLogin ConsActivateOffer ConsumerGetAvailableOffers ConsActivateReward \
       ConsumerGetAvailableRewards ConsumerTransactionStart ConsumerTransactionStatus \
       ConsumerTransactionApprove ConsumerStatementSummary ConsumerStatementDetail \
       MerchantLocationSearch MerchantLocationDetail ConsumerValidateGet \
       ConsumerValidateTest )

for arg in ${NAMES[@]}
do
   curl $LOCALHOST/$arg >../ArgoPay/Testing/stubs/$arg.js
done   