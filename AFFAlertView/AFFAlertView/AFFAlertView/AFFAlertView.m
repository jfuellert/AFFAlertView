//
//  AFFAlertView.m
//  AF Apps
//
//  Created by Jeremy Fuellert on 2014-03-11.
//  Copyright (c) 2014 AF-Apps. All rights reserved.
//

#import "AFFAlertView.h"
#import "AFFAlertViewButtonModel.h"

#pragma mark - Private item subclassing
/** AFFAlertViewButton is a subclass of UIButton. This is private and used for altering any buttons in the class that belong to the immediate AFFAlertView class. */
@interface AFFAlertViewButton : UIButton
@end

@implementation AFFAlertViewButton
@end

/** AFFAlertViewBorder is a subclass of UIView. This is private and used for altering any borders in the class that belong to the immediate AFFAlertView class. */
@interface AFFAlertViewBorder : UIView
@end

@implementation AFFAlertViewBorder
@end

/** AFFAlertViewTextField is a subclass of UITextField. This is private and used for altering any textfields in the class that belong to the immediate AFFAlertView class. */
@interface AFFAlertViewTextField : UITextField
@end

@implementation AFFAlertViewTextField
@end

#pragma mark - Constants
//Animations
const CGFloat kAFFAlertView_DefaultShowDuration                        = 0.3f;
const CGFloat kAFFAlertView_DefaultShowAnimationOptions                = UIViewAnimationOptionCurveEaseInOut;
const CGFloat kAFFAlertView_DefaultDismissDuration                     = 0.3f;
const CGFloat kAFFAlertView_DefaultDismssAnimationOptions              = UIViewAnimationOptionCurveEaseInOut;

const CGFloat kAFFAlertView_DefaultMotionEffectsAmount                 = 10.0f;

//Padding
const CGFloat kAFFAlertView_DefaultTopTitlePadding                     = 18.5f;
const CGFloat kAFFAlertView_DefaultTopMessagePadding                   = 5.0f;
const CGFloat kAFFAlertView_DefaultTitleMessagePadding                 = 9.5f;
const CGFloat kAFFAlertView_DefaultButtonHeight                        = 44.5f;

//Border radius
const CGFloat kAFFAlertView_DefaultRoundedCornerRadius                 = 7.0f;
const CGFloat kAFFAlertView_DefaultRoundedBorderWidth                  = 0.5f;

//Font sizing
const CGFloat kAFFAlertView_DefaultTitleFontSize                       = 17.0f;
const CGFloat kAFFAlertView_DefaultMessageFontSize                     = 14.0f;
const CGFloat kAFFAlertView_DefaultButtonFontSize                      = 17.0f;

//Textfeild sizing
const CGFloat kAFFAlertView_DefaultInputFieldHeight                    = 30.0f;
const CGFloat kAFFAlertView_DefaultInputFieldPadding                   = 15.0f;
const CGFloat kAFFAlertView_DefaultInputFieldViewPadding               = 5.0f;

//Textfield borders
const CGFloat kAFFAlertView_DefaultInputFieldBorderRoundedCornerRadius = 7.0f;
const CGFloat kAFFAlertView_DefaultInputFieldBorderWidth               = 0.5f;

//Colors
#define AFFAlertView_DEFAULT_TEXT_COLOR                  [UIColor blackColor]
#define AFFAlertView_DEFAULT_SELF_VIEW_COLOR             [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:0.98f]
#define AFFAlertView_DEFAULT_BACKGROUND_VIEW_COLOR       [UIColor colorWithWhite:0.0f alpha:0.35f]
#define AFFAlertView_DEFAULT_BORDER_COLOR                [UIColor colorWithWhite:0.0f alpha:0.18f]
#define AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR           [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
const CGFloat kAFFAlertView_DarkerColorPercentage         = 0.9f;

//Preferred size
#define AFFAlertView_DEFAULT_PREFERRED_SIZE              CGSizeMake(270.0f, 124.0f)

@interface AFFAlertView () <UITextFieldDelegate> {
    
    //Horizontal effect
    UIInterpolatingMotionEffect *_motionEffectHorizontal;
    
    //Vertical effect
    UIInterpolatingMotionEffect *_motionEffectVertical;
    
    //Keyboard height
    CGFloat                     _keyboardHeightOffset;
    
