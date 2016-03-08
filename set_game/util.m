//
//  util.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "util.h"

@implementation util

+(float)degreesToRadians:(float)degrees
{
    return M_PI * degrees / 180.0;
}

+(NSString *)intToHms:(int)timeInt
{
    int seconds = timeInt % 60;
    int minutes = (timeInt / 60) % 60;
    return [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
}

+(UIButton *)buttonWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title fontSize:(float)fontSize
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *background = image;
    [button setBackgroundImage:background forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = true;
    button.adjustsImageWhenDisabled = true;
    button.frame = frame;
    if(title != nil) {
        button.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:fontSize];
        [button setTitle:title forState:UIControlStateNormal];
    }
    return button;
}

+(void)configureLeaderboardTableView:(UITableView *)tableView delegate:(id)delegate
{
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorColor = [UIColor clearColor];
    tableView.rowHeight = LEADERBOARD_TABLE_ROW_HEIGHT;
    
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
}

+(UILabel *)labelWithOrigin:(CGPoint)origin text:(NSString *)text fontSize:(float)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:fontSize];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    CGSize size = [text sizeWithFont:label.font];
    label.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    return label;
}

+(void)addObserverForNotifications:(id)observer inSelector:(SEL)inSelector outSelector:(SEL)outSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:outSelector
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:inSelector
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}
@end
