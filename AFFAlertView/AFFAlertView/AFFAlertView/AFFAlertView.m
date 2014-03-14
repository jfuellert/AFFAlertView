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

#pragma mark - Constants
//Animations
const CGFloat kAFFAlertView_DefaultShowDuration           = 0.3f;
const CGFloat kAFFAlertView_DefaultShowAnimationOptions   = UIViewAnimationOptionCurveEaseInOut;
const CGFloat kAFFAlertView_DefaultDismissDuration        = 0.3f;
const CGFloat kAFFAlertView_DefaultDismssAnimationOptions = UIViewAnimationOptionCurveEaseInOut;

const CGFloat kAFFAlertView_DefaultMotionEffectsAmount    = 10.0f;

//Padding
const CGFloat kAFFAlertView_DefaultTopTitlePadding        = 19.0f;
const CGFloat kAFFAlertView_DefaultTopMessagePadding      = 5.0f;
const CGFloat kAFFAlertView_DefaultTitleMessagePadding    = 10.0f;
const CGFloat kAFFAlertView_DefaultButtonHeight           = 44.5f;

//Border radius
const CGFloat kAFFAlertView_DefaultRoundedCornerRadius    = 7.0f;
const CGFloat kAFFAlertView_DefaultRoundedBorderWith      = 0.5f;

//Font sizing
const CGFloat kAFFAlertView_DefaultTitleFontSize          = 17.0f;
const CGFloat kAFFAlertView_DefaultMessageFontSize        = 14.0f;
const CGFloat kAFFAlertView_DefaultButtonFontSize         = 16.0f;

//Colors
#define AFFAlertView_DEFAULT_TEXT_COLOR                  [UIColor blackColor]
#define AFFAlertView_DEFAULT_SELF_VIEW_COLOR             [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:0.97f]
#define AFFAlertView_DEFAULT_BACKGROUND_VIEW_COLOR       [UIColor colorWithWhite:0.0f alpha:0.35f]
#define AFFAlertView_DEFAULT_BORDER_COLOR                [UIColor colorWithWhite:0.0f alpha:0.18f]
#define AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR           [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

//Preferred size
#define AFFAlertView_DEFAULT_PREFERRED_SIZE              CGSizeMake(270.0f, 124.0f)

@interface AFFAlertView () {
    
    //Horizontal effect
    UIInterpolatingMotionEffect *_motionEffectHorizontal;
    
    //Vertical effect
    UIInterpolatingMotionEffect *_motionEffectVertical;
}

@end

@implementation AFFAlertView

#pragma mark - Init
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles {
    
    CGSize preferredSize = AFFAlertView_DEFAULT_PREFERRED_SIZE;
    
    self = [super initWithFrame:CGRectMake(0, 0, preferredSize.width, preferredSize.height)];
    if (self) {
        
        self.hidden = YES;
        
        //Set defaults
        _showDuration                   = kAFFAlertView_DefaultShowDuration;
        _showAnimationOptions           = kAFFAlertView_DefaultShowAnimationOptions;
        _dismissDuration                = kAFFAlertView_DefaultDismissDuration;
        _dismissAnimationOptions        = kAFFAlertView_DefaultDismssAnimationOptions;
        _animationDirection             = AFFAlertViewAnimationFromDirection_Center;
        _motionEffectsAmount            = CGPointMake(kAFFAlertView_DefaultMotionEffectsAmount, kAFFAlertView_DefaultMotionEffectsAmount);
        _buttonTextColor                = AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR;
        _selectedStateButtonTextColor   = AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR;
        _borderColor                    = AFFAlertView_DEFAULT_BORDER_COLOR;
        
        //Create view components
        [self createBackgroundBlockerView];
        [self createBackground];
        [self createMotionEffects];
        [self createTitle:title];
        [self createMessage:message];
        [self createButtonsWithTitles:buttonTitles];
    }
    return self;
}

#pragma mark - Create UI components
#pragma mark - Background blocker view
- (void)createBackgroundBlockerView {
    
    UIView *superView = superViewContainer();
    
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
    self.layer.borderWidth   = kAFFAlertView_DefaultRoundedBorderWith;
    self.layer.cornerRadius  = kAFFAlertView_DefaultRoundedCornerRadius;
}

