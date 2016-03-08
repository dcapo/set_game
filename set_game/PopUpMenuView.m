//
//  PopUpMenuView.m
//  set_game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "PopUpMenuView.h"
#import "LeaderboardCell.h"
#import "FoundSetCell.h"
#import "UIView+Animation.h"
#import "util.h"
#import "CardView.h"
#import "PuzzleGame.h"
#import "ClassicGame.h"
#import "SetGame.h"

#define TABLE_WIDTH 215
#define LEADERBOARD_TABLE_HEIGHT 255
#define FOUND_SETS_TABLE_HEIGHT 278
#define TABLE_Y 93
#define FOUND_SETS_TABLE_ROW_HEIGHT 60
#define TITLE_Y 10
#define MENU_Y 43
#define MENU_WIDTH 254
#define MENU_HEIGHT 366
#define MENU_SHORT_HEIGHT 150
#define SCORE_LABEL_X 24
#define TIME_LABEL_X 81
#define SUBSCORE_LABEL_X 126
#define DATE_LABEL_X 191
#define TABLE_HEADER_Y 69
#define CANCEL_X -16
#define CANCEL_Y -19
#define YOU_DID_IT_WIDTH 220
#define STATS_FONT_SIZE 20.0
#define STATS_Y0 65
#define STATS_MARGIN 1
#define STATS_CENTER_OFFSET 20
#define BUTTON_WIDTH 150
#define BUTTON_HEIGHT 28
#define BUTTON_TOP_MARGIN 10
#define BUTTON_MARGIN 10
#define BUTTON_FONT_SIZE 18.0
#define CARD_WIDTH 58
#define CARD_HEIGHT 50
#define CARD_MARGIN 5

@interface PopUpMenuView ()
@property (weak, nonatomic) IBOutlet LeaderboardCell *leaderboardCell;
@property (weak, nonatomic) IBOutlet FoundSetCell *foundSetCell;
@property (strong, nonatomic) SetGame *game;
@property (strong, nonatomic) UILabel *tallyLabel;
@end

@implementation PopUpMenuView

@synthesize delegate, game, highScores;
@synthesize leaderboardTableView, leaderboardCell;
@synthesize foundSetsTableView, foundSetCell;
@synthesize menuView, spinner, playAgainButton;
@synthesize setsFoundLabel, hintsLabel, incorrectLabel;
@synthesize timeLabel, subscoreLabel, finalScoreLabel, tallyLabel;

-(UIView *)menuView
{
    if (!menuView) {
        float x = (self.frame.size.width - MENU_WIDTH) / 2;
        CGRect menuFrame = CGRectMake(x, MENU_Y, MENU_WIDTH, MENU_HEIGHT);
        menuView = [[UIView alloc] initWithFrame:menuFrame];
        menuView.opaque = NO;
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"leaderboard_background.png"]];
        menuView.backgroundColor = background;
    }
    return menuView;
}

-(UITableView *)leaderboardTableView
{
    if (!leaderboardTableView) {
        float tableX = (self.menuView.frame.size.width - TABLE_WIDTH) / 2;
        CGRect tableViewFrame = CGRectMake(tableX, TABLE_Y, TABLE_WIDTH, LEADERBOARD_TABLE_HEIGHT);
        leaderboardTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        leaderboardTableView.delegate = self;
        leaderboardTableView.dataSource = self;
        leaderboardTableView.backgroundColor = [UIColor clearColor];
        leaderboardTableView.separatorColor = [UIColor clearColor];
        leaderboardTableView.rowHeight = LEADERBOARD_TABLE_ROW_HEIGHT;
    }
    return leaderboardTableView;
}

-(UITableView *)foundSetsTableView
{
    if (!foundSetsTableView) {
        float tableX = (self.menuView.frame.size.width - TABLE_WIDTH) / 2;
        CGRect tableViewFrame = CGRectMake(tableX, TABLE_HEADER_Y, TABLE_WIDTH, FOUND_SETS_TABLE_HEIGHT);
        foundSetsTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        foundSetsTableView.delegate = self;
        foundSetsTableView.dataSource = self;
        foundSetsTableView.backgroundColor = [UIColor clearColor];
        foundSetsTableView.separatorColor = [UIColor clearColor];
        foundSetsTableView.rowHeight = FOUND_SETS_TABLE_ROW_HEIGHT;
    }
    return foundSetsTableView;
}

