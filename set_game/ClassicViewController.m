//
//  ClassicViewController.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "ClassicViewController.h"
#import "ClassicGame.h"
#import "CardView.h"
#import "HighScores.h"

#define POOF_DURATION 0.5

@interface ClassicViewController ()
@property (nonatomic, strong) UIImage *poof;
@end

@implementation ClassicViewController
@synthesize poof ;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil game:(ClassicGame *)aGame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil game:aGame];
    if (self) {
        poof = [UIImage animatedImageNamed:@"poof" duration:POOF_DURATION];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)replaceCards
{
    for (int i = 0; i < self.game.selectedCards.count; i++) {
        Card *selectedCard = [self.game.selectedCards objectAtIndex:i];
        int index = [self.game.cards indexOfObject:selectedCard];
        CardView *oldCardView = [self.cardViews objectAtIndex:index];
        Card *newCard = [self.game replaceCard:selectedCard];
        if (newCard) {
            CGRect deckRect = CGRectMake(self.view.frame.size.width - DECK_MARGIN - DECK_WIDTH/2, self.view.frame.size.height - SCOREBOARD_BOTTOM_MARGIN - SCOREBOARD_HEIGHT/2,
                                         CARD_WIDTH, CARD_HEIGHT);
            CardView *newCardView = [[CardView alloc] initWithFrame:deckRect FromCard:newCard];
            [newCardView.button addTarget:self action:@selector(cardSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self.cardViews replaceObjectAtIndex:index withObject:newCardView];            
            [newCardView setAnchorPoint:CGPointMake(0, 0)];
            newCardView.transform = CGAffineTransformScale(newCardView.transform, 0.0000001, 0.0000001);
            [self.view addSubview:newCardView];
        } else {
            [self.cardViews removeObjectAtIndex:index];
        }
        [oldCardView removeFromSuperview];
        UIImageView *poofView = [[UIImageView alloc] initWithImage:self.poof];
        poofView.frame = CGRectMake(oldCardView.frame.origin.x + oldCardView.frame.size.width/2 - poofView.frame.size.width/2,
                                     oldCardView.frame.origin.y + oldCardView.frame.size.height/2 - poofView.frame.size.height/2,
                                     poofView.frame.size.width,
                                     poofView.frame.size.height);
        [self.view addSubview:poofView];
        [poofView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:POOF_DURATION - 0.08];
    }
    [self.game.selectedCards removeAllObjects];
    [self performSelector:@selector(arrangeCards) withObject:nil afterDelay:POOF_DURATION];
}

-(void)updateScoreboard
{
    [super updateScoreboard];
    [self.cardsLeftLabel setText:[NSString stringWithFormat:@"%d", self.game.availableCards.count]];
}

-(bool)gameDidEnd
{
    if(self.game.cards.count == 0) {
        return true;
    } else if(self.game.availableCards.count == 0) {
        NSArray *wrapper = [self.game findSets:1];
        if (wrapper == nil) {
            self.gameEnded = true;
            return true;
        }
    }
    self.gameEnded = false;
    return false;
}

-(HighScores *)getHighScores
{
    HighScores *highScores = [[HighScores alloc] initWithScores:CLASSIC_HIGH_SCORES];
    return highScores;
}

@end
