//
//  ASKPCustomerSupportViewController.h
//  AskingPointLib
//
//  Copyright (c) 2015 KnowFu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AskingPoint/ASKPCommon.h>
#import <AskingPoint/ASKPCommand.h>

@class ASKPCustomerSupportViewController;

ASKP_ASSUME_NONNULL_BEGIN

@protocol ASKPCustomerSupportViewControllerDelegate <NSObject,UINavigationControllerDelegate>

@optional
// If this method is not implemented, the customer support controller will dismiss itself on complete.
// If this is implemented, it is responsible for dismissing the customer support controller.
- (void)customerSupportViewControllerDidComplete:(ASKPCustomerSupportViewController*)customerSupportViewController;

@end

@interface ASKPCustomerSupportViewController : UINavigationController

- (instancetype)init;
- (instancetype)initWithCommand:(askp_nullable ASKPCommand*)command;

@property(nonatomic,copy, askp_null_resettable) NSString *headerMessage;

@property(nonatomic,assign, askp_nullable) id<ASKPCustomerSupportViewControllerDelegate> delegate;

@end



@class ASKPFeedbackViewController;

__attribute__ ((deprecated("Use ASKPCustomerSupportViewControllerDelegate")))
@protocol ASKPFeedbackViewControllerDelegate <NSObject,UINavigationControllerDelegate>

@optional
// If this method is not implemented, the feedback controller will dismiss itself on complete.
// If this is implemented, it is responsible for dismissing the feedback controller.
- (void)feedbackViewControllerDidComplete:(ASKPFeedbackViewController*)feedbackViewController;

@end


__attribute__ ((deprecated("Use ASKPCustomerSupportViewController")))
@interface ASKPFeedbackViewController : UINavigationController

- (instancetype)init __attribute__ ((deprecated("Use ASKPCustomerSupportViewController")));
- (instancetype)initWithCommand:(askp_nullable ASKPCommand*)command __attribute__ ((deprecated("Use ASKPCustomerSupportViewController")));

@property(nonatomic,copy, askp_null_resettable) NSString *headerMessage __attribute__ ((deprecated("Use ASKPCustomerSupportViewController")));

@property(nonatomic,assign, askp_nullable) id<ASKPFeedbackViewControllerDelegate> delegate __attribute__ ((deprecated("Use ASKPCustomerSupportViewController")));

@end

ASKP_ASSUME_NONNULL_END