-(id)initWithFrame:(CGRect)frame setGame:(SetGame *)setGame highScores:(HighScores *)scores
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.menuView];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        game = setGame;
        highScores = scores;
    }
    return self;
}

-(void)clearMenuViews {
    for (UIView *view in [self.menuView subviews]) {
        [view removeFromSuperview];
    }
}

-(UIImageView *)titleViewWithImageName:(NSString *)imageName {
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    float x = (self.menuView.frame.size.width - titleImageView.frame.size.width) / 2;
    titleImageView.frame = CGRectMake(x,
                                      TITLE_Y,
                                      titleImageView.frame.size.width,
                                      titleImageView.frame.size.height);
    return titleImageView;
}

-(void)animateFinalScoreTallyWithDelay:(float)delay
{
    [tallyLabel setText:@"0"];
    int current = 0;
    int finalScore = [self.game getFinalScore];
    float period = 0.01;
    while ((current + 10) < finalScore) {
        NSString *text = [NSString stringWithFormat:@"%d", current];
        [tallyLabel performSelector:@selector(setText:) withObject:text afterDelay:delay];
        delay += period;
        current+=10;
    }
    while(current <= finalScore) {
        NSString *text = [NSString stringWithFormat:@"%d", current];
        [tallyLabel performSelector:@selector(setText:) withObject:text afterDelay:delay];
        delay += period;
        current++;
    }
}

