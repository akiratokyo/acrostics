//
//  ASKPManager.h
//  AskingPoint
//
//  Copyright (c) 2012 KnowFu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AskingPoint/ASKPCommon.h>
#import <AskingPoint/ASKPCommand.h>

#if defined(__cplusplus)
#define ASKP_EXTERN extern "C"
#else
#define ASKP_EXTERN extern
#endif


@class CLLocation;

ASKP_ASSUME_NONNULL_BEGIN

// Return YES if the command was processed, NO to use the default handler
typedef BOOL (^ASKPManagerCommandHandler)(ASKPCommand *command);
typedef BOOL (^ASKPManagerTagRequestComplete)(NSString *tag, ASKPCommand * __askp_nullable command);

// To be notified of Button Selection on Ratings Booster and Message widgets
typedef void (^ASKPManagerAlertResponse)(ASKPCommand *command, ASKPAlertButton *pressed);

typedef void (^ASKPManagerPresentFeedbackController)(void);

ASKP_EXTERN NSString * const ASKPFeedbackUnreadCountChangedNotification;
ASKP_EXTERN NSString * const ASKPFeedbackUnreadCountUserInfoKey;

@interface ASKPManager : NSObject

// System root view controller
// defaults to [[[UIApplication sharedApplication] keyWindow] rootViewController]
@property(nonatomic,retain) UIViewController *rootViewController;

@property(nonatomic,copy,askp_nullable) ASKPManagerCommandHandler commandHandler;
@property(nonatomic,copy,askp_nullable) ASKPManagerAlertResponse alertResponse;
@property(nonatomic,copy,askp_nullable) ASKPManagerPresentFeedbackController presentFeedbackController;

@property(nonatomic,copy,askp_null_unspecified) NSString *gender; // @"M" or @"F"
@property(nonatomic,assign) int age;
@property(nonatomic,copy,askp_null_unspecified) CLLocation *location;
@property(nonatomic,copy,askp_null_unspecified) NSString *email;
@property(nonatomic,copy,askp_null_unspecified) NSString *userName;
@property(nonatomic,copy,askp_null_unspecified) NSString *userID;

+(ASKPManager *)sharedManager;
+(void)startup:(NSString *)apiKey;
+(void)setLocalizedAppName:(NSString*)localizedAppName;
+(NSString*)localizedAppName;

+(void)setAppVersion:(NSString*)appVersion;

+(void)addEventWithName:(NSString *)name;
+(void)startTimedEventWithName:(NSString *)name;
+(void)stopTimedEventWithName:(NSString *)name;

#ifdef ASKP_GENERICS_AVAILABLE
+(void)addEventWithName:(NSString *)name andData:(askp_nullable NSDictionary<NSString*,id> *)data;
+(void)startTimedEventWithName:(NSString *)name andData:(askp_nullable NSDictionary<NSString*,id> *)data;
+(void)stopTimedEventWithName:(NSString *)name andData:(askp_nullable NSDictionary<NSString*,id> *)data;
#else
+(void)addEventWithName:(NSString *)name andData:(askp_nullable NSDictionary *)data;
+(void)startTimedEventWithName:(NSString *)name andData:(askp_nullable NSDictionary *)data;
+(void)stopTimedEventWithName:(NSString *)name andData:(askp_nullable NSDictionary *)data;
#endif


+(void)requestCommandsWithTag:(NSString*)tag;
+(void)requestCommandsWithTag:(NSString *)tag completionHandler:(askp_nullable ASKPManagerTagRequestComplete)completionHandler;
+(void)reportAlertResponseForCommand:(ASKPCommand*)command button:(askp_nullable ASKPAlertButton*)pressed __attribute__ ((deprecated("Use ASKPCommand.reportCompleteWithButton")));

+(void)setGender:(NSString *)gender;     // @"M" or @"F"
+(void)setAge:(int)age;
+(void)setLocation:(CLLocation *)location;
+(void)setEmail:(NSString*)email;
+(void)setUserName:(NSString*)userName;
+(void)setUserID:(NSString*)userID; // This value must be globally unique for the user

+(void)sendIfNeeded;

+(void)setOptedOut:(BOOL)optedOut;
+(BOOL)optedOut;

+(NSUInteger)unreadFeedbackCount;

+(BOOL)canShowRatingPrompt;
+(BOOL)showRatingPrompt;

// System root view controller
// defaults to [[[UIApplication sharedApplication] keyWindow] rootViewController]
+(void)setRootViewController:(UIViewController*)rootViewController;

@end

ASKP_ASSUME_NONNULL_END

#ifndef __ASKINGPOINT_NO_COMPAT

@compatibility_alias APManager ASKPManager;

typedef ASKPManagerCommandHandler APManagerCommandHandler __attribute__ ((deprecated("Use ASKPManagerCommandHandler")));
typedef ASKPManagerAlertResponse APManagerAlertResponse __attribute__ ((deprecated("Use ASKPManagerAlertResponse")));
typedef ASKPManagerTagRequestComplete APManagerTagRequestComplete __attribute__ ((deprecated("Use ASKPManagerTagRequestComplete")));

#endif