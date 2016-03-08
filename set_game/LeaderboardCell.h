//
//  LeaderboardCell.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *date;
+ (NSString *)reuseIdentifier;
@end
