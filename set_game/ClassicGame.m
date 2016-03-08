//
//  ClassicGame.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "ClassicGame.h"

@implementation ClassicGame

-(Card *)replaceCard:(Card *)cardToReplace
{
    int cardToReplaceIndex = [self.cards indexOfObject:cardToReplace];
    NSMutableArray *availableCardsArray = [NSMutableArray arrayWithArray:[self.availableCards allObjects]];
    if (availableCardsArray.count == 0) {
        [self.cards removeObjectAtIndex:cardToReplaceIndex];
        return nil;
    } else {
        int randomIndex = rand()%self.availableCards.count;
        Card *newCard = [availableCardsArray objectAtIndex:randomIndex];
        [self.cards replaceObjectAtIndex:cardToReplaceIndex withObject:newCard];
        [self.availableCards removeObject:newCard];
        return newCard;
    }
}

-(int)getFinalScore
{
    int pointMax = self.score + self.incorrectGuesses;
    float points = self.score - (0.5 * self.hints);
    float a = 0.9;
    float b = 0.9993;
    float pointScore = POINT_BASE * powf(a, pointMax - points);
    float timeScore = TIME_BASE * powf(b, self.time);
    return floorf(pointScore + timeScore + 0.5);
}

@end
