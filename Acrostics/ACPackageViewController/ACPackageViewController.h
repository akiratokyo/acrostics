//  Copyright (c) 2012-2015 Egghead Games LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface ACPackageViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIActionSheetDelegate> {
    
    NSMutableArray<NSString *> *mProductIds;
    NSMutableArray<SKProduct *> *mPriceArray;
    NSInteger mRealPurchasedCount;
    NSInteger mCurrentCellTag;
}

@property (nonatomic) CGSize popOverContentSize;

@property (nonatomic) BOOL isFromList;

@property (nonatomic, readwrite) BOOL isRestorePurchases;

@end