- (void)createMotionEffects {
    
    if(![self hasMotionEffects]) {
        return;
    }
    
    //Horizontal effect
    _motionEffectHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    _motionEffectHorizontal.minimumRelativeValue         = @( - _motionEffectsAmount.x);
    _motionEffectHorizontal.maximumRelativeValue         = @( _motionEffectsAmount.x);
    
    //Vertical effect
    _motionEffectVertical   = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    _motionEffectVertical.minimumRelativeValue           = @( - _motionEffectsAmount.y);
    _motionEffectVertical.maximumRelativeValue           = @( _motionEffectsAmount.y);
    
    UIMotionEffectGroup *motionEffectGroup              = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects                     = @[_motionEffectHorizontal, _motionEffectVertical];
    
    [self addMotionEffect:motionEffectGroup];
}

#pragma mark - Title
- (void)createTitle:(NSString *)title {
    
    _titleLabel       = createLabel(title, kAFFAlertView_DefaultTitleFontSize, YES);
    
    //Frame
    CGRect frame      = boundingRectForLabel(_titleLabel, CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2));
    frame.size.width  = CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2);
    frame.origin.x    = kAFFAlertView_DefaultTitleMessagePadding;
    frame.origin.y    = kAFFAlertView_DefaultTopTitlePadding;
    _titleLabel.frame = frame;
    
    [self addSubview:_titleLabel];
}

#pragma mark - Message
- (void)createMessage:(NSString *)message {
    
    _messageLabel     = createLabel(message, kAFFAlertView_DefaultMessageFontSize, NO);
    
    //Frame
    CGRect frame      = boundingRectForLabel(_messageLabel, CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2));
    frame.size.width  = CGRectGetWidth(self.bounds) - (kAFFAlertView_DefaultTitleMessagePadding * 2);
    frame.origin.x    = kAFFAlertView_DefaultTitleMessagePadding;
    frame.origin.y    = CGRectGetMaxY(_titleLabel.frame) + kAFFAlertView_DefaultTopMessagePadding;
    _messageLabel.frame = frame;
    
    [self addSubview:_messageLabel];
    
    //If the message is going out of bounds then the view must be re-framed.
    if(CGRectGetMaxY(_messageLabel.frame) + kAFFAlertView_DefaultTitleMessagePadding > CGRectGetHeight(self.frame) - kAFFAlertView_DefaultButtonHeight) {
        
        CGFloat heightOffset = fabsf((CGRectGetHeight(self.frame) - kAFFAlertView_DefaultButtonHeight - kAFFAlertView_DefaultTitleMessagePadding) - CGRectGetMaxY(_messageLabel.frame));
        
        CGRect frame         = self.frame;
        frame.size.height   += heightOffset;
        self.frame           = frame;
    }
}

