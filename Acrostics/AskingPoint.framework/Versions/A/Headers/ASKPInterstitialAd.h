//
//  ASKPInterstitialAd.h
//  AskingPoint
//
//  Copyright (c) 2013 KnowFu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AskingPoint/ASKPCommon.h>
#import <AskingPoint/ASKPCommand.h>

@class ASKPInterstitialAd;

ASKP_ASSUME_NONNULL_BEGIN

@protocol ASKPInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdWillLoadAd:(ASKPInterstitialAd*)interstitialAd;
- (void)interstitialAdDidLoadAd:(ASKPInterstitialAd*)interstitialAd;
- (void)interstitialAd:(ASKPInterstitialAd*)interstitialAd didFailToLoadAdWithError:(askp_nullable NSError*)error;

- (void)interstitialAdWillAppear:(ASKPInterstitialAd*)interstitialAd;
- (void)interstitialAdWillDisappear:(ASKPInterstitialAd*)interstitialAd;
- (void)interstitialAdDidDisappear:(ASKPInterstitialAd*)interstitialAd;

- (void)didClickInterstitialAd:(ASKPInterstitialAd*)interstitialAd;
@end


@interface ASKPInterstitialAd : NSObject

@property(nonatomic, assign, askp_nullable) id<ASKPInterstitialAdDelegate> delegate;
@property(nonatomic, readonly, getter=isLoaded) BOOL loaded;
#ifdef ASKP_GENERICS_AVAILABLE
@property(nonatomic, copy, askp_nullable) NSDictionary<NSString*,id> *parameters;
#else
@property(nonatomic, copy, askp_nullable) NSDictionary *parameters;
#endif
- (BOOL)presentFromViewController:(UIViewController *)viewController;

@end

@interface ASKPInterstitialAd (ASKPCommand) <ASKPInterstitialAdDelegate>

+ (askp_nullable instancetype)interstitialAdWithCommand:(ASKPCommand*)command;

@end

ASKP_ASSUME_NONNULL_END