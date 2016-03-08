//
//  HighScores.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "HighScores.h"

static NSString * const classicHighScoresPlist = @"classic_highscores.plist";
static NSString * const classicHighScoresKey = @"ClassicHighScores";
static NSString * const puzzleHighScoresPlist = @"puzzle_highscores.plist";
static NSString * const puzzleHighScoresKey = @"PuzzleHighScores";

static NSString *plist;
static NSString *key;

@interface HighScores(Private)

- (void)saveHighScores;
- (void)loadHighScores;

@end

@implementation HighScores

@synthesize highScoresArray = m_highScoresArray;

- (id)initWithScores:(int)scoreListConstant
{
    if(self = [super init]){
        m_highScoresArray = [[NSMutableArray alloc] init];
        if (scoreListConstant == CLASSIC_HIGH_SCORES) {
            plist = classicHighScoresPlist;
            key = classicHighScoresKey;
        } else {
            plist = puzzleHighScoresPlist;
            key = puzzleHighScoresKey;
        }
        [self loadHighScores];
    }
    return self;
}

- (BOOL)isHighScore:(int)score
{
    if([m_highScoresArray count] < 10) {
        return YES;
    }
    for(int i = 0; i < [m_highScoresArray count]; i++) {
        NSArray * currentScoreArray = [m_highScoresArray objectAtIndex:i];
        int currentScore = [[currentScoreArray objectAtIndex:0] intValue];
        if(score > currentScore) {
            return YES;
        }
    }
    return NO;
}

- (void)saveScore:(int)score withTime:(int)time subscore:(int)subscore incorrect:(int)incorrect hints:(int)hints date:(NSDate *)date
{
    NSArray * scoreArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:score],
                                                     [NSNumber numberWithInt:time], 
                                                     [NSNumber numberWithInt:subscore],
                                                     [NSNumber numberWithInt:incorrect],
                                                     [NSNumber numberWithInt:hints],
                                                     date, nil];
    if([m_highScoresArray count] == 0 || ([m_highScoresArray count] < 10 && [[[m_highScoresArray lastObject] objectAtIndex:0] intValue] >= score)) {
        [m_highScoresArray addObject:scoreArray];
    }
    else {
        for(int i = 0; i < [m_highScoresArray count]; i++) {
            NSArray * currentScoreArray = [m_highScoresArray objectAtIndex:i];
            int currentScore = [[currentScoreArray objectAtIndex:0] intValue];
            if(score > currentScore) {
                [m_highScoresArray insertObject:scoreArray atIndex:i];
                break;
            }
        }
        if([m_highScoresArray count] > 10) {
            [m_highScoresArray removeLastObject];
        }
    }
    [self saveHighScores];
}

- (void)loadHighScores
{
    NSString * cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * highScoresFile = [cachesDirectory stringByAppendingPathComponent:plist];
    m_highScoresArray = [NSMutableArray arrayWithArray:[[NSDictionary dictionaryWithContentsOfFile:highScoresFile] objectForKey:key]];
}

- (void)saveHighScores
{
    NSString * cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * highScoresFile = [cachesDirectory stringByAppendingPathComponent:plist];
    NSDictionary * highScoresDictionary = [NSDictionary dictionaryWithObject:m_highScoresArray forKey:key];
    [highScoresDictionary writeToFile:highScoresFile atomically:YES];
}

@end