#pragma mark - Buttons
- (void)createButtonsWithTitles:(NSArray *)buttonTitleArray {

    //Create buttons from titles
    NSUInteger maxButtonCount = buttonTitleArray.count;
    NSUInteger index          = 0;
    CGRect containerRect      = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    for(NSString *title in buttonTitleArray) {
        
        //Create button
        AFFAlertViewButton *button = createButton(title, index, maxButtonCount, containerRect, index == 0);
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:button atIndex:0];

        //Create right border for button
        if(index < maxButtonCount - 1) {
            [self addSubview:createRightBorder(CGRectGetMaxX(button.frame), CGRectGetMinY(button.frame),  CGRectGetHeight(button.frame))];
        }
        
        //Create the top border
        if(index == 0) {
            [self addSubview:createTopBorder(CGRectGetWidth(self.bounds), CGRectGetMinY(button.frame))];
        }
        
        //Increment index
        index ++;
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
    
    //Frame
    CGRect initialFrame;
    
    UIView *containerView           = superViewContainer();
    CGRect selfFrame                = self.frame;
    CGRect containerViewFrame       = _backgroundBlockerView.frame;
    CATransform3D currentTransform  = self.layer.transform;
    
    switch(_animationDirection) {
        case AFFAlertViewAnimationFromDirection_Center:
            initialFrame     = centerFrame(selfFrame, containerViewFrame);
            currentTransform = CATransform3DMakeScale(1.25f, 1.25f, 1.0f);
            self.alpha       = 0.0f;
            break;
        case AFFAlertViewAnimationFromDirection_Top:
            initialFrame = topFrame(selfFrame, containerViewFrame);
            break;
        case AFFAlertViewAnimationFromDirection_Bottom:
            initialFrame = bottomFrame(selfFrame, containerViewFrame);
            break;
        case AFFAlertViewAnimationFromDirection_Right:
            initialFrame = rightFrame(selfFrame, containerViewFrame);
            break;
        case AFFAlertViewAnimationFromDirection_Left:
            initialFrame = leftFrame(selfFrame, containerViewFrame);
            break;
        default:
            break;
    }
    
    //Add blocker view
    [containerView addSubview:_backgroundBlockerView];
    
    //Add as subview
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;

    [containerView insertSubview:self aboveSubview:_backgroundBlockerView];
    self.frame           = initialFrame;
    self.hidden          = NO;
    self.layer.transform = currentTransform;
    
    //Animate
    [UIView animateWithDuration:_showDuration delay:0.0f options:_showAnimationOptions animations:^{
        
        self.frame                   = centerFrame(self.frame, _backgroundBlockerView.frame);
        self.layer.transform         = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
        self.alpha                   = 1.0f;
        _backgroundBlockerView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        if([_delegate respondsToSelector:@selector(alertViewDidShow:)]) {
            [_delegate alertViewDidShow:self];
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
            dismissFrame = centerFrame(selfFrame, containerViewFrame);
            alpha        = 0.0f;
            
            CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
            CATransform3D rotation = CATransform3DMakeRotation(- startRotation + M_PI * 270.0f / 180.0f, 0.0f, 0.0f, 0.0f);
            self.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1.0f, 1.0f, 1.0f));
            newTransform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.85f, 0.85f, 1.0f));
            
            break;
        case AFFAlertViewAnimationFromDirection_Top:
            dismissFrame = topFrame(selfFrame, containerViewFrame);
            break;
        case AFFAlertViewAnimationFromDirection_Bottom:
            dismissFrame = bottomFrame(selfFrame, containerViewFrame);
            break;
        case AFFAlertViewAnimationFromDirection_Right:
            dismissFrame = rightFrame(selfFrame, containerViewFrame);
            break;
        case AFFAlertViewAnimationFromDirection_Left:
            dismissFrame = leftFrame(selfFrame, containerViewFrame);
            break;
        default:
            break;
    }
    
    //Animate
    [UIView animateWithDuration:_dismissDuration delay:0.0f options:_dismissAnimationOptions animations:^{
        
        self.frame                   = dismissFrame;
        self.alpha                   = alpha;
        self.layer.transform         = newTransform;
        _backgroundBlockerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if([_delegate respondsToSelector:@selector(alertViewDidDismss:)]) {
            [_delegate alertViewDidDismss:self];
        }
        
        [_backgroundBlockerView removeFromSuperview];
        [self removeFromSuperview];
    }];
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
    
    //Inline borders
    for(AFFAlertViewBorder *border in self.subviews) {
        if([border isKindOfClass:[AFFAlertViewBorder class]]) {
            border.backgroundColor = _borderColor;
        }
    }
    
    //Alert view border
    self.layer.borderColor = _borderColor.CGColor;
    
    //Buttons
    //Button selected background color image
    UIImage *selectedBackgroundImage = imageWithColor(_borderColor);
    
    for(AFFAlertViewButton *button in self.subviews) {
        if([button isKindOfClass:[AFFAlertViewButton class]]) {
            
            [button setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
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
UIView *superViewContainer(void) {
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] subviews] firstObject];
    
    return rootView;
}

#pragma mark - Alert frames
CGRect centerFrame(CGRect viewFrame, CGRect containerFrame) {
    
    CGFloat posX = (CGRectGetWidth(containerFrame) - CGRectGetWidth(viewFrame)) * 0.5f;
    CGFloat posY = (CGRectGetHeight(containerFrame) - CGRectGetHeight(viewFrame)) * 0.5f;
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return frame;
}

CGRect topFrame(CGRect viewFrame, CGRect containerFrame) {
    
    CGFloat posX = (CGRectGetWidth(containerFrame) - CGRectGetWidth(viewFrame)) * 0.5f;
    CGFloat posY = - CGRectGetHeight(viewFrame);
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return frame;
}

CGRect bottomFrame(CGRect viewFrame, CGRect containerFrame) {
    
    CGFloat posX = (CGRectGetWidth(containerFrame) - CGRectGetWidth(viewFrame)) * 0.5f;
    CGFloat posY = CGRectGetHeight(containerFrame);
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return frame;
}

CGRect leftFrame(CGRect viewFrame, CGRect containerFrame) {
    
    CGFloat posX = - CGRectGetWidth(containerFrame);
    CGFloat posY = (CGRectGetHeight(containerFrame) - CGRectGetHeight(viewFrame)) * 0.5f;
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return frame;
}