    //Bottom border
    AFFAlertViewBorder          *_bottomButtonBorder;
}

@end

@implementation AFFAlertView

#pragma mark - Init
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles {
    
    return [self initWithStyle:AFFAlertViewStyle_Default title:title message:message buttonTitles:buttonTitles];
}

- (instancetype)initWithStyle:(AFFAlertViewStyle)style title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles {
    
    CGSize preferredSize = AFFAlertView_DEFAULT_PREFERRED_SIZE;
    
    self = [super initWithFrame:CGRectMake(0, 0, preferredSize.width, preferredSize.height)];
    if(self) {
        
        self.hidden = YES;
        
        //Set defaults
        _keyboardHeightOffset           = 0.0f;
        _isBeingPresented               = NO;
        _showDuration                   = kAFFAlertView_DefaultShowDuration;
        _showAnimationOptions           = kAFFAlertView_DefaultShowAnimationOptions;
        _dismissDuration                = kAFFAlertView_DefaultDismissDuration;
        _dismissAnimationOptions        = kAFFAlertView_DefaultDismssAnimationOptions;
        _animationDirection             = AFFAlertViewAnimationFromDirection_Center;
        _motionEffectsAmount            = CGPointMake(kAFFAlertView_DefaultMotionEffectsAmount, kAFFAlertView_DefaultMotionEffectsAmount);
        _buttonTextColor                = AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR;
        _selectedStateButtonTextColor   = AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR;
        _borderColor                    = AFFAlertView_DEFAULT_BORDER_COLOR;
        
        //Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        //Resizing mask
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        //Create view components
        [self createBackgroundBlockerView];
        [self createBackground];
        [self createMotionEffects];
        [self createTitle:title];
        [self createMessage:message];
        [self createAdditionalTextFields:style];
        [self createButtonsWithTitles:buttonTitles];
        [self adjustFrame];
        [self adjustBottomBorder];
    }
    return self;
}

#pragma mark - Create UI components
#pragma mark - Background blocker view
- (void)createBackgroundBlockerView {
    
    UIView *superView = [AFFAlertView superViewContainer];
    
    _backgroundBlockerView                        = [[UIView alloc] initWithFrame:superView.bounds];
    _backgroundBlockerView.backgroundColor        = AFFAlertView_DEFAULT_BACKGROUND_VIEW_COLOR;
    _backgroundBlockerView.alpha                  = 0;
    _backgroundBlockerView.autoresizingMask       = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Background
- (void)createBackground {
    
    //Background
    self.backgroundColor = AFFAlertView_DEFAULT_SELF_VIEW_COLOR;
    self.clipsToBounds   = YES;
    
    //Border and radius
    self.layer.masksToBounds = YES;
    self.layer.borderColor   = AFFAlertView_DEFAULT_BORDER_COLOR.CGColor;
    self.layer.borderWidth   = kAFFAlertView_DefaultRoundedBorderWidth;
    self.layer.cornerRadius  = kAFFAlertView_DefaultRoundedCornerRadius;
}

- (void)createMotionEffects {
    
    if(![self hasMotionEffects]) {
        return;
    }
    
    //Horizontal effect
    _motionEffectHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    _motionEffectHorizontal.minimumRelativeValue         = @( -_motionEffectsAmount.x);
    _motionEffectHorizontal.maximumRelativeValue         = @( _motionEffectsAmount.x);
    
    //Vertical effect
    _motionEffectVertical   = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    _motionEffectVertical.minimumRelativeValue           = @( -_motionEffectsAmount.y);
    _motionEffectVertical.maximumRelativeValue           = @( _motionEffectsAmount.y);
    
    UIMotionEffectGroup *motionEffectGroup              = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects                     = @[_motionEffectHorizontal, _motionEffectVertical];
    
    [self addMotionEffect:motionEffectGroup];
}

#pragma mark - Title
- (void)createTitle:(NSString *)title {
    
    _titleLabel       = [AFFAlertView createLabel:title fontSize:kAFFAlertView_DefaultTitleFontSize bold:YES];
    
    //Frame
    CGRect frame      = [AFFAlertView boundingRectForLabel:_titleLabel maxWidth:CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2)];
    frame.size.width  = CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2);
    frame.origin.x    = kAFFAlertView_DefaultTitleMessagePadding;
    frame.origin.y    = kAFFAlertView_DefaultTopTitlePadding;
    _titleLabel.frame = CGRectIntegral(frame);
    
    [self addSubview:_titleLabel];
}

#pragma mark - Message
- (void)createMessage:(NSString *)message {
    
    _messageLabel       = [AFFAlertView createLabel:message fontSize:kAFFAlertView_DefaultMessageFontSize bold:NO];
    
    //Frame
    CGRect frame        = [AFFAlertView boundingRectForLabel:_messageLabel maxWidth:CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2)];
    frame.size.width    = CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2);
    frame.origin.x      = kAFFAlertView_DefaultTitleMessagePadding;
    frame.origin.y      = CGRectGetMaxY(_titleLabel.frame) + kAFFAlertView_DefaultTopMessagePadding;
    _messageLabel.frame = CGRectIntegral(frame);
    
    [self addSubview:_messageLabel];
}

#pragma mark - Create additional text fields
- (void)createAdditionalTextFields:(AFFAlertViewStyle)style {
    
    //No style
    if(style & AFFAlertViewStyle_Default) {
        return;
    }
    
    //Plain and secure input
    if(style & AFFAlertViewStyle_PlainTextInput && style & AFFAlertViewStyle_SecureTextInput) {
        
        [self createPlainTextInput:UIRectCornerTopLeft | UIRectCornerTopRight];
        [self createSecureTextInput:UIRectCornerBottomLeft | UIRectCornerBottomRight];
        
        //Plain
    } else if(style & AFFAlertViewStyle_PlainTextInput) {
        [self createPlainTextInput:UIRectCornerAllCorners];
        
        //Secure
    } else if(style & AFFAlertViewStyle_SecureTextInput) {
        [self createSecureTextInput:UIRectCornerAllCorners];
    }
}

- (void)createPlainTextInput:(UIRectCorner)corners {
    
    //Frame
    CGRect frame             = CGRectZero;
    frame.origin.x           = kAFFAlertView_DefaultInputFieldPadding;
    frame.origin.y           = CGRectGetMaxY(_messageLabel.frame) + kAFFAlertView_DefaultTopTitlePadding;
    frame.size.width         = CGRectGetWidth(self.frame) - (CGRectGetMinX(frame) * 2);
    frame.size.height        = kAFFAlertView_DefaultInputFieldHeight;
    
    _plainTextField          = [AFFAlertView createInputLabel:frame fontSize:kAFFAlertView_DefaultMessageFontSize corners:corners secure:NO];
    _plainTextField.delegate = self;
    
    [self addSubview:_plainTextField];
}

- (void)createSecureTextInput:(UIRectCorner)corners {
    
    //Frame
    CGFloat topPosition       = 0.0f;
    
    if(_plainTextField) {
        topPosition           = CGRectGetMaxY(_plainTextField.frame) - kAFFAlertView_DefaultInputFieldBorderWidth;
    } else {
        topPosition           = CGRectGetMaxY(_messageLabel.frame) + kAFFAlertView_DefaultTopTitlePadding;
    }
    
    CGRect frame              = CGRectZero;
    frame.origin.x            = kAFFAlertView_DefaultInputFieldPadding;
    frame.origin.y            = topPosition;
    frame.size.width          = CGRectGetWidth(self.frame) - (CGRectGetMinX(frame) * 2);
    frame.size.height         = kAFFAlertView_DefaultInputFieldHeight;
    
    _secureTextField          = [AFFAlertView createInputLabel:frame fontSize:kAFFAlertView_DefaultMessageFontSize corners:corners secure:YES];
    _secureTextField.delegate = self;
    
    [self addSubview:_secureTextField];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(!_plainTextField || !_secureTextField) {
        [textField resignFirstResponder];
        return NO;
    }
    
    //Plain text
    if(textField == _plainTextField) {
        [_secureTextField becomeFirstResponder];
    }
    
    //Secure text
    if(textField == _secureTextField) {
        [_plainTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - Buttons
- (void)createButtonsWithTitles:(NSArray *)buttonTitleArray {
    
    //Create buttons from titles
    NSUInteger maxButtonCount = buttonTitleArray.count;
    NSUInteger index          = 0;
    CGRect containerRect      = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    for(NSString *title in buttonTitleArray) {
        
        //Create button
        AFFAlertViewButton *button = [self createButton:title index:index maxButtonCount:maxButtonCount containerRect:containerRect isNotBold:index == 0];
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:button atIndex:0];
        
        //Create right border for button
        if(index < maxButtonCount - 1) {
            [self addSubview:[AFFAlertView createRightBorderWithPosX:CGRectGetMaxX(button.frame) posY:CGRectGetMinY(button.frame) height:CGRectGetHeight(button.frame)]];
        }
        
        //Increment index
        index ++;
    }
}

#pragma mark - Adjust frame
- (void)adjustFrame {
    
    CGFloat maxY         = CGRectGetMaxY(_messageLabel.frame);
    
    //Adjust frame by text fields (if available)
    if(_secureTextField) {
        maxY             = CGRectGetMaxY(_secureTextField.frame);
    } else if(_plainTextField) {
        maxY             = CGRectGetMaxY(_plainTextField.frame);
    }
    
    //Add padding
    maxY += kAFFAlertView_DefaultTopTitlePadding;
    
    //Add button frames
    maxY += kAFFAlertView_DefaultButtonHeight;
    
    CGRect frame      = self.frame;
    frame.size.height = maxY;
    self.frame        = CGRectIntegral(frame);
}

- (void)adjustBottomBorder {
    
    //Create the bottom border
    CGFloat bottomBorderY = CGRectGetHeight(self.frame) - kAFFAlertView_DefaultButtonHeight;
    
    if(!_bottomButtonBorder) {
        _bottomButtonBorder = [AFFAlertView createTopBorderWithWidth:CGRectGetWidth(self.frame) posY:bottomBorderY];
        [self addSubview:_bottomButtonBorder];
    } else {
        CGRect bottomBorderFrame = _bottomButtonBorder.frame;
        bottomBorderFrame.origin.y = bottomBorderY - CGRectGetHeight(bottomBorderFrame);
        _bottomButtonBorder.frame = bottomBorderFrame;
    }
}

#pragma mark - Alert actions
#pragma mark - Button press actions
- (void)onButtonPress:(UIButton *)button {
    
    //Create button model
    AFFAlertViewButtonModel *buttonModel = [[AFFAlertViewButtonModel alloc] init];
    [buttonModel setValue:@(button.tag) forKey:@"index"];
    [buttonModel setValue:[button titleForState:UIControlStateNormal] forKey:@"title"];
    
    if([_delegate respondsToSelector:@selector(alertView:didDismissWithButton:)]) {
        [_delegate alertView:self didDismissWithButton:buttonModel];
    }
    
    [self dismiss];
}

#pragma mark - Alert animations
#pragma mark - Show the alert
- (void)show {
    
    if([_delegate respondsToSelector:@selector(alertViewWillShow:)]) {
        [_delegate alertViewWillShow:self];
    }
    
    //Keyboard (if applicable)
    if(_plainTextField) {
        [_plainTextField becomeFirstResponder];
    } else if(_secureTextField) {
        [_secureTextField becomeFirstResponder];
    }
    
    //Frame
    CGRect initialFrame;
    
    if([_delegate respondsToSelector:@selector(alertViewPreferredSize:)]) {
        CGSize selfFrameSize = [_delegate alertViewPreferredSize:self];
        self.frame = CGRectMake(0, 0, selfFrameSize.width, selfFrameSize.height);
    } else {
        [self adjustFrame];
    }
    
    CGRect selfFrame = self.frame;
    [self adjustBottomBorder];
    
    UIView *containerView          = [AFFAlertView superViewContainer];
    CGRect containerViewFrame      = containerView.frame;
    CATransform3D currentTransform = self.layer.transform;
    
    switch(_animationDirection) {
        case AFFAlertViewAnimationFromDirection_Center:
            initialFrame     = [AFFAlertView centerFrame:selfFrame containerFrame:containerViewFrame keyboardOffset:_keyboardHeightOffset];
            currentTransform = CATransform3DMakeScale(1.25f, 1.25f, 1.0f);
            self.alpha       = 0.0f;
            break;
        case AFFAlertViewAnimationFromDirection_Top:
            initialFrame     = [AFFAlertView topFrame:selfFrame containerFrame:containerViewFrame];
            break;
        case AFFAlertViewAnimationFromDirection_Bottom:
            initialFrame     = [AFFAlertView bottomFrame:selfFrame containerFrame:containerViewFrame];
            break;
        case AFFAlertViewAnimationFromDirection_Right:
            initialFrame     = [AFFAlertView rightFrame:selfFrame containerFrame:containerViewFrame];
            break;
        case AFFAlertViewAnimationFromDirection_Left:
            initialFrame     = [AFFAlertView leftFrame:selfFrame containerFrame:containerViewFrame];
            break;
        default:
            break;
    }
    
    //Add as subview
    [containerView addSubview:_backgroundBlockerView];
    [containerView insertSubview:self aboveSubview:_backgroundBlockerView];
    self.frame           = initialFrame;
    self.hidden          = NO;
    self.layer.transform = currentTransform;
    
    __weak typeof(self) weakSelf = self;
    
    //Animate
    [UIView animateWithDuration:_showDuration delay:0.0f options:_showAnimationOptions animations:^{
        
        weakSelf.frame               = [AFFAlertView centerFrame:weakSelf.frame containerFrame:_backgroundBlockerView.frame keyboardOffset:_keyboardHeightOffset];
        weakSelf.layer.transform     = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
        weakSelf.alpha               = 1.0f;
        _backgroundBlockerView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        _isBeingPresented = YES;
        
        if([_delegate respondsToSelector:@selector(alertViewDidShow:)]) {
            [_delegate alertViewDidShow:weakSelf];
        }
    }];
}

#pragma mark - Dismiss the alert
- (void)dismiss {
    
    if([_delegate respondsToSelector:@selector(alertViewWillDismss:)]) {
        [_delegate alertViewWillDismss:self];
    }
    
    //Frame
    CGRect dismissFrame;
    
    CGRect selfFrame                = self.frame;
    CGRect containerViewFrame       = _backgroundBlockerView.frame;
    CGFloat alpha                   = self.alpha;
    CATransform3D currentTransform  = self.layer.transform;
    CATransform3D newTransform      = self.layer.transform;
    
    switch(_animationDirection) {
        case AFFAlertViewAnimationFromDirection_Center:
            dismissFrame = [AFFAlertView centerFrame:selfFrame containerFrame:containerViewFrame keyboardOffset:_keyboardHeightOffset];
            alpha        = 0.0f;
            
            CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
            CATransform3D rotation = CATransform3DMakeRotation(- startRotation + M_PI * 270.0f / 180.0f, 0.0f, 0.0f, 0.0f);
            self.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1.0f, 1.0f, 1.0f));
            newTransform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.85f, 0.85f, 1.0f));
            
            break;
        case AFFAlertViewAnimationFromDirection_Top:
            dismissFrame     = [AFFAlertView topFrame:selfFrame containerFrame:containerViewFrame];
            break;
        case AFFAlertViewAnimationFromDirection_Bottom:
            dismissFrame     = [AFFAlertView bottomFrame:selfFrame containerFrame:containerViewFrame];
            break;
        case AFFAlertViewAnimationFromDirection_Right:
            dismissFrame     = [AFFAlertView rightFrame:selfFrame containerFrame:containerViewFrame];
            break;
        case AFFAlertViewAnimationFromDirection_Left:
            dismissFrame     = [AFFAlertView leftFrame:selfFrame containerFrame:containerViewFrame];
            break;
        default:
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    
    //Animate
    [UIView animateWithDuration:_dismissDuration delay:0.0f options:_dismissAnimationOptions animations:^{
        
        weakSelf.frame                   = dismissFrame;
        weakSelf.alpha                   = alpha;
        weakSelf.layer.transform         = newTransform;
        _backgroundBlockerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        _isBeingPresented = NO;
        
        if([_delegate respondsToSelector:@selector(alertViewDidDismss:)]) {
            [_delegate alertViewDidDismss:weakSelf];
        }
        
        [_backgroundBlockerView removeFromSuperview];
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - Keyboard height
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    _keyboardHeightOffset = CGRectGetHeight([notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue]);
    
    if(_isBeingPresented) {
        self.frame = [AFFAlertView centerFrame:self.frame containerFrame:_backgroundBlockerView.frame keyboardOffset:_keyboardHeightOffset];
    }
}

#pragma mark - Setters
#pragma mark - Motion effects
- (void)setMotionEffectsAmount:(CGPoint)motionEffectsAmount {
    
    _motionEffectsAmount = motionEffectsAmount;
    
    if(![self hasMotionEffects]) {
        return;
    }
    
    //Horizontal effect
    _motionEffectHorizontal.minimumRelativeValue         = @( - _motionEffectsAmount.x);
    _motionEffectHorizontal.maximumRelativeValue         = @( _motionEffectsAmount.x);
    
    //Vertical effect
    _motionEffectVertical.minimumRelativeValue           = @( - _motionEffectsAmount.y);
    _motionEffectVertical.maximumRelativeValue           = @( _motionEffectsAmount.y);
}

- (BOOL)hasMotionEffects {
    
    BOOL hasMotionEffects = NO;
    
    if([UIInterpolatingMotionEffect class]) {
        hasMotionEffects = YES;
    }
    
    return hasMotionEffects;
}

#pragma mark - Border color
- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    
    //Inline borders and textfield borders
    for(UIView *subview in self.subviews) {
        
        //Border view
        if([subview isKindOfClass:[AFFAlertViewBorder class]]) {
            subview.backgroundColor   = _borderColor;
            
            //Textfield
        } else if([subview isKindOfClass:[AFFAlertViewTextField class]]) {
            subview.layer.borderColor = _borderColor.CGColor;
        }
    }
    
    //Alert view border
    self.layer.borderColor = _borderColor.CGColor;
}

#pragma mark - Button background color
- (void)setSelectedStateButtonBackgroundColor:(UIColor *)selectedStateButtonBackgroundColor {
    
    _selectedStateButtonBackgroundColor = selectedStateButtonBackgroundColor;
    
    for(AFFAlertViewButton *button in self.subviews) {
        if([button isKindOfClass:[AFFAlertViewButton class]]) {
            
            [button setBackgroundImage:[AFFAlertView imageWithColor:selectedStateButtonBackgroundColor] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - Button text color
- (void)setButtonTextColor:(UIColor *)buttonTextColor {
    
    _buttonTextColor = buttonTextColor;
    
    for(AFFAlertViewButton *button in self.subviews) {
        if([button isKindOfClass:[AFFAlertViewButton class]]) {
            
            [button setTitleColor:_buttonTextColor forState:UIControlStateNormal];
        }
    }
}

- (void)setSelectedStateButtonTextColor:(UIColor *)selectedStateButtonTextColor {
    
    _selectedStateButtonTextColor = selectedStateButtonTextColor;
    
    for(AFFAlertViewButton *button in self.subviews) {
        if([button isKindOfClass:[AFFAlertViewButton class]]) {
            
            [button setTitleColor:_selectedStateButtonTextColor forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - Superview and frames
#pragma mark - Superview
+ (UIView *)superViewContainer {
    
    //Choose the the top subview view of the topmost presented view controller
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController].view;
    
    //If not controller is presented then look for the topmost subview of the root view controller.
    if(!rootView) {
        rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
    }
    
    return rootView;
}

#pragma mark - Alert frames
+ (CGRect)centerFrame:(CGRect)viewFrame containerFrame:(CGRect)containerFrame  keyboardOffset:(CGFloat)keyboardOffset {
    
    CGFloat posX = (CGRectGetWidth(containerFrame) - CGRectGetWidth(viewFrame)) * 0.5f;
    CGFloat posY = (CGRectGetHeight(containerFrame) - CGRectGetHeight(viewFrame)) * 0.5f;
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    //If self frame is taller than the keyboard then it must be offset
    
#warning TODO : This is incorrect
    if(CGRectGetMaxY(frame) > CGRectGetHeight(containerFrame) - keyboardOffset) {
        
        CGFloat diffY = CGRectGetMaxY(frame) - (CGRectGetHeight(containerFrame) - keyboardOffset);
        frame.origin.y -= diffY;
    }
    
    return CGRectIntegral(frame);
}

+ (CGRect)topFrame:(CGRect)viewFrame containerFrame:(CGRect)containerFrame {
    
    CGFloat posX = (CGRectGetWidth(containerFrame) - CGRectGetWidth(viewFrame)) * 0.5f;
    CGFloat posY = - CGRectGetHeight(viewFrame);
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return CGRectIntegral(frame);
}

+ (CGRect)bottomFrame:(CGRect)viewFrame containerFrame:(CGRect)containerFrame {
    
    CGFloat posX = (CGRectGetWidth(containerFrame) - CGRectGetWidth(viewFrame)) * 0.5f;
    CGFloat posY = CGRectGetHeight(containerFrame);
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return CGRectIntegral(frame);
}

+ (CGRect)leftFrame:(CGRect)viewFrame containerFrame:(CGRect)containerFrame {
    
    CGFloat posX = - CGRectGetWidth(containerFrame);
    CGFloat posY = (CGRectGetHeight(containerFrame) - CGRectGetHeight(viewFrame)) * 0.5f;
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return CGRectIntegral(frame);
}

+ (CGRect)rightFrame:(CGRect)viewFrame containerFrame:(CGRect)containerFrame {
    
    CGFloat posX = CGRectGetWidth(containerFrame);
    CGFloat posY = (CGRectGetHeight(containerFrame) - CGRectGetHeight(viewFrame)) * 0.5f;
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return CGRectIntegral(frame);
}

#pragma mark - Utilities
+ (AFFAlertViewTextField *)createInputLabel:(CGRect)frame fontSize:(CGFloat)fontSize corners:(UIRectCorner)corners secure:(BOOL)secure {
    
    //Label
    AFFAlertViewTextField *label = [[AFFAlertViewTextField alloc] initWithFrame:CGRectIntegral(frame)];
    label.clipsToBounds          = YES;
    label.autoresizingMask       = UIViewAutoresizingFlexibleWidth;
    label.font                   = [UIFont systemFontOfSize:fontSize];
    label.secureTextEntry        = secure;
    label.backgroundColor        = [UIColor clearColor];
    label.textColor              = AFFAlertView_DEFAULT_TEXT_COLOR;
    label.textColor              = [UIColor blackColor];
    label.returnKeyType          = UIReturnKeyDefault;
    
    //Left view padding
    UIView *leftView             = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAFFAlertView_DefaultInputFieldViewPadding, CGRectGetHeight(label.frame))];
    label.leftViewMode           = UITextFieldViewModeAlways;
    label.leftView               = leftView;
    
    //Right view padding
    UIView *rightView            = [[UIView alloc] initWithFrame:leftView.frame];
    label.rightViewMode          = label.leftViewMode;
    label.rightView              = rightView;
    
    //Corners
    CGSize cornerSize            = CGSizeMake(kAFFAlertView_DefaultInputFieldBorderRoundedCornerRadius, kAFFAlertView_DefaultInputFieldBorderRoundedCornerRadius);
    
    CAShapeLayer *maskLayer      = [CAShapeLayer layer];
    maskLayer.frame              = label.bounds;
    
    CGFloat posX                 = CGRectGetMinX(maskLayer.frame) + kAFFAlertView_DefaultRoundedBorderWidth;
    CGFloat posY                 = CGRectGetMinY(maskLayer.frame) + kAFFAlertView_DefaultRoundedBorderWidth;
    CGFloat width                = CGRectGetWidth(maskLayer.frame) - (posX * 2);
    CGFloat height               = CGRectGetHeight(maskLayer.frame) - (posY * 2);
    CGRect pathFrame             = CGRectMake(posX, posY, width, height);
    
    UIBezierPath *roundedPath    = [UIBezierPath bezierPathWithRoundedRect:pathFrame byRoundingCorners:corners cornerRadii:cornerSize];
    maskLayer.strokeColor        = AFFAlertView_DEFAULT_BORDER_COLOR.CGColor;
    maskLayer.fillColor          = [UIColor whiteColor].CGColor;
    maskLayer.lineCap            = kCALineCapRound;
    maskLayer.lineJoin           = kCALineJoinRound;
    maskLayer.borderColor        = [UIColor clearColor].CGColor;
    maskLayer.lineWidth          = kAFFAlertView_DefaultRoundedBorderWidth;
    maskLayer.path               = [roundedPath CGPath];
    
    [label.layer addSublayer:maskLayer];
    
    return label;
}

+ (UILabel *)createLabel:(NSString *)title fontSize:(CGFloat)fontSize bold:(BOOL)bold {
    
    UIFont *font           = (bold) ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    
    //Label
    UILabel *label         = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font             = font;
    label.backgroundColor  = [UIColor clearColor];
    label.textColor        = AFFAlertView_DEFAULT_TEXT_COLOR;
    label.textAlignment    = NSTextAlignmentCenter;
    label.numberOfLines    = 0;
    label.text             = title;
    
    return label;
}

+ (CGRect)boundingRectForLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth {
    
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGRect boundingRect;
    
    //iOS 6 +
    if([label.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        boundingRect = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin                                                      attributes:@{NSFontAttributeName : label.font} context:nil];
    } else {
        
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        CGSize size  = [label.text sizeWithFont:label.font constrainedToSize:maxSize];
#pragma GCC diagnostic pop
        boundingRect = CGRectMake(CGRectGetMinX(label.frame), CGRectGetMinY(label.frame), size.width, size.height);
    }
    
    return boundingRect;
}

- (AFFAlertViewButton *)createButton:(NSString *)title index:(NSUInteger)index maxButtonCount:(NSUInteger) maxButtonCount containerRect:(CGRect)containerRect isNotBold:(BOOL)isNotBold {
    
    //Button background color image
    UIImage *backgroundImage = [AFFAlertView imageWithColor:[UIColor clearColor]];
    
    //Button selected background color image
    UIColor *lighterBackgroundColor     = [AFFAlertView darkerColor:self.backgroundColor];
    _selectedStateButtonBackgroundColor = lighterBackgroundColor;
    UIImage *selectedBackgroundImage    = [AFFAlertView imageWithColor:lighterBackgroundColor];
    
    //Frame
    CGFloat width  = (CGRectGetWidth(containerRect) / maxButtonCount) + kAFFAlertView_DefaultRoundedBorderWidth;
    CGFloat height = kAFFAlertView_DefaultButtonHeight;
    CGFloat posX   = (width * index) - kAFFAlertView_DefaultRoundedBorderWidth;
    CGFloat posY   = CGRectGetHeight(containerRect) - height;
    
    //Create button
    AFFAlertViewButton *button     = [[AFFAlertViewButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
    button.backgroundColor        = [UIColor clearColor];
    button.tag                    = index;
    button.autoresizingMask       = UIViewAutoresizingFlexibleTopMargin;
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [button setTitleColor:AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR forState:UIControlStateHighlighted];
    
    //Create button title edge insets
    button.titleEdgeInsets = UIEdgeInsetsMake(kAFFAlertView_DefaultRoundedBorderWidth * 2, 0, kAFFAlertView_DefaultRoundedBorderWidth, 0);
    
    //Set button bolding
    if(isNotBold) {
        button.titleLabel.font = [UIFont systemFontOfSize:kAFFAlertView_DefaultButtonFontSize];
    } else {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:kAFFAlertView_DefaultButtonFontSize];
    }
    
    return button;
}

#pragma mark - Borders
+ (AFFAlertViewBorder *)createTopBorderWithWidth:(CGFloat)width posY:(CGFloat)posY {
    
    AFFAlertViewBorder *border = [AFFAlertView createBorder];
    border.frame               = CGRectMake(CGRectGetWidth(border.frame), posY - CGRectGetHeight(border.frame), width, CGRectGetHeight(border.frame));
    border.autoresizingMask    = UIViewAutoresizingFlexibleWidth;
    
    return border;
}

+ (AFFAlertViewBorder *)createRightBorderWithPosX:(CGFloat)posX posY:(CGFloat)posY height:(CGFloat)height {
    
    AFFAlertViewBorder *border = [AFFAlertView createBorder];
    border.frame               = CGRectMake(posX - CGRectGetWidth(border.frame), posY + CGRectGetHeight(border.frame), CGRectGetWidth(border.frame), height);
    border.autoresizingMask    = UIViewAutoresizingFlexibleTopMargin;
    
    return border;
}

/** Returns a 1x1 border. */
+ (AFFAlertViewBorder *)createBorder {
    
    AFFAlertViewBorder *border                = [[AFFAlertViewBorder alloc] initWithFrame:CGRectMake(0, 0, kAFFAlertView_DefaultRoundedBorderWidth, kAFFAlertView_DefaultRoundedBorderWidth)];
    border.backgroundColor          = AFFAlertView_DEFAULT_BORDER_COLOR;
    border.userInteractionEnabled   = NO;
    return border;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor *)darkerColor:(UIColor *)color {
    
    CGFloat h, s, b, a;
    if([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
        
        return [UIColor colorWithHue:h saturation:s brightness:b * kAFFAlertView_DarkerColorPercentage alpha:a];
    }
    
    return nil;
}

#pragma mark - Dealloc
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegate = nil;
}

@end