-(void)setUpCongratulations {
    [self clearMenuViews];
    UIImageView *titleImageView = [self titleViewWithImageName:@"you_did_it.png"];
    [self.menuView addSubview:titleImageView];
    
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    [stats setObject:[NSNumber numberWithInt:self.game.foundSets.count] forKey:@"Sets Found"];
    [stats setObject:[NSNumber numberWithInt:self.game.incorrectGuesses] forKey:@"Incorrect"];
    [stats setObject:[NSNumber numberWithInt:self.game.hints] forKey:@"Hints"];
    [stats setObject:[NSNumber numberWithInt:self.game.score] forKey:@"Subscore"];
    [stats setObject:[NSNumber numberWithInt:self.game.time] forKey:@"Time"];
    [stats setObject:[NSNumber numberWithInt:[self.game getFinalScore]] forKey:@"Final Score"];
    
    int y = STATS_Y0;
    int statsValueX = self.menuView.frame.size.width/2 + STATS_CENTER_OFFSET;
    for (NSString *key in stats) {
        UILabel *keyLabel = [util labelWithOrigin:CGPointMake(0, y) text:key fontSize:STATS_FONT_SIZE];
        float x = self.menuView.frame.size.width/2 - keyLabel.frame.size.width;
        keyLabel.frame = CGRectMake(x, keyLabel.frame.origin.y, keyLabel.frame.size.width, keyLabel.frame.size.height);
        [self.menuView addSubview:keyLabel];
        
        int valueInt = [[stats valueForKey:key] intValue];
        NSString *value;
        if ([key isEqualToString:@"Time"]) {
            value = [util intToHms:valueInt];
        } else {
            value = [NSString stringWithFormat:@"%d", valueInt];
        }
        UILabel *valueLabel = [util labelWithOrigin:CGPointMake(statsValueX, y) text:value fontSize:STATS_FONT_SIZE];
        if ([key isEqualToString:@"Final Score"]) {
            tallyLabel = valueLabel;
        }
        y += (STATS_MARGIN + keyLabel.frame.size.height);
        [self.menuView addSubview:valueLabel];
    }
    
    y += BUTTON_TOP_MARGIN;
    float buttonX = (self.menuView.frame.size.width - BUTTON_WIDTH) / 2;
    UIButton *menuButton = [util buttonWithFrame:CGRectMake(buttonX, y, BUTTON_WIDTH, BUTTON_HEIGHT) image:[UIImage imageNamed:@"red_gradient.png"] title:@"Main Menu" fontSize:BUTTON_FONT_SIZE];
    [menuButton addTarget:self action:@selector(menuPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:menuButton];
    y+= BUTTON_HEIGHT + BUTTON_MARGIN;
    
    playAgainButton = [util buttonWithFrame:CGRectMake(buttonX, y, BUTTON_WIDTH, BUTTON_HEIGHT) image:[UIImage imageNamed:@"green_gradient.png"] title:@"Play Again" fontSize:BUTTON_FONT_SIZE];
    [self.playAgainButton addTarget:self action:@selector(playAgainPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.playAgainButton];
    y+= BUTTON_HEIGHT + BUTTON_MARGIN;
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.frame = CGRectMake(playAgainButton.frame.origin.x + (playAgainButton.frame.size.width - spinner.frame.size.width)/2,
                               playAgainButton.frame.origin.y + (playAgainButton.frame.size.height - spinner.frame.size.height)/2,
                               spinner.frame.size.width,
                               spinner.frame.size.height);
    self.spinner.hidden = YES;
    [self.menuView addSubview:self.spinner];
    
    UIButton *leaderboardButton = [util buttonWithFrame:CGRectMake(buttonX, y, BUTTON_WIDTH, BUTTON_HEIGHT) image:[UIImage imageNamed:@"purple_gradient.png"] title:@"High Scores" fontSize:BUTTON_FONT_SIZE];
    [leaderboardButton addTarget:self action:@selector(leaderboardPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:leaderboardButton];
    
}

-(UIButton *)getCancelButton {
    UIImage *cancelImage = [UIImage imageNamed:@"cancel.png"];
    CGRect buttonFrame = CGRectMake(CANCEL_X, CANCEL_Y, cancelImage.size.width, cancelImage.size.height);
    UIButton *cancelButton = [util buttonWithFrame:buttonFrame image:cancelImage title:nil fontSize:BUTTON_FONT_SIZE];
    [cancelButton addTarget:self action:@selector(cancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    return cancelButton;
}

-(void)setUpFoundSets {
    [self clearMenuViews];
    UIImageView *titleImageView = [self titleViewWithImageName:@"found_sets.png"];
    [self.menuView addSubview:titleImageView];
    
    UIButton *cancelButton = [self getCancelButton];
    [self.menuView addSubview:cancelButton];
    
    if(self.game.foundSets.count > 0) {
        [self.foundSetsTableView reloadData];
        [self.menuView addSubview:self.foundSetsTableView];
    } else {
        NSString *text = @"(No sets found yet)";
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:NOTHING_THERE_FONT_SIZE]];
        CGPoint origin = CGPointMake(self.menuView.frame.size.width/2 - size.width/2, TABLE_Y);
        UILabel *noSetsLabel = [util labelWithOrigin:origin text:text fontSize:NOTHING_THERE_FONT_SIZE];
        [self.menuView addSubview:noSetsLabel];
    }
}

-(void)setUpLeaderboard:(bool)displayCancel {
    [self clearMenuViews];
    UIImageView *titleImageView = [self titleViewWithImageName:@"leaderboard_title.png"];
    [self.menuView addSubview:titleImageView];
    
    CGPoint scoreLabelOrigin = CGPointMake(SCORE_LABEL_X, TABLE_HEADER_Y);
    UILabel *scoreHeader = [util labelWithOrigin:scoreLabelOrigin text:@"Score" fontSize:TABLE_HEADER_FONT_SIZE];
    [self.menuView addSubview:scoreHeader];
    
    CGPoint timeLabelOrigin = CGPointMake(TIME_LABEL_X, TABLE_HEADER_Y);
    UILabel *timeHeader = [util labelWithOrigin:timeLabelOrigin text:@"Time" fontSize:TABLE_HEADER_FONT_SIZE];
    [self.menuView addSubview:timeHeader];
    
    CGPoint setsLabelOrigin = CGPointMake(SUBSCORE_LABEL_X, TABLE_HEADER_Y);
    UILabel *setsHeader = [util labelWithOrigin:setsLabelOrigin text:@"Subscore" fontSize:TABLE_HEADER_FONT_SIZE];
    [self.menuView addSubview:setsHeader];
    
    CGPoint dateLabelOrigin = CGPointMake(DATE_LABEL_X, TABLE_HEADER_Y);
    UILabel *dateHeader = [util labelWithOrigin:dateLabelOrigin text:@"Date" fontSize:TABLE_HEADER_FONT_SIZE];
    [self.menuView addSubview:dateHeader];
    
    if(displayCancel) {
        UIButton *cancelButton = [self getCancelButton];
        [self.menuView addSubview:cancelButton];
    } else {
        self.leaderboardTableView.frame = CGRectMake(self.leaderboardTableView.frame.origin.x,
                                                     self.leaderboardTableView.frame.origin.y,
                                                     self.leaderboardTableView.frame.size.width, 
                                                     LEADERBOARD_TABLE_HEIGHT - BUTTON_HEIGHT - BUTTON_MARGIN);
        float buttonX = (self.menuView.frame.size.width - BUTTON_WIDTH) / 2;
        float buttonY = TABLE_Y + self.leaderboardTableView.frame.size.height + BUTTON_MARGIN;
        UIButton *backButton = [util buttonWithFrame:CGRectMake(buttonX, buttonY, BUTTON_WIDTH, BUTTON_HEIGHT) image:[UIImage imageNamed:@"purple_gradient.png"] title:@"Back" fontSize:BUTTON_FONT_SIZE];
        [backButton addTarget:self action:@selector(setUpCongratulations) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:backButton]; 
    }
    
    NSArray *scores = [self.highScores highScoresArray];
    if (scores.count > 0) {
        [self.leaderboardTableView reloadData];
        [self.menuView addSubview:self.leaderboardTableView];
    } else {
        NSString *text = @"(No high scores yet)";
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:NOTHING_THERE_FONT_SIZE]];
        CGPoint origin = CGPointMake(self.menuView.frame.size.width/2 - size.width/2, TABLE_Y + NOTHING_THERE_MARGIN);
        UILabel *noHighScoresLabel = [util labelWithOrigin:origin text:text fontSize:NOTHING_THERE_FONT_SIZE];
        [self.menuView addSubview:noHighScoresLabel];
    }
}

-(void)cancelPressed:(id)sender {
    [self.delegate cancelPressedForPopUp:self];
}

-(void)menuPressed:(id)sender {
    [self.delegate menuPressedForPopUp:self];
}

-(void)playAgainPressed:(id)sender {
    [self.delegate playAgainPressedForPopUp:self];
}

-(void)leaderboardPressed:(id)sender {
    [self setUpLeaderboard:false];
}


#pragma mark - TableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.leaderboardTableView) {
        NSArray *scores = [self.highScores highScoresArray];
        return scores.count;
    } else {
        return self.game.foundSets.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leaderboardTableView) {
        LeaderboardCell *cell = (LeaderboardCell *)[self.leaderboardTableView dequeueReusableCellWithIdentifier:[LeaderboardCell reuseIdentifier]];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"LeaderboardCell" owner:self options:nil];
            cell = leaderboardCell;
            leaderboardCell = nil;
        }
        NSArray *scoreEntry = [[self.highScores highScoresArray] objectAtIndex:indexPath.row];
        if(scoreEntry) {
            cell.score.text = [NSString stringWithFormat:@"%d", [[scoreEntry objectAtIndex:0]intValue]];
            int time = [[scoreEntry objectAtIndex:1] intValue];
            cell.time.text = [util intToHms:time];
            cell.points.text = [NSString stringWithFormat:@"%d", [[scoreEntry objectAtIndex:2] intValue]];
            NSDate *date = [scoreEntry objectAtIndex:5];
            NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MM-dd"];
            cell.date.text = [dateFormatter stringFromDate:date];
        }
        return cell;
    } else {
        FoundSetCell *cell = (FoundSetCell *)[tableView dequeueReusableCellWithIdentifier:[FoundSetCell reuseIdentifier]];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"FoundSetCell" owner:self options:nil];
            cell = foundSetCell;
            foundSetCell = nil;
        }
        NSArray *set = [[self.game.foundSets objectAtIndex:indexPath.row] allObjects];
        float x = cell.frame.size.width/2 - 1.5*CARD_WIDTH - CARD_MARGIN;
        float y = (cell.frame.size.height - CARD_HEIGHT) / 2;
        for(int i = 0; i < set.count; i++) {
            CGRect frame = CGRectMake(x, y, CARD_WIDTH, CARD_HEIGHT);
            CardView *cv = [[CardView alloc] initWithFrame:frame FromCard:[set objectAtIndex:i]];
            cv.button.adjustsImageWhenDisabled = NO;
            cv.button.enabled = NO; 
            [cell addSubview:cv];
            x += CARD_WIDTH + CARD_MARGIN;
        }
        return cell;
    } 
}

@end
