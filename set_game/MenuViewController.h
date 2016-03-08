//
//  MenuViewController.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *classicButton;
@property (weak, nonatomic) IBOutlet UIButton *puzzleButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@end
