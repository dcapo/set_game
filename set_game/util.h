//
//  util.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LEADERBOARD_TABLE_ROW_HEIGHT 50
#define TABLE_HEADER_FONT_SIZE 20.0
#define NOTHING_THERE_FONT_SIZE 20.0
#define NOTHING_THERE_MARGIN 15

@interface util : NSObject

+(float)degreesToRadians:(float)degrees;
+(NSString *)intToHms:(int)timeInt;
+(UIButton *)buttonWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title fontSize:(float)fontSize;
+(void)configureLeaderboardTableView:(UITableView *)tableView delegate:(id)delegate;
+(UILabel *)labelWithOrigin:(CGPoint)origin text:(NSString *)text fontSize:(float)fontSize;
+(void)addObserverForNotifications:(id)observer inSelector:(SEL)inSelector outSelector:(SEL)outSelector;
@end
