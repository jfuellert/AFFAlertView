** Caution: This project is still in early development and may have many api changes. If you choose to use this product in active development please use a release build. **

AFFAlertView
========
AFFAlertView is a customizable alert view built for iOS. It is compatible with iOS 6+ so older devices can benefit from the iOS 7 UIAlertView look and feel. AFFAlertView comes with a list of modifiable properties which can give the alert view a custom style. It also supports subclassing so customization is even more abundant. 

##Purpose
The main purpose of this software is to provide developers with a customizable version of UIAlertView. It has similar functionality to UIAlertView and supports subclassing. The secondary purpose of this software is to provide iOS 6 developers an iOS 7 styled UIAlertView alternative.

##Installation
1. Install via CocoaPods
Add the following line to your .podfile

	```
	pod 'AFFAlertView'
	```
2. Use and enjoy!

##Support
####IOS
Earliest tested and supported build and deployment target - iOS 6.0. 
Latest tested and supported build and deployment target - iOS 7.1.

##ARC Compatibility
AFFAlertView is built from ARC and is ARC compatible. 

##Usage
####AFFAlertView initialization
AFFAlertView can be used identically to UIAlert view.

``` objective-c
AFFAlertView *alertView = [[AFFAlertView alloc] initWithTitle:@"Title here"
                                                message:@"Message here"
                                                buttonTitles:@[@"Cancel”, @“Okay"]];
``` 

The AFFAlertView instance may optionally be provided with a delegate.
``` objective-c
alertView.delegate = self;
``` 

Showing in the AFFAlertView instance is identical to a UIAlertView.
``` objective-c
[alertView show];
``` 

AFFAlertView also has an option to manually dismiss the alert view.
``` objective-c
[alertView dismiss];
``` 

####AFFAlertView delegate
AFFAlertViewDelegate is a fully optional protocol that provides useful functionality for alert dismissal clicks and basic UI interactions.

``` objective-c
/** Called before showing the alert view. This is used to override the default alert view size within constraints such as keyboard size and orientation. */
- (CGSize)alertViewPreferredSize:(AFFAlertView *)alertView;

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
``` 
