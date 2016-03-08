//
//  CardView.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "UIView+Animation.h"

@interface CardView : UIView
@property (nonatomic, strong) Card *card;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *glow;
@property bool isSelected;

- (id)initWithFrame:(CGRect)frame FromCard:(Card *)aCard;
- (void)toggleHighlight;
@end
