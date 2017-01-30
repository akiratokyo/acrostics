//
//  AcrosticsSegue.m
//  Acrostics
//
//  Created by Luokey on 10/2/15.
//  Copyright © 2015 Vakoms. All rights reserved.
//

#import "AcrosticsSegue.h"

@implementation AcrosticsSegue

- (void)perform {
    [self.sourceViewController.navigationController pushViewController:self.destinationViewController animated:NO];
}

@end
