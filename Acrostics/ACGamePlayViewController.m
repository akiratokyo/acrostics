//
//  ACGamePlayViewController.m
//  Acrostics
//
//  Created by roman.andruseiko on 11/9/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import "ACGamePlayViewController.h"
#import "ACGameBoard.h"
#import <QuartzCore/QuartzCore.h>

@interface ACGamePlayViewController ()

@end

@implementation ACGamePlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initGameData];
    
    // init options button
    [[mOptionsButton layer] setBackgroundColor:[UIColor whiteColor].CGColor];
    [[mOptionsButton layer] setCornerRadius:10.0f];
    [mOptionsButton setClipsToBounds:YES];
    [mOptionsButton.titleLabel setTextColor:[UIColor blackColor]];
}

- (void)initGameData{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttons methods
- (IBAction)backPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)optionsPressed{
    
}

#pragma mark - dealloc
-(void)dealloc{
    [mBackButton release];
    [mOptionsButton release];
    [mGameBoard release];
    [super dealloc];
}

@end
