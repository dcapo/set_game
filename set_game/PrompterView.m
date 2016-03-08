//
//  PrompterView.m
//  set_game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "PrompterView.h"
#import <QuartzCore/QuartzCore.h>
#define FONT_SIZE 20.0
#define DEFAULT_HOLD 2.0
#define ENTRY_EXIT_DURATION 1.0
#define SIDE_MARGIN 7

@interface PrompterView()

@property (nonatomic, strong) UILabel *label;
@property bool isAnimating;

@end

@implementation PrompterView
@synthesize label, isAnimating;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = true;
        UIImageView *backgroundImg = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImg.image = [UIImage imageNamed:@"prompter.png"];
        [self addSubview:backgroundImg];
        label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:FONT_SIZE];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        isAnimating = false;
        
    }
    return self;
}

-(void)animateExit:(int)delay {
    [UIView animateWithDuration:ENTRY_EXIT_DURATION delay:delay options:0 animations:^{
        self.label.frame = CGRectMake(self.label.frame.origin.x,
                                      -self.label.frame.size.height,
                                      self.label.frame.size.width,
                                      self.label.frame.size.height);
    } completion:nil];
}

-(void)promptMessage:(NSString *)message {
    CGSize size = [message sizeWithFont:self.label.font];
    float centeredX = self.frame.size.width/2 - size.width/2;
    float x = (centeredX > 0) ? centeredX : SIDE_MARGIN;
    self.label.text = message;
    self.label.frame = CGRectMake(x, self.frame.size.height, size.width, size.height);
    [UIView animateWithDuration:ENTRY_EXIT_DURATION delay:0 options:0 animations:^{
        self.label.frame = CGRectMake(self.label.frame.origin.x,
                                      self.frame.size.height/2 - self.label.frame.size.height/2,
                                      self.label.frame.size.width,
                                      self.label.frame.size.height);
    } completion:^(BOOL finished){
        if (finished) {
            if (self.label.frame.size.width > self.frame.size.width) {
                float duration = DEFAULT_HOLD * (self.label.frame.size.width / self.frame.size.width);
                [UIView animateWithDuration:duration delay:0.5 options:0 animations:^{
                    float x = self.frame.size.width - self.label.frame.size.width - SIDE_MARGIN;
                    self.label.frame = CGRectMake(x, self.label.frame.origin.y,
                                                  self.label.frame.size.width,
                                                  self.label.frame.size.height);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self animateExit:0];
                    }
                }];
            } else {
                [self animateExit:DEFAULT_HOLD];
            }
        }
    }];
}

@end
