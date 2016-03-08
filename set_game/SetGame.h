//
//  SetGame.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

#define NUM_CARDS 12
#define NUM_COLS 3
#define NUM_ROWS 4
#define NUM_TYPES 3
#define NUM_FEATURES 4
#define POINT_BASE 1000
#define TIME_BASE 1000

@interface SetGame : NSObject

@property (nonatomic, strong) NSArray *features;
@property (nonatomic, strong) NSArray *numbers;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *shadings;
@property (nonatomic, strong) NSArray *shapes;

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) NSMutableArray *selectedCards;
@property (nonatomic, strong) NSMutableSet *allCards;
@property (nonatomic, strong) NSMutableSet *availableCards;
@property (nonatomic, strong) NSMutableSet *trashedCards;

@property (nonatomic, strong) NSMutableArray *foundSets;
@property int incorrectGuesses;
@property int hints;
@property int score;
@property int time;


-(id)init; 
-(bool)evaluateSet:(NSArray *)set;
-(void)dealCards;
-(void)generateAllCards;
-(Card *)replaceCard:(Card *)card;
-(NSArray *)findSets:(int)numSetsToFind;
-(NSArray *)getSetsInDeal;
-(int)getFinalScore;

+(Card *)getRandomCard;

@end