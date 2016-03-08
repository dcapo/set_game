//
//  CardView.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "CardView.h"
#define ZOOM 1.12   

@implementation CardView
@synthesize card;
@synthesize button,glow;
@synthesize isSelected;

-(void)loadImages
{
    UIImageView *sym1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@_%@.png", card.shading, card.color, card.shape]]];
    int symbolWidth = ((24.0/105.0)*self.frame.size.width);
    int symbolHeight = ((85.0/91.0)*self.frame.size.height);
    
    int y = self.bounds.size.height / 2 - symbolHeight / 2;
    if ([card.number isEqualToString:@"one"]) {
        sym1.frame = CGRectMake(self.bounds.size.width/2 - symbolWidth/2, y, symbolWidth, symbolHeight);
        [self addSubview:sym1];
    } else if ([card.number isEqualToString:@"two"]) {
        sym1.frame = CGRectMake(self.bounds.size.width/3 - symbolWidth/2, y, symbolWidth, symbolHeight);
        [self addSubview:sym1];
        UIImageView *sym2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@_%@.png", card.shading, card.color, card.shape]]];
        sym2.frame = CGRectMake((2.0*self.bounds.size.width)/3 - symbolWidth/2, y, symbolWidth, symbolHeight);
        [self addSubview:sym2];
    } else {
        sym1.frame = CGRectMake(22 * self.bounds.size.width/100 - symbolWidth/2, y, symbolWidth, symbolHeight);
        [self addSubview:sym1];
        UIImageView *sym2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@_%@.png", card.shading, card.color, card.shape]]];
        sym2.frame = CGRectMake(self.bounds.size.width/2 - symbolWidth/2, y, symbolWidth, symbolHeight);
        [self addSubview:sym2];
        UIImageView *sym3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@_%@.png", card.shading, card.color, card.shape]]];
        sym3.frame = CGRectMake(77*self.bounds.size.width/100 - symbolWidth/2, y, symbolWidth, symbolHeight);
        [self addSubview:sym3];
    }
}

- (id)initWithFrame:(CGRect)frame FromCard:(Card *)aCard
{
    self = [super initWithFrame:frame];
    if (self) {
        card = aCard;
        isSelected = false;
        button = [[UIButton alloc] initWithFrame:self.bounds];
        [self.button setBackgroundImage:[UIImage imageNamed:@"card_white.png"] forState:UIControlStateNormal];
        [self addSubview:button];
        [self loadImages];
    }
    return self;
}

-(void)toggleHighlight
{
    [self setAnchorPoint:CGPointMake(0.5, 0.5)];
    if (self.isSelected) {
        self.transform = CGAffineTransformScale(self.transform, 1.0/ZOOM, 1.0/ZOOM);
        [self.button setBackgroundImage:[UIImage imageNamed:@"card_white.png"] forState:UIControlStateNormal];
        self.isSelected = false;
    } else {
        NSString *image = [NSString stringWithFormat:@"card_highlight_%@.png", self.card.color];
        [self.button setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        self.transform = CGAffineTransformScale(self.transform, ZOOM, ZOOM);
        self.isSelected = true;
    }
    [self setAnchorPoint:CGPointMake(0.5, 0.5)];
}

@end
