//
//  LeaderboardDetailCell.h
//  set_game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *subscore;
@property (weak, nonatomic) IBOutlet UILabel *incorrect;
@property (weak, nonatomic) IBOutlet UILabel *hints;
@property (weak, nonatomic) IBOutlet UILabel *date;
+ (NSString *)reuseIdentifier;

@end
