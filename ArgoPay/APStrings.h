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

APKEYEDSTRING(kNotifyScanComplete)
APKEYEDSTRING(kNotifyTransactionUserActed)
APKEYEDSTRING(kNotifyUserLoginStatusChanged)
APKEYEDSTRING(kNotifyUserSettingChanged)

APKEYEDSTRING(kSettingUserLoginName)
APKEYEDSTRING(kSettingUserLoginPassword)
APKEYEDSTRING(kSettingUserArgoPoints)

APKEYEDSTRING(kSettingSlidingCameraView)

APKEYEDSTRING(kSettingDebug)
APKEYEDSTRING(kSettingDebugNetworkStubbed)
APKEYEDSTRING(kSettingDebugNetworkDelay)
APKEYEDSTRING(kSettingDebugNetworkSSL)
APKEYEDSTRING(kSettingDebugLocalhostAddr)
APKEYEDSTRING(kSettingDebugStrictJSON)

APKEYEDSTRING(kViewAccount)
APKEYEDSTRING(kViewError)
APKEYEDSTRING(kViewHistory)
APKEYEDSTRING(kViewHome)
APKEYEDSTRING(kViewLogin)
APKEYEDSTRING(kViewMain)
APKEYEDSTRING(kViewMerchantDetail)
APKEYEDSTRING(kViewOffers)
APKEYEDSTRING(kViewOfferDetail)
APKEYEDSTRING(kViewPlaces)
APKEYEDSTRING(kViewRewards)
APKEYEDSTRING(kViewScanner)
APKEYEDSTRING(kViewSettings)
APKEYEDSTRING(kViewTransaction)

APKEYEDSTRING(kSegueMainEmbedding)

APKEYEDSTRING(kCellIDMenu)
APKEYEDSTRING(kCellIDReward)
APKEYEDSTRING(kCellIDMerchantDetail)
APKEYEDSTRING(kCellIDOffer)
APKEYEDSTRING(kCellIDHistory)
APKEYEDSTRING(kCellIDLocation)

APKEYEDSTRING(kImageAccount)
APKEYEDSTRING(kImageBack)
APKEYEDSTRING(kImageBlackSq)
APKEYEDSTRING(kImageBanner)
APKEYEDSTRING(kImageButtonBg)
APKEYEDSTRING(kImageErrorBalloon)
APKEYEDSTRING(kImageFavorite)
APKEYEDSTRING(kImageHelp)
APKEYEDSTRING(kImageHistory)
APKEYEDSTRING(kImageHome)
APKEYEDSTRING(kImageLocation)
APKEYEDSTRING(kImageLocationCircle)
APKEYEDSTRING(kImageLogin)
APKEYEDSTRING(kImageLogout)
APKEYEDSTRING(kImageLogoutHome)
APKEYEDSTRING(kImageMapList);
APKEYEDSTRING(kImageMapView);
APKEYEDSTRING(kImageOffers)
APKEYEDSTRING(kImagePopupBG)
APKEYEDSTRING(kImageProfile)
APKEYEDSTRING(kImageQR)
APKEYEDSTRING(kImageRewards)
APKEYEDSTRING(kImageSort)
APKEYEDSTRING(kImageSettings)
APKEYEDSTRING(kImageWhiteSq)
#define SELECTEDIMG(name) [name stringByAppendingString:@"-selected"]

APKEYEDSTRING(kDebugFire)
APKEYEDSTRING(kDebugLifetime)
APKEYEDSTRING(kDebugNetwork)
APKEYEDSTRING(kDebugViews)
APKEYEDSTRING(kDebugUser)
APKEYEDSTRING(kDebugLocation)