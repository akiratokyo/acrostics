//
//  ASKPCommand.h
//  AskingPoint
//
//  Copyright (c) 2013 KnowFu Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AskingPoint/ASKPCommon.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(NSInteger, ASKPCommandType) {
    ASKPCommandWeb = 0,               // Set for Pop-up WebView. E.g. survey
    ASKPCommandAlert = 1,             // Set for Messages, Rating Booster
    ASKPCommandPayload = 2,           // Set for Remote-Control feature
    ASKPCommandInterstitial = 3,      // Set for ad interstitials
    ASKPCommandFeedback = 4,          // Set for feedback input
    ASKPCommandLocalNotification = 5, // Set for local notification
};

typedef NS_ENUM(NSInteger, ASKPAlertType) {
    ASKPAlertUnknown = 0,               // An UNKNOWN AlertType. Should not be seen by end user Apps
    ASKPAlertRating = 1,                // Ratings Booster
    ASKPAlertMessage = 2,               // Pull Message
    ASKPAlertFeedbackOrRatingIntro = 3  // Sent when Feedback option is on. Asks if user likes App. A No response shows a Feedback widget, a Yes response shows Rating widget.
};

typedef NS_ENUM(NSInteger, ASKPAlertRatingButtonType) {
    ASKPAlertRatingNone = 0,          // An ERROR. Not a Rating Alert Button
    ASKPAlertRatingYes = 1,           // Will rate it
    ASKPAlertRatingNo = 2,            // Will not rate it
    ASKPAlertRatingRemindMe = 3       // Remind me to rate it later
};

ASKP_ASSUME_NONNULL_BEGIN

@interface ASKPCommand : NSObject
@property(nonatomic,readonly) ASKPCommandType type;
@property(nonatomic,readonly,weak,askp_nullable) ASKPCommand *parentCommand;
@property(nonatomic,readonly,askp_nullable) id commandId;
@property(nonatomic,readonly) BOOL test;                // Set to YES when shown by a Dashboard Test.
#ifdef ASKP_GENERICS_AVAILABLE
@property(nonatomic,readonly) NSSet<NSString*> *tags;              // Lists Tags set in features Dashboard Tag Editor.
#else
@property(nonatomic,readonly) NSSet *tags;              // Lists Tags set in features Dashboard Tag Editor.
#endif
@property(nonatomic,readonly,askp_nullable) NSString *requestedTag;   // Tag that triggered this.
@property(nonatomic,readonly,askp_nullable) id data;                  // Contains JSON data when Remote-Control ASKPCommandPayload
@property(nonatomic,readonly,getter=isComplete) BOOL complete; // Indicates processing of an ASKPCommand is complete.
-(void)reportComplete;                                  // Must be called when done processing Remote-Control (Payload) or else no further commands are received.
@end

@interface ASKPCommand (Web)
@property(nonatomic,readonly,askp_nullable) NSURL *url;               // URL the pop-up web view will take the user to.
@end

@class ASKPAlertButton;

@interface ASKPCommand (Alert)
@property(nonatomic,readonly) ASKPAlertType alertType;
@property(nonatomic,copy,askp_nullable) NSString *language;           // BCP 47 Language code (wikipedia.org/wiki/BCP_47).
@property(nonatomic,copy,askp_nullable) NSString *title;              // Text to show in widget title bar.
@property(nonatomic,copy,askp_nullable) NSString *message;            // Text to show in widget message body.
#ifdef ASKP_GENERICS_AVAILABLE
@property(nonatomic,readonly,askp_nullable) NSArray<ASKPAlertButton*> *buttons;  // Array of ASKPAlertButton items to show on widget.
#else
@property(nonatomic,readonly,askp_nullable) NSArray *buttons;         // Array of ASKPAlertButton items to show on widget.
#endif
-(void)reportCompleteWithButton:(askp_nullable ASKPAlertButton*)button; // Must be called when customizing Rating or Message widget look and feel and your widget is collecting button responses. This reports the user selection and prevents them being prompted again.
@end

