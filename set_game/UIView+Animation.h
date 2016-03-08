//
//  UIView+Animation.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "util.h"

@interface UIView (Animation)

-(void)scale:(CGPoint)scale
AndTranslate:(CGPoint)translation
    duration:(float)secs
       delay:(float)delay
      option:(UIViewAnimationOptions)option;

-(void)scale:(CGPoint)scale
      rotate:(CGFloat)rotation
AndTranslate:(CGPoint)translation
    duration:(float)secs
       delay:(float)delay
      option:(UIViewAnimationOptions)option;

-(void)setAnchorPoint:(CGPoint)anchorPoint;

-(void)popToMaxSize:(CGPoint)maxScale 
            endSize:(CGPoint)endScale 
     withExpandTime:(float)expandTime
        compactTime:(float)compactTime 
             completion:(void (^)(BOOL finished))completionBlock;
-(void)fade:(bool)fadeIn duration:(float)duration;
@end
