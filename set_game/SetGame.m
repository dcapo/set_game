//
//  SetGame.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "SetGame.h"

@implementation SetGame

@synthesize features,numbers,colors,shadings,shapes;
@synthesize cards, selectedCards, allCards, availableCards, trashedCards;
@synthesize foundSets, incorrectGuesses, hints, score, time;

-(void)generateAllCards
{

    for (NSString *number in numbers) {
        for (NSString *color in colors) {
            for (NSString *shading in self.shadings) {
                for (NSString *shape in self.shapes) {
                    Card *newCard = [[Card alloc] initWithNumber:number color:color shading:shading shape:shape];
                    [allCards addObject:newCard];
                    [availableCards addObject:newCard];
                }
            }
        }
    }
    
//    Card *c1 = [[Card alloc] initWithNumber:@"one" color:@"red" shading:@"solid" shape:@"squiggle"];
//    [allCards addObject:c1];
//    [availableCards addObject:c1];
//    
//    Card *c2 = [[Card alloc] initWithNumber:@"two" color:@"green" shading:@"solid" shape:@"diamond"];
//    [allCards addObject:c2];
//    [availableCards addObject:c2];
//    
//    Card *c3 = [[Card alloc] initWithNumber:@"two" color:@"green" shading:@"solid" shape:@"squiggle"];
//    [allCards addObject:c3];
//    [availableCards addObject:c3];
    
}

/**
 * Chooses the first batch of cards to display in the game.
 */
-(void)dealCards
{
    NSMutableArray *availableCardsArray = [NSMutableArray arrayWithArray:[self.availableCards allObjects]];
    for(int i=0; i < NUM_CARDS; i++) {
        int randomIndex = rand()%self.availableCards.count;
        Card *card = [availableCardsArray objectAtIndex:randomIndex];
        [self.cards addObject:card];
        [self.availableCards removeObject:card];
        [availableCardsArray removeObjectAtIndex:randomIndex];
    }
}

+(NSArray *)features {
    return [NSArray arrayWithObjects:@"number", @"color", @"shading", @"shape", nil];
}

+(NSArray *)numbers {
    return [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
}

+(NSArray *)colors {
    return [NSArray arrayWithObjects:@"red", @"green", @"purple", nil];
}

+(NSArray *)shadings {
    return [NSArray arrayWithObjects:@"solid", @"striped", @"open", nil];
}

+(NSArray *)shapes {
    return [NSArray arrayWithObjects:@"diamond", @"squiggle", @"oval", nil];
}

-(void)setup 
{
    features = [SetGame features];
    numbers = [SetGame numbers];
    colors = [SetGame colors];
    shadings = [SetGame shadings];
    shapes = [SetGame shapes];
    
    cards = [[NSMutableArray alloc] init];
    selectedCards = [[NSMutableArray alloc] init];
    availableCards = [[NSMutableSet alloc] init];
    trashedCards = [[NSMutableSet alloc] init];
    allCards = [[NSMutableSet alloc] init];
    foundSets = [[NSMutableArray alloc] init];
    [self generateAllCards];
    
    score = 0;
    time = 0;
    incorrectGuesses = 0;
}

-(id)init 
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(bool)evaluateFeature:(NSString *)feature inSet:(NSArray *)set
{
    NSMutableSet *typesInSet = [[NSMutableSet alloc] init];
    NSString *typeOne = [(Card *)[set objectAtIndex:0] getFeature:feature];
    NSString *typeTwo = [(Card *)[set objectAtIndex:1] getFeature:feature];
    NSString *typeThree = [(Card *)[set objectAtIndex:2] getFeature:feature];
    [typesInSet addObject:typeOne];
    [typesInSet addObject:typeTwo];
    [typesInSet addObject:typeThree];  
    if ([typesInSet count] == 2) {
        return false;
    } else {
        return true;
    }
}

-(bool)evaluateSet:(NSArray *)set
{
    for (int i = 0; i < self.features.count; i++) {
        if ([self evaluateFeature:[self.features objectAtIndex:i] inSet:set] == false) {
            return false;
        }
    }
    return true;
}

-(NSArray *)findSets:(int)numSetsToFind
{
    NSMutableArray *sets = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.cards.count - 2; i++) {
        for (int j = i+1; j < self.cards.count - 1; j++) {
            for (int k = j+1; k < self.cards.count; k++) {
                NSArray *potentialSet = [NSArray arrayWithObjects: [self.cards objectAtIndex:i], [self.cards objectAtIndex:j], [self.cards objectAtIndex:k], nil];
                if ([self evaluateSet:potentialSet]) {
                    [sets addObject:potentialSet];
                    if (sets.count == numSetsToFind) {
                        return sets;
                    }
                }
            }
        }
    }
    return nil;
}

-(NSArray *)getSetsInDeal
{
    NSMutableArray *sets = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.cards.count - 2; i++) {
        for (int j = i+1; j < self.cards.count - 1; j++) {
            for (int k = j+1; k < self.cards.count; k++) {
                NSArray *potentialSet = [NSArray arrayWithObjects: [self.cards objectAtIndex:i], [self.cards objectAtIndex:j], [self.cards objectAtIndex:k], nil];
                if ([self evaluateSet:potentialSet]) {
                    [sets addObject:potentialSet];
                }
            }
        }
    }
    return sets;
}

+(Card *)getRandomCard {
    NSArray *numbers = [SetGame numbers];
    NSArray *colors = [SetGame colors];
    NSArray *shadings = [SetGame shadings];
    NSArray *shapes = [SetGame shapes];
    Card *card = [[Card alloc] initWithNumber:[numbers objectAtIndex:(rand()%numbers.count)]
                                        color:[colors objectAtIndex:(rand()%colors.count)]
                                      shading:[shadings objectAtIndex:(rand()%shadings.count)]
                                        shape:[shapes objectAtIndex:(rand()%shapes.count)]];
    return card;
}

-(Card *)replaceCard:(Card *)cardToReplace {return nil;}
-(int)getFinalScore {return -1;}

@end
