//
//  AFFAlertView.h
//  Blips
//
//  Created by Jeremy Fuellert on 2014-03-11.
//  Copyright (c) 2014 AF-Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AFFAlertView;
@class AFFAlertViewButtonModel;

typedef NS_ENUM(NSUInteger, AFFAlertViewAnimationFromDirection){
    
    /** Animates the view to and from the center with an alpha animation. This closely resembles the default iOS 7 UIAlertView animation. */
    AFFAlertViewAnimationFromDirection_Center,
    
    /** Animates the view to and from the top. */
    AFFAlertViewAnimationFromDirection_Top,
    
    /** Animates the view to and from the bottom. */
    AFFAlertViewAnimationFromDirection_Bottom,
    
    /** Animates the view to and from the left. */
    AFFAlertViewAnimationFromDirection_Left,
    
    /** Animates the view to and from the right. */
    AFFAlertViewAnimationFromDirection_Right
};

@protocol AFFAlertViewDelegate <NSObject>

@optional
/** Called when an alert view button has been selected. */
- (void)alertView:(AFFAlertView *)alertView didDismissWithButton:(AFFAlertViewButtonModel *)buttonModel;

/** Called when the alert view will open. */
- (void)alertViewWillShow:(AFFAlertView *)alertView;

/** Called when the alert view has opened. */
- (void)alertViewDidShow:(AFFAlertView *)alertView;

/** Called when the alert view will close. */
- (void)alertViewWillDismss:(AFFAlertView *)alertView;

/** Called when the alert view has closed. */
- (void)alertViewDidDismss:(AFFAlertView *)alertView;

@end

/** AFFAlertView is a class used for dislpaying simple text alerts. It can be used as an alternative to UIAlertView and supports subclassing. */
NS_CLASS_AVAILABLE_IOS(5_0) @interface AFFAlertView : UIView

#pragma mark - Animation properties
/** The animation duration for showing the alert view. Default is '0.2f'. */
@property (nonatomic, assign) CGFloat showDuration;

/** The animation options for showing the alert view. Default is 'UIViewAnimationOptionCurveEaseInOut'. */
@property (nonatomic, assign) UIViewAnimationOptions showAnimationOptions;

/** The animation duration for dismissing the alert view. Default is '0.2f'. */
@property (nonatomic, assign) CGFloat dismissDuration;

/** The animation options for dismissing the alert view. Default is 'UIViewAnimationOptionCurveEaseInOut'. */
@property (nonatomic, assign) UIViewAnimationOptions dismissAnimationOptions;

/** The animation direction. This is where the AFFAlertView will animate from when showing in and where it will animate to when being dismissed. Default is 'AFFAlertViewAnimationFromDirection_Center'. */
@property (nonatomic, assign) AFFAlertViewAnimationFromDirection animationDirection;

/** The animation amount for motion effects if UIMotionEffects are available. Default value is '{25.0f, 25.0f}'. */
@property (nonatomic, assign) CGPoint motionEffectsAmount;

#pragma mark - Text properties
/** Returns title label. Default title color is '[UIColor blackColor]'. */
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/** Returns message label. Default title color is '[UIColor blackColor]'. */
@property (nonatomic, strong, readonly) UILabel *messageLabel;

/** The text color for the buttons. Default is '[UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f]'. */
@property (nonatomic, assign) UIColor *buttonTextColor;

/** The selected state text color for the buttons. Default is '[UIColor colorWithRed:15.0f/255.0f green:124.0f/255.0f blue:255.0f/255.0f alpha:1.0f]'. */
@property (nonatomic, assign) UIColor *selectedStateButtonTextColor;

#pragma mark - Background overlay properties
/** Returns the background overlay blocker view that is presented behind the alert view. Default color is '[UIColor colorWithWhite:0.0f alpha:0.45f]'. */
@property (nonatomic, strong, readonly) UIView *backgroundBlockerView;

#pragma mark - Color properties
/** The text color for the buttions. This also sets the selected background color of the button to match the border. Default is '[UIColor colorWithWhite:0.0f alpha:0.2f]'. */
@property (nonatomic, assign) UIColor *borderColor;

#pragma mark - Misc properties
/** Returns whether or not the device has motion effects. */
@property (nonatomic, readonly) BOOL hasMotionEffects;

/** The AFFAlertView delegate object. */
@property (nonatomic, weak) id<AFFAlertViewDelegate> delegate;

#pragma mark - Init
/** Returns a new AFFAlertView. */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles;

#pragma mark - Show the alert
/** Shows the alert view. */
- (void)show;

#pragma mark - Dismiss the alert
/** Manually Dismiss the alert view. */
- (void)dismiss;

@end