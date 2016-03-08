//
//  UIView+Animation.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)


-(void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchorPoint;
}

-(void)popToMaxSize:(CGPoint)maxScale 
            endSize:(CGPoint)endScale 
     withExpandTime:(float)expandTime
        compactTime:(float)compactTime 
             completion:(void (^)(BOOL finished))completionBlock {

    [UIView animateWithDuration:expandTime delay:0.0 options:0
         animations:^{
             self.transform = CGAffineTransformScale(self.transform, maxScale.x, maxScale.y);
         }
         completion:^(BOOL finished) {
             [UIView animateWithDuration:compactTime delay:0.0 options:0
                animations:^{
                    self.transform = CGAffineTransformScale(self.transform, endScale.x, endScale.y);
                } completion:completionBlock];
         }
     ];
}

-(void)scale:(CGPoint)scale AndTranslate:(CGPoint)translation duration:(float)secs delay:(float)delay option:(UIViewAnimationOptions)option {
    [UIView animateWithDuration:secs delay:delay options:option
        animations:^{
            CGAffineTransform t = self.transform;
            t = CGAffineTransformScale(t, scale.x, scale.y);
            t = CGAffineTransformTranslate(t, translation.x, translation.y);

            self.transform = t;
        }
        completion:^(BOOL finished){
        }];
}

-(void)scale:(CGPoint)scale
      rotate:(CGFloat)rotation
AndTranslate:(CGPoint)translation
    duration:(float)secs
       delay:(float)delay
      option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:delay options:option
                     animations:^{
                         CGAffineTransform t = self.transform;
                         t = CGAffineTransformScale(t, scale.x, scale.y);
                         t = CGAffineTransformTranslate(t, translation.x, translation.y);
                         t = CGAffineTransformRotate(t, rotation);                         
                         self.transform = t;
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)fade:(bool)fadeIn duration:(float)duration
{
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         self.alpha = fadeIn ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {}];
}

@end
