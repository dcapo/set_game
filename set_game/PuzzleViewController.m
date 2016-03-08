//
//  PuzzleViewController.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "PuzzleViewController.h"
#import "PuzzleGame.h"
#import "util.h"
#import "HighScores.h"

#define NUM_SETS_TO_FIND 6
#define FOUND_SETS_FONT_SIZE 24.0
#define FLIP_DURATION 1.5

@interface PuzzleViewController ()

@end

@implementation PuzzleViewController
@synthesize foundSetsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil game:(PuzzleGame *)aGame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil game:aGame];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.cardsLeftLabel setText:@"0"];
    UIView *parentView = [self.noSetButton superview];
    foundSetsButton = [util buttonWithFrame:self.noSetButton.frame image:[UIImage imageNamed:@"sets_button.png"] title:nil fontSize:FOUND_SETS_FONT_SIZE];
    [self.noSetButton removeFromSuperview];
    [self.foundSetsButton addTarget:self action:@selector(foundSetsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:self.foundSetsButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)foundSetsButtonPressed {
    [self.pausedView removeFromSuperview];
    [self.popUpMenuView setUpFoundSets];
    [self animatePopUpForView:self.popUpMenuView.menuView];
    if(!self.gameEnded) {
        [self togglePause:true];
    }
}

-(bool)gameDidEnd
{
    if (self.game.foundSets.count == NUM_SETS_TO_FIND) {
        self.gameEnded = true;
        return true;
    }
    self.gameEnded = false;
    return false;
}

-(HighScores *)getHighScores
{
    HighScores *highScores = [[HighScores alloc] initWithScores:PUZZLE_HIGH_SCORES];
    return highScores;
}

-(void)flipCard:(CardView *)cv {
    [cv setAnchorPoint:CGPointMake(0.5, 0.5)];
    CGRect f0 = cv.frame;
    [UIView animateWithDuration:FLIP_DURATION/4.0 delay:0.0 options:0 animations:^{
        cv.transform = CGAffineTransformScale(cv.transform, TINY_VALUE, 1);
    } completion: ^(BOOL finished) {
        UIImageView *cardBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_back.png"]];
        cardBack.frame = f0;
        [self.view insertSubview:cardBack atIndex:1];
        [cardBack setAnchorPoint:CGPointMake(0.5, 0.5)];
        cardBack.transform = CGAffineTransformScale(cardBack.transform, TINY_VALUE, 1);
        [UIView animateWithDuration:FLIP_DURATION/4.0 delay:0.0 options:0 animations:^{
            cardBack.transform = CGAffineTransformScale(cardBack.transform, 1/TINY_VALUE, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:FLIP_DURATION/4.0 delay:0.0 options:0 animations:^{
                cardBack.transform = CGAffineTransformScale(cardBack.transform, TINY_VALUE, 1);
            } completion:^(BOOL finished) {
                [cardBack removeFromSuperview];
                [UIView animateWithDuration:FLIP_DURATION/4.0 delay: 0.0 options:0 animations:^ {
                    cv.transform = CGAffineTransformScale(cv.transform, 1/TINY_VALUE, 1);
                } completion:^(BOOL finished) {
                }];
            }];
        }];
    }];
}

-(void)replaceCards
{
    [self performSelector:@selector(refreshBoard) withObject:nil afterDelay:0];
    for (int i = 0; i < self.game.selectedCards.count; i++) {
        Card *selectedCard = [self.game.selectedCards objectAtIndex:i];
        int index = [self.game.cards indexOfObject:selectedCard];
        CardView *cv = [self.cardViews objectAtIndex:index];
        [self flipCard:cv];
    }
}

@end
