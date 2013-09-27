//
//  APRemoteStrings.h
//  ArgoPay
//
//  Created by victor on 9/25/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#ifndef ArgoPay_APRemoteStrings_h
#define ArgoPay_APRemoteStrings_h

#ifndef APREMOTESTRINGV
#define APREMOTESTRINGV(type,k,v) extern NSString *const kRemote##type##k;
#endif

#define APREMOTESTRING(type,k) APREMOTESTRINGV(type,k,k)
#define APREMOTECMD(k)         APREMOTESTRINGV(Cmd,k,k)
#define APREMOTEPAYLOAD(k)     APREMOTESTRINGV(Payload,k,k)

// SubDomains
APREMOTESTRINGV(SubDomain, Offers,      offers)
APREMOTESTRINGV(SubDomain, Transaction, transaction)
APREMOTESTRINGV(SubDomain, Customer,    customer)

// Commands
APREMOTECMD(ConsumerGetAvailableOffers)
APREMOTECMD(ConsumerGetAvailableRewards)
APREMOTECMD(ConsActivateReward)
APREMOTECMD(ConsumerTransactionStart)
APREMOTECMD(ConsumerTransactionStatus)
APREMOTECMD(ConsumerTransactionApprove)
APREMOTECMD(ConsumerLogin)

// Payloads
APREMOTEPAYLOAD(Offers)
APREMOTEPAYLOAD(Rewards)

//
// Values
//

APREMOTESTRINGV(Value, YES, Y);
APREMOTESTRINGV(Value, NO,  N);

// Transaction Status
APREMOTESTRINGV(Value, TransactionStatusTimeOut,           T);
APREMOTESTRINGV(Value, TransactionStatusPending,           P);
APREMOTESTRINGV(Value, TransactionStatusReadyForApproval,  A);
APREMOTESTRINGV(Value, TransactionStatusInsufficientFunds, I);
APREMOTESTRINGV(Value, TransactionStatusServerCancelled,   C);


// Offer/Rewards.SortBy Values
APREMOTESTRINGV(Value, SortByNone,              W); // actually: none doesn't make sense to map to 'newest'
APREMOTESTRINGV(Value, SortByNewest,            W);
APREMOTESTRINGV(Value, SortByReadyToUse,        R);
APREMOTESTRINGV(Value, SortByAvailableToSelect, A);
APREMOTESTRINGV(Value, SortByExpiringSoon,      E);

#endif
