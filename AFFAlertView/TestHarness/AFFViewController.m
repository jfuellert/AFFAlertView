//
//  AFFViewController.m
//  AFFAlertView
//
//  Created by Jeremy Fuellert on 2014-03-13.
//  Copyright (c) 2014 AFApps. All rights reserved.
//

#import "AFFAlertView.h"
#import "AFFAlertViewButtonModel.h"
#import "AFFViewController.h"

@interface AFFViewController () <AFFAlertViewDelegate>

@end

@implementation AFFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createButton];
}

- (void)createButton {
    
    UIButton *button        = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    button.center           = self.view.center;
    button.backgroundColor  = [UIColor lightGrayColor];
    [button setTitle:NSLocalizedString(@"Click me", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showAlertView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - Show alert view
- (void)showAlertView {
        
    AFFAlertView *alertView = [[AFFAlertView alloc] initWithTitle:NSLocalizedString(@"Title here", nil) message:NSLocalizedString(@"Message here", nil) buttonTitles:@[NSLocalizedString(@"Cancel", nil), NSLocalizedString(@"Okay", nil)]];
    alertView.delegate      = self;
    [alertView show];
}

#pragma mark - AFFAlertViewDelegate
- (void)alertView:(AFFAlertView *)alertView didDismissWithButton:(AFFAlertViewButtonModel *)buttonModel {
    
    NSLog(@"Alert view clicked : %d - %@", buttonModel.index, buttonModel.title);
}

@end