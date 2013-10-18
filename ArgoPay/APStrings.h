//
//  APStrings.h
//  ArgoPayMobile
//
//  Created by victor on 9/17/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#ifndef APKEYEDSTRING
#define APKEYEDSTRING(key) extern NSString *const key;
#endif

APKEYEDSTRING(kNotifySystemError)
APKEYEDSTRING(kNotifyErrorViewClosed)
APKEYEDSTRING(kNotifyUserSettingChanged)

APKEYEDSTRING(kSettingUserLoginName)
APKEYEDSTRING(kSettingUserLoginPassword)
APKEYEDSTRING(kSettingUserArgoPoints)
APKEYEDSTRING(kSettingUserUniqueID)
APKEYEDSTRING(kSettingUserLastLat)
APKEYEDSTRING(kSettingUserLastLong)
APKEYEDSTRING(kSettingUserFirstInvoke)

APKEYEDSTRING(kSettingSystemBuildNumber)
APKEYEDSTRING(kSettingFrequentGPS)
APKEYEDSTRING(kSettingViewAsKilometer)

APKEYEDSTRING(kSettingSlidingCameraView)

APKEYEDSTRING(kSettingDebug)
APKEYEDSTRING(kSettingDebugNetworkStubbed)
APKEYEDSTRING(kSettingDebugNetworkDelay)
APKEYEDSTRING(kSettingDebugNetworkSSL)
APKEYEDSTRING(kSettingDebugLocalhostAddr)
APKEYEDSTRING(kSettingDebugStrictJSON)
APKEYEDSTRING(kSettingDebugSendStubData)

APKEYEDSTRING(kViewError)

APKEYEDSTRING(kViewMain)


APKEYEDSTRING(kSegueOffersToOfferDetail)
APKEYEDSTRING(kSegueRewardsToMerchantDetail)
APKEYEDSTRING(kSegueLocationToMerchantDetail)
APKEYEDSTRING(kSegueEmbedMerchantMap)
APKEYEDSTRING(kSegueEmbedOfferMap)
APKEYEDSTRING(kSegueCameraUnwind)
APKEYEDSTRING(kSegueTransactionBill)


APKEYEDSTRING(kCellIDMenu)
APKEYEDSTRING(kCellIDReward)
APKEYEDSTRING(kCellIDMerchantDetail)
APKEYEDSTRING(kCellIDOffer)
APKEYEDSTRING(kCellIDHistory)
APKEYEDSTRING(kCellIDLocation)

APKEYEDSTRING(kImageBack)
APKEYEDSTRING(kImageButtonBg)
APKEYEDSTRING(kImageLogo)
APKEYEDSTRING(kImageMapList)
APKEYEDSTRING(kImageMapView)
APKEYEDSTRING(kImageOffers)
APKEYEDSTRING(kImageSort)


#define SELECTEDIMG(name) [name stringByAppendingString:@"-selected"]

APKEYEDSTRING(kDebugFire)
APKEYEDSTRING(kDebugLifetime)
APKEYEDSTRING(kDebugNetwork)
APKEYEDSTRING(kDebugViews)
APKEYEDSTRING(kDebugUser)
APKEYEDSTRING(kDebugLocation)
APKEYEDSTRING(kDebugStartup)
APKEYEDSTRING(kDebugScan)
APKEYEDSTRING(kDebugNavigation)
APKEYEDSTRING(kDebugJSONDumps)