@interface ASKPCommand (LocalNotification)
@property(nonatomic,readonly,askp_nullable) NSString *localNotificationId;
@property(nonatomic,readonly) BOOL cancelExistingNotification;
@property(nonatomic,copy,askp_nullable) NSString *soundName;   // See UILocalNotification.soundName
@property(nonatomic,copy,askp_nullable) NSString *title; // NS_AVAILABLE_IOS(8_2); // See UILocalNotification.alertTitle
@property(nonatomic,copy,askp_nullable) NSString *message;     // See UILocalNotification.alertBody
@property(nonatomic,copy,askp_nullable) NSString *alertAction; // See UILocalNotification.alertAction

@property(nonatomic,copy,askp_nullable) NSDate *fireDate;      // See UILocalNotification.fireDate
@property(nonatomic,copy,askp_nullable) NSTimeZone *timeZone;  // See UILocalNotification.timeZone

@end

@interface ASKPCommandResponse : NSObject
@property(nonatomic,readonly,askp_nullable) NSURL *url;   // On Rating widget, the "Rate It" button contains a URL to the App's app store page. On a Message widget, Custom buttons have this set to URL added to button, else nil
@property(nonatomic,readonly,askp_nullable) ASKPCommand *command; // Command that will execute when this button is pressed.
@end

@interface ASKPAlertButton : ASKPCommandResponse
@property(nonatomic,readonly) id buttonId;
@property(nonatomic,readonly) BOOL cancel;  // Follows Apple usability guidelines for Cancel buttons.
@property(nonatomic,copy) NSString *text;   // Text that is shown on button, will be in language implied by ASKPCommand language property.
@end

@interface ASKPAlertButton (Rating)
@property(nonatomic,readonly) ASKPAlertRatingButtonType ratingType;
@end

ASKP_ASSUME_NONNULL_END

#ifndef __ASKINGPOINT_NO_COMPAT

@compatibility_alias APCommand ASKPCommand; // Deprecated, use ASKPCommand
@compatibility_alias APAlertButton ASKPAlertButton; // Deprecated, use ASKPAlertButton

typedef ASKPCommandType APCommandType __attribute__ ((deprecated("Use ASKPCommandType")));
__attribute__ ((deprecated("Use ASKPCommandWeb"))) static const APCommandType APCommandWeb = ASKPCommandWeb;
__attribute__ ((deprecated("Use ASKPCommandAlert"))) static const APCommandType APCommandAlert = ASKPCommandAlert;
__attribute__ ((deprecated("Use ASKPCommandPayload"))) static const APCommandType APCommandPayload = ASKPCommandPayload;

typedef ASKPAlertType APAlertType __attribute__ ((deprecated("Use ASKPAlertType")));
__attribute__ ((deprecated("Use ASKPAlertUnknown"))) static const APAlertType APAlertUnknown = ASKPAlertUnknown;
__attribute__ ((deprecated("Use ASKPAlertRating"))) static const APAlertType APAlertRating = ASKPAlertRating;
__attribute__ ((deprecated("Use ASKPAlertMessage"))) static const APAlertType APAlertMessage = ASKPAlertMessage;

typedef ASKPAlertRatingButtonType APAlertRatingButtonType __attribute__ ((deprecated("Use ASKPAlertRatingButtonType")));
__attribute__ ((deprecated("Use ASKPAlertRatingNone"))) static const APAlertRatingButtonType APAlertRatingNone = ASKPAlertRatingNone;
__attribute__ ((deprecated("Use ASKPAlertRatingYes"))) static const APAlertRatingButtonType APAlertRatingYes = ASKPAlertRatingYes;
__attribute__ ((deprecated("Use ASKPAlertRatingNo"))) static const APAlertRatingButtonType APAlertRatingNo = ASKPAlertRatingNo;
__attribute__ ((deprecated("Use ASKPAlertRatingRemindMe"))) static const APAlertRatingButtonType APAlertRatingRemindMe = ASKPAlertRatingRemindMe;

#endif
