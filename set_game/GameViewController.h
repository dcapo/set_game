//
//  GameViewController.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetGame.h"
#import "CardView.h"
#import "PopUpMenuView.h"

// Abstract Class
@interface GameViewController : UIViewController <PopUpMenuViewDelegate>

//#define CARD_MARGIN_X 0
//#define CARD_MARGIN_Y 2
//#define CARD_WIDTH 105
//#define CARD_HEIGHT 91
//#define Y_0 40
#define CARD_MARGIN_X 6
#define CARD_MARGIN_Y 8
#define CARD_WIDTH 98
#define CARD_HEIGHT 85
#define Y_0 44

#define SCOREBOARD_HEIGHT 50
#define SCOREBOARD_BOTTOM_MARGIN 5
#define SCOREBOARD_DURATION 0.5
#define SCOREBOARD_DELAY 0.2
#define TOP_MENU_HEIGHT 38
#define TOP_MENU_WIDTH 320
#define SCORE_WIDTH 75
#define SCORE_RIGHT_MARGIN 10
#define CARDS_LEFT_WIDTH 85
#define CARDS_LEFT_MARGIN 10
#define DECK_WIDTH 50
#define DECK_HEIGHT 35
#define DECK_MARGIN 5
#define INITIAL_DEAL_DELAY 0.8
#define DEAL_DELAY 0.1
#define HINT_DELAY 0.2
#define MESSAGE_ZOOM 3.0
#define TINY_VALUE 0.0000001
#define PROMPTER_X 83
#define PROMPTER_Y 4
#define PROMPTER_WIDTH 140
#define PROMPTER_HEIGHT 28
#define POP_UP_DURATION 0.6

@property (nonatomic, strong) SetGame *game;
@property (nonatomic, strong) NSMutableArray *cardViews;
@property (nonatomic, strong) PopUpMenuView *popUpMenuView;
@property (nonatomic, weak) IBOutlet UIButton *noSetButton;
@property (nonatomic, weak) IBOutlet UILabel *cardsLeftLabel;
@property (nonatomic, strong) UIImageView *pausedView;
@property (nonatomic, strong) NSArray *congratulatoryPhrases;
@property bool gameEnded;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil game:(SetGame *)aGame;
-(void)replaceCards;
-(void)refreshBoard;
-(void)arrangeCards;
-(bool)gameDidEnd;
-(void)saveScore;
-(void)animatePopUpForView:(UIView *)view;
-(void)updateScoreboard;
-(void)togglePause:(bool)pause;
-(HighScores *)getHighScores;

@end
