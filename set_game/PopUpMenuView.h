//
//  PopUpMenuView.h
//  set_game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetGame.h"
#import "HighScores.h"

@class PopUpMenuView;
@protocol PopUpMenuViewDelegate
@optional
-(void)cancelPressedForPopUp:(PopUpMenuView *)view;
-(void)menuPressedForPopUp:(PopUpMenuView *)view;
-(void)playAgainPressedForPopUp:(PopUpMenuView *)view;
-(void)leaderboardPressedForPopUp:(PopUpMenuView *)view;
@end

@interface PopUpMenuView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *leaderboardTableView;
@property (strong, nonatomic) UITableView *foundSetsTableView;
@property (strong, nonatomic) UIView *menuView;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) HighScores *highScores;

@property (strong, nonatomic) UILabel *setsFoundLabel;
@property (strong, nonatomic) UILabel *incorrectLabel;
@property (strong, nonatomic) UILabel *hintsLabel;
@property (strong, nonatomic) UILabel *subscoreLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *finalScoreLabel;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIButton *playAgainButton;

-(id)initWithFrame:(CGRect)frame setGame:(SetGame *)game highScores:(HighScores *)scores;
-(void)setUpLeaderboard:(bool)displayCancel;
-(void)setUpFoundSets;
-(void)setUpCongratulations;
-(void)animateFinalScoreTallyWithDelay:(float)delay;

@end