CGRect rightFrame(CGRect viewFrame, CGRect containerFrame) {
    
    CGFloat posX = CGRectGetWidth(containerFrame);
    CGFloat posY = (CGRectGetHeight(containerFrame) - CGRectGetHeight(viewFrame)) * 0.5f;
    
    CGRect frame = CGRectMake(posX, posY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    
    return frame;
}

#pragma mark - Utilities
UILabel *createLabel(NSString *title, CGFloat fontSize, BOOL bold) {
    
    UIFont *font = (bold) ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    
    //Label
    UILabel *label        = [[UILabel alloc] init];
    label.font            = font;
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = AFFAlertView_DEFAULT_TEXT_COLOR;
    label.textAlignment   = NSTextAlignmentCenter;
    label.numberOfLines   = 0;
    label.text            = title;
    
    return label;
}

CGRect boundingRectForLabel(UILabel *label, CGFloat maxWidth) {
    
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGRect boundingRect;
    
    //iOS 7 +
    if([label.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        boundingRect = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin                                                      attributes:@{NSFontAttributeName : label.font} context:nil];
    } else {
        CGSize size  = [label.text sizeWithFont:label.font constrainedToSize:maxSize];
        boundingRect = CGRectMake(CGRectGetMinX(label.frame), CGRectGetMinY(label.frame), size.width, size.height);
    }
    
    return boundingRect;
}

AFFAlertViewButton *createButton(NSString *title, NSUInteger index, NSUInteger maxButtonCount, CGRect containerRect, BOOL isNotBold) {
    
    //Button background color image
    UIImage *backgroundImage = imageWithColor([UIColor clearColor]);
    
    //Button selected background color image
    UIImage *selectedBackgroundImage = imageWithColor(AFFAlertView_DEFAULT_BORDER_COLOR);
    
    //Frame
    CGFloat width  = CGRectGetWidth(containerRect) / maxButtonCount;
    CGFloat height = kAFFAlertView_DefaultButtonHeight;
    CGFloat posX   = width * index;
    CGFloat posY   = CGRectGetHeight(containerRect) - height;
    
    //Create button
    AFFAlertViewButton *button     = [[AFFAlertViewButton alloc] initWithFrame:CGRectMake(posX - kAFFAlertView_DefaultRoundedBorderWith, posY, width + kAFFAlertView_DefaultRoundedBorderWith, height)];
    button.backgroundColor        = [UIColor clearColor];
    button.tag                    = index;
    button.autoresizingMask       = UIViewAutoresizingFlexibleTopMargin;
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [button setTitleColor:AFFAlertView_DEFAULT_BUTTON_TEXT_COLOR forState:UIControlStateHighlighted];
    
    //Set button bolding
    if(isNotBold) {
        button.titleLabel.font = [UIFont systemFontOfSize:kAFFAlertView_DefaultButtonFontSize];
    } else {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:kAFFAlertView_DefaultButtonFontSize];
    }
    
    return button;
}

AFFAlertViewBorder *createTopBorder(CGFloat width, CGFloat posY) {
    
    AFFAlertViewBorder *border = createBorder();
    border.frame              = CGRectMake(CGRectGetWidth(border.frame), posY, width - (CGRectGetWidth(border.frame) * 2), CGRectGetHeight(border.frame));
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return border;
}

AFFAlertViewBorder *createRightBorder(CGFloat posX, CGFloat posY, CGFloat height) {
    
    AFFAlertViewBorder *border = createBorder();
    border.frame              = CGRectMake(posX - CGRectGetWidth(border.frame), posY + CGRectGetHeight(border.frame), CGRectGetWidth(border.frame), height - (CGRectGetHeight(border.frame) * 2));
    
    return border;
}

/** Returns a 1x1 border. */
AFFAlertViewBorder *createBorder() {
    
    AFFAlertViewBorder *border                = [[AFFAlertViewBorder alloc] initWithFrame:CGRectMake(0, 0, kAFFAlertView_DefaultRoundedBorderWith, kAFFAlertView_DefaultRoundedBorderWith)];
    border.backgroundColor                   = AFFAlertView_DEFAULT_BORDER_COLOR;
    border.userInteractionEnabled            = NO;
    
    return border;
}

UIImage *imageWithColor(UIColor *color) {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Dealloc
- (void)dealloc {
    
    _delegate = nil;
}

@end