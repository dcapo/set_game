//
//  HighScores.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CLASSIC_HIGH_SCORES 0
#define PUZZLE_HIGH_SCORES 1

@interface HighScores : NSObject
{
    NSMutableArray * m_highScoresArray;
}

- (BOOL)isHighScore:(int)score;
- (void)saveScore:(int)score withTime:(int)time subscore:(int)subscore incorrect:(int)incorrect hints:(int)hints date:(NSDate *)date;
-(id)initWithScores:(int)scoreListConstant;
- (void)loadHighScores;

@property (readonly) NSMutableArray * highScoresArray;

@end
