//
//  PuzzleGame.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "PuzzleGame.h"

@implementation PuzzleGame


-(void)dealCards
{
    NSMutableSet *origAvailableCards = [NSMutableSet setWithSet:self.availableCards];
    int count = 0;
    while (true) {
        [super dealCards];
        NSArray *wrapper = [self getSetsInDeal];
        if(wrapper.count == NUM_SETS_TO_FIND) {   
            return;
        } else {
            [self.cards removeAllObjects];
            self.availableCards = [NSMutableSet setWithSet:origAvailableCards];
        }
        count++;
    }
}

-(int)getFinalScore {
    int pointMax = self.score + self.incorrectGuesses;
    float points = self.score - (0.5 * self.hints);
    float a = 0.9;
    float b = 0.995;
    float pointScore = POINT_BASE * powf(a, pointMax - points);
    float timeScore = TIME_BASE * powf(b, self.time);
    return floorf(pointScore + timeScore + 0.5);
}

@end
