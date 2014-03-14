//
//  AFBlipAlertViewButtonModel.h
//  AF Apps
//
//  Created by Jeremy Fuellert on 2014-03-11.
//  Copyright (c) 2014 AF-Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

/** AFFAlertViewButtonModel is a model class used in AFFAlertView. It encompasses callback information from a selected button in the AFBlipAlertView. */
@interface AFFAlertViewButtonModel : NSObject

/** Returns the title of the button. */
@property (nonatomic, readonly) NSString *title;

/** Return the index of the button. */
@property (nonatomic, readonly) NSUInteger index;

@end
