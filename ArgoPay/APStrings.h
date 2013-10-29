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
APKEYEDSTRING(kNotifyUserLoginStatus)
APKEYEDSTRING(kNotifyMessageFromRemotePush)
APKEYEDSTRING(kNotifyRemotePushPickedUp)
APKEYEDSTRING(kNotifyInactivityTimeOut)

APKEYEDSTRING(kSettingUserLoginName)
APKEYEDSTRING(kSettingUserLoginPassword)
APKEYEDSTRING(kSettingUserPIN)
APKEYEDSTRING(kSettingUserDevicePushToken)


APKEYEDSTRING(kSettingChangePassword)
APKEYEDSTRING(kSettingUserLoginOldPassword)
APKEYEDSTRING(kSettingUserLoginNewPassword)
APKEYEDSTRING(kSettingUserLoginPasswordConfirm)
APKEYEDSTRING(kSettingChangePIN)
APKEYEDSTRING(kSettingUserLoginOldPIN)
APKEYEDSTRING(kSettingUserLoginNewPIN)
APKEYEDSTRING(kSettingUserLoginPINConfirm)

APKEYEDSTRING(kSettingUserArgoPoints)
APKEYEDSTRING(kSettingUserUniqueID)
APKEYEDSTRING(kSettingUserLastLat)
APKEYEDSTRING(kSettingUserLastLong)
APKEYEDSTRING(kSettingUserFirstInvoke)
APKEYEDSTRING(kSettingUserUseGoogleMaps)

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
APKEYEDSTRING(kViewLogin)
APKEYEDSTRING(kViewMain)

APKEYEDSTRING(kSegueOffersToOfferDetail)
APKEYEDSTRING(kSegueRewardsToMerchantDetail)
APKEYEDSTRING(kSegueLocationToMerchantDetail)
APKEYEDSTRING(kSegueEmbedMerchantMap)
APKEYEDSTRING(kSegueEmbedOfferMap)
APKEYEDSTRING(kSegueCameraUnwind)
APKEYEDSTRING(kSegueTransactionBill)
APKEYEDSTRING(kSegueLocationsToPinMap)
APKEYEDSTRING(kSegueNearyByMapEmbedding)
APKEYEDSTRING(kSegueSignUp1to2)
APKEYEDSTRING(kSegueSignUp2to3)
APKEYEDSTRING(kSegueSignInToGetPIN)
APKEYEDSTRING(kSegueUnwindToGetPIN)
APKEYEDSTRING(kSegueLoginToMakePIN)
APKEYEDSTRING(kSegueUnwindFromPINMaker)

APKEYEDSTRING(kCellIDMenu)
APKEYEDSTRING(kCellIDReward)
APKEYEDSTRING(kCellIDMerchantDetail)
APKEYEDSTRING(kCellIDOffer)
APKEYEDSTRING(kCellIDHistory)
APKEYEDSTRING(kCellIDLocation)
APKEYEDSTRING(kCellIDQuestion)
APKEYEDSTRING(kCellIDAnswer)
APKEYEDSTRING(kCellIDSubmit)

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
APKEYEDSTRING(kDebugPush)
