//
//  GameViewController.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "GameViewController.h"
#import "UIView+Animation.h"
#import "ClassicGame.h"
#import "PuzzleGame.h"
#import "PrompterView.h"
#import "HighScores.h"

@interface GameViewController ()

@end

@implementation GameViewController
{
    IBOutlet UIView *topMenu;
    IBOutlet UIView *scoreboard;
    IBOutlet UIButton *pauseButton;
    IBOutlet UIButton *hintButton;
    IBOutlet UILabel *scoreLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UIView *alertView;
    
    int currentHints;
    bool isPaused;
    NSTimer *timer;
    NSArray *hintSet;
    PrompterView *prompterView;
    UIImageView *pausedView;
}

@synthesize popUpMenuView, noSetButton;
@synthesize game;
@synthesize cardViews;
@synthesize gameEnded;
@synthesize cardsLeftLabel, pausedView, congratulatoryPhrases;

-(PopUpMenuView *)popUpMenuView
{
    if (!popUpMenuView) {
        HighScores *scores = [self getHighScores];
        popUpMenuView = [[PopUpMenuView alloc] initWithFrame:self.view.frame setGame:self.game highScores:scores];
        popUpMenuView.delegate = self;
    }
    return popUpMenuView;
}

-(UIImageView *)pausedView
{
    if (!pausedView) {
        pausedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paused.png"]];
        pausedView.frame = CGRectMake((self.view.frame.size.width - pausedView.frame.size.width)/2,
                                      TOP_MENU_HEIGHT + (self.view.frame.size.height - TOP_MENU_HEIGHT - SCOREBOARD_HEIGHT - pausedView.frame.size.height)/2,
                                      pausedView.frame.size.width,
                                      pausedView.frame.size.height);
    }
    return pausedView;
}

-(void)updateScoreboard
{
    [scoreLabel setText:[NSString stringWithFormat:@"%d", self.game.score]];
    [timeLabel setText:[util intToHms:self.game.time]];
}

-(NSArray *)congratulatoryPhrases {
    if (!congratulatoryPhrases) {
        congratulatoryPhrases = [NSArray arrayWithObjects:@"Nice find!",
                                 @"Great work!",
                                 @"Yeah man.",
                                 @"Ahh yeah!",
                                 @"Excellent!",
                                 @"Good stuff!",
                                 @"Well done!",
                                 @"You got it!",
                                 @"There we go!",
                                 @"Clever spot!",
                                 @"Wonderful!",
                                 nil];
    }
    return congratulatoryPhrases;
}

-(void)oneSecondPassed
{
    self.game.time++;
    [self updateScoreboard];
}

-(void)startTimer
{
    if (!isPaused) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(oneSecondPassed) userInfo:nil repeats:YES];
    }
}

-(void)registerNotifications
{
    [util addObserverForNotifications:self inSelector:@selector(appEnteredForeground) outSelector:@selector(appEnteredBackground)];
}

-(void)appEnteredForeground {
    [self startTimer];
}

-(void)appEnteredBackground {
    [timer invalidate];
}

-(void)animateScoreboard 
{
    CGRect startFrame = CGRectMake(0, -topMenu.frame.size.height, topMenu.frame.size.width, topMenu.frame.size.height);
    topMenu.frame = startFrame;
    
    [UIView animateWithDuration: SCOREBOARD_DURATION
                          delay: SCOREBOARD_DELAY
                        options: (UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         topMenu.transform = CGAffineTransformMakeTranslation(0, topMenu.frame.size.height);
                     }
                     completion:^(BOOL finished) { }
     ];
    
    
    startFrame = CGRectMake(0, self.view.frame.size.height, scoreboard.frame.size.width, scoreboard.frame.size.height);
    scoreboard.frame = startFrame;
    
    [UIView animateWithDuration: SCOREBOARD_DURATION
                          delay: 2*SCOREBOARD_DELAY
                        options: (UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         scoreboard.transform = CGAffineTransformMakeTranslation(0, -scoreboard.frame.size.height);
                     }
                     completion:^(BOOL finished) { }
     ];
}

-(void)drawDeck
{
    CGRect deckRect = CGRectMake(self.view.frame.size.width - DECK_MARGIN - DECK_WIDTH/2,
                                 self.view.frame.size.height - SCOREBOARD_BOTTOM_MARGIN - SCOREBOARD_HEIGHT/2,
                                 CARD_WIDTH, CARD_HEIGHT);
    for (int i = 0; i < self.game.cards.count; i++) {
        Card *card = [self.game.cards objectAtIndex:i];
        CardView *cv = [[CardView alloc] initWithFrame:deckRect FromCard:card];
        [cv.button addTarget:self action:@selector(cardSelected:) forControlEvents:UIControlEventTouchUpInside];

        [cv setAnchorPoint:CGPointMake(0, 0)];
        cv.transform = CGAffineTransformScale(cv.transform, TINY_VALUE, TINY_VALUE);
        
        [self.cardViews addObject:cv];
        [self.view addSubview:cv];
    }
}

-(void)moveAndScaleCard:(id)argument
{
    NSArray *args = (NSArray *)argument;
    CardView *cv = (CardView *)[argument objectAtIndex:0];
    NSValue *scaleValue = [args objectAtIndex:1];
    NSValue *translateValue = [args objectAtIndex:2];
    [cv scale:[scaleValue CGPointValue] AndTranslate:[translateValue CGPointValue] duration:0.5 delay:0.0 option:0];
}

-(void)arrangeCards
{
    [self refreshBoard];
    int x_0 = (self.view.frame.size.width / 2) - CARD_WIDTH/2 - CARD_MARGIN_X - CARD_WIDTH;
    int x = x_0;
    int y = Y_0;
    NSTimeInterval delay = 0;
    for (int i = 0; i < self.cardViews.count; i++) {
        CardView *cv = [self.cardViews objectAtIndex:i];
        CGPoint translate = CGPointMake(x - cv.frame.origin.x, y - cv.frame.origin.y);
        CGPoint scale = CGPointMake(CARD_WIDTH/cv.frame.size.width, CARD_HEIGHT/cv.frame.size.height);
        if (![[NSValue valueWithCGPoint:translate] isEqualToValue:[NSValue valueWithCGPoint:CGPointMake(0, 0)]]) {
            NSArray *argument = [NSArray arrayWithObjects:cv, [NSValue valueWithCGPoint: scale], [NSValue valueWithCGPoint:translate], nil];
            [self performSelector:@selector(moveAndScaleCard:) withObject:argument afterDelay:delay];
            delay += DEAL_DELAY;
        }
        x += CARD_WIDTH + CARD_MARGIN_X;
        if ((x + CARD_WIDTH) > self.view.frame.size.width) {
            x = x_0;
        }
        if ((i + 1)%NUM_COLS == 0) {
            y += CARD_HEIGHT + CARD_MARGIN_Y;
        }
    }
    [self.view setNeedsDisplay];
}

-(void)rearrangeCards
{
    NSMutableArray *cards = [NSMutableArray arrayWithArray:self.game.cards];
    NSMutableArray *cViews = [NSMutableArray arrayWithArray:self.cardViews];
    for (int i = 0; i < self.game.cards.count; i++) {
        int randomIndex = rand() % cards.count;
        Card *randomCard = [cards objectAtIndex:randomIndex];
        CardView *randomCardView = [cViews objectAtIndex:randomIndex];
        [cards removeObjectAtIndex:randomIndex];
        [cViews removeObjectAtIndex:randomIndex];
        [self.game.cards replaceObjectAtIndex:i withObject:randomCard];
        [self.cardViews replaceObjectAtIndex:i withObject:randomCardView];
    }
    [self arrangeCards];
}

-(void)promptMessage:(NSString *)message {
    [prompterView promptMessage:message];
}

-(void)drawGame
{
    [self drawDeck];
    [self updateScoreboard];
    [self animateScoreboard];
    [self performSelector:@selector(arrangeCards) withObject:nil afterDelay:INITIAL_DEAL_DELAY];
    [self performSelector:@selector(promptMessage:) withObject:@"Game on!" afterDelay:INITIAL_DEAL_DELAY];
    float delay = 1.0 + DEAL_DELAY * (NUM_CARDS - 1);
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:delay];
    [self performSelector:@selector(registerNotifications) withObject:nil afterDelay:delay];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil game:(SetGame *)aGame
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        game = aGame;
        cardViews = [[NSMutableArray alloc] init];
        [game dealCards];
        currentHints = 0;
        gameEnded = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isPaused = false;
    [self drawGame];
    CGRect prompterRect = CGRectMake(PROMPTER_X, PROMPTER_Y, PROMPTER_WIDTH, PROMPTER_HEIGHT);
    prompterView = [[PrompterView alloc] initWithFrame:prompterRect];
    [topMenu addSubview:prompterView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)animateMessage:(NSString *)message inColor:(UIColor *)color {
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.transform = CGAffineTransformIdentity;
    messageLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:48];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = color;
    messageLabel.alpha = 1.0;
    CGSize size = [message sizeWithFont:[messageLabel font]];
    [messageLabel setText:message];
    
    messageLabel.frame = CGRectMake(self.view.frame.size.width/2 - size.width/2, self.view.frame.size.height/2 - size.height/2, size.width, size.height);
    messageLabel.transform = CGAffineTransformMakeScale(1.0/MESSAGE_ZOOM, 1.0/MESSAGE_ZOOM);
    [self.view addSubview:messageLabel];
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationCurveEaseInOut 
                     animations:^ {
                         messageLabel.alpha = 0.0;
                         messageLabel.transform = CGAffineTransformMakeScale(MESSAGE_ZOOM, MESSAGE_ZOOM);
                     } 
                     completion:^(BOOL finished) {
                         [messageLabel removeFromSuperview];
                     }];
    
}

-(void)refreshBoard
{
    for (int i = 0; i < self.game.selectedCards.count; i++) {
        Card *selectedCard = [self.game.selectedCards objectAtIndex:i];
        int index = [self.game.cards indexOfObject:selectedCard];
        CardView *oldCardView = [self.cardViews objectAtIndex:index];
        if (oldCardView.isSelected) {
            [oldCardView toggleHighlight];
        }
    }
    [self.game.selectedCards removeAllObjects];
}

-(void)handleIncorrectGuess {
    [self animateMessage:@"Wrong" inColor:[UIColor redColor]];
    self.game.incorrectGuesses++;
    self.game.score--;
    [self updateScoreboard];
}

-(void)handleCorrectGuess:(NSString *)message {
    [self animateMessage:message inColor:[UIColor colorWithRed:0 green:0.7 blue:0.3 alpha:1]];
    int randomIndex = rand() % self.congratulatoryPhrases.count;
    NSString *prompt = [self.congratulatoryPhrases objectAtIndex:randomIndex];
    if ([self.game isKindOfClass:[PuzzleGame class]]) {
        int setsToGo = NUM_SETS_TO_FIND - self.game.foundSets.count;
        if (setsToGo > 0) {
            prompt = [NSString stringWithFormat:@"%@ %d %@ to go!", prompt, setsToGo, (setsToGo == 1) ? @"set" : @"sets"];
        }
    }
    [prompterView promptMessage:prompt];
    self.game.score++;
    [self updateScoreboard];
}

-(void)handleNoSets {
    NSMutableArray *randomIndices = [[NSMutableArray alloc] init];
    while (randomIndices.count < 3) {
        int randomIndex = rand() % [self.game.cards count];
        if (![randomIndices containsObject:[NSNumber numberWithInt:randomIndex]]) {
            [randomIndices addObject:[NSNumber numberWithInt:randomIndex]];
        }
    }
    for (int i = 0; i < 3; i++) {
        int randomIndex = [[randomIndices objectAtIndex:i] intValue];
        Card *randomCard = [self.game.cards objectAtIndex:randomIndex];
        [self.game.selectedCards addObject:randomCard];
    }
    [self replaceCards];
    if([self gameDidEnd]) {
        [self handleEndOfGame];
    } else {
        currentHints = 0;
    }
}

-(void)togglePause:(bool)pause {
    if (pause) {
        for (CardView *cv in self.cardViews) {
            cv.hidden = true;
        }
        [timer invalidate];
        isPaused = true;
        noSetButton.enabled = NO;
        hintButton.enabled = NO;
    } else {
        for (CardView *cv in self.cardViews) {
            cv.hidden = false;
        }
        isPaused = false;
        [self startTimer];
        noSetButton.enabled = YES;
        hintButton.enabled = YES;
    }
}

- (IBAction)pausePressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (isPaused) {
        [button setBackgroundImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
        [self.pausedView fade:false duration:0.5];
        [self.pausedView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(togglePause:) withObject:[NSNumber numberWithBool:!isPaused] afterDelay:0.5];
        
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        self.pausedView.alpha = 0;
        [self.view addSubview:self.pausedView];
        [self.pausedView fade:true duration:0.5];
        [self togglePause:!isPaused];
    }
}

-(void)animatePopUpForView:(UIView *)view {
    UIView *superview = [view superview];
    if (![superview isDescendantOfView:self.view]) {
        [view setAnchorPoint:CGPointMake(0.5, 0.5)];
        float scaleT0 = TINY_VALUE;
        view.transform = CGAffineTransformScale(view.transform, scaleT0, scaleT0);
        [self.view addSubview:superview];
        float scaleT1 = 1.2;
        [view popToMaxSize:CGPointMake(scaleT1/TINY_VALUE, scaleT1/TINY_VALUE)
                   endSize:CGPointMake(1/scaleT1, 1/scaleT1)
            withExpandTime:POP_UP_DURATION/2.0
               compactTime:POP_UP_DURATION/2.0
                completion:nil];
    }
}

-(void)animatePopUpRemovalForView:(UIView *)view {
    UIView *superview = [view superview];
    if ([superview isDescendantOfView:self.view]) {
        [view setAnchorPoint:CGPointMake(0.5, 0.5)];
        float scaleT1 = 1.2;
        [view popToMaxSize:CGPointMake(scaleT1, scaleT1)
                   endSize:CGPointMake(TINY_VALUE, TINY_VALUE)
            withExpandTime:0.3
               compactTime:0.3
                completion:^(BOOL finished) {
                    view.transform = CGAffineTransformIdentity;
                    [superview removeFromSuperview];
                }];
    }
}

-(void)handleEndOfGame {
    [timer invalidate];
    int finalScore = [self.game getFinalScore];
    if ([self.popUpMenuView.highScores isHighScore:finalScore]) {
        [self.popUpMenuView.highScores saveScore:finalScore withTime:self.game.time subscore:self.game.score incorrect:self.game.incorrectGuesses hints:self.game.hints date:[NSDate date]];
    }
    
    [self.popUpMenuView.highScores loadHighScores];
    [self.popUpMenuView setUpCongratulations];
    [self animatePopUpForView:self.popUpMenuView.menuView];
    [self.popUpMenuView animateFinalScoreTallyWithDelay:2.0];
}

-(void)handleSet {
    NSSet *set = [NSSet setWithArray:self.game.selectedCards];
    if ([self.game.foundSets containsObject:set]) {
        [prompterView promptMessage:@"You already guessed that set!"];
        [self animateMessage:@"Set!" inColor:[UIColor yellowColor]];
        [self refreshBoard];
    } else {
        [self.game.foundSets addObject:set];
        [self handleCorrectGuess:@"Set!"];
        [self replaceCards];
    }
    if([self gameDidEnd]) {
        [self handleEndOfGame];
    }
}

-(void)cardSelected:(id)button
{
    CardView *cv = (CardView *)[button superview];
    Card *card = cv.card;
    [cv toggleHighlight];
    if ([self.game.selectedCards containsObject:card]) {
        [self.game.selectedCards removeObject:card];
    } else {
        [self.game.selectedCards addObject:card];
        if ([self.game.selectedCards count] == 3) {
            if ([self.game evaluateSet:self.game.selectedCards]) {
                [self handleSet];
            } else {
                [self handleIncorrectGuess];
                [self refreshBoard];
            }
            currentHints = 0;
        }
    }
}

-(void)enableButton:(UIButton *)button {
    button.enabled = YES;
}

- (IBAction)hintPressed:(UIButton *)button {
    self.game.hints++;
    NSString *prompt = [NSString stringWithFormat:@"Hints taken: %d", self.game.hints];
    [prompterView promptMessage:prompt];
    [self refreshBoard];
    if (currentHints == 0) {
        NSArray *sets = [self.game getSetsInDeal];
        if (sets.count > 0) {
            for (int i = 0; i < sets.count; i++) {
                NSArray *setArray = [sets objectAtIndex:i];
                NSSet *set = [NSSet setWithArray:setArray];
                if (![self.game.foundSets containsObject:set]) {
                    hintSet = setArray;
                    break;
                }
            }
        } else {
            hintSet = nil;
        }
    }
    if (hintSet != nil) {
        button.enabled = NO;
        currentHints++;
        float delay = HINT_DELAY;
        for (int i = 0 ; i < currentHints; i++) {
            Card *card = [hintSet objectAtIndex:i];
            int index = [self.game.cards indexOfObject:card];
            CardView *cv = [self.cardViews objectAtIndex:index];
            [self performSelector:@selector(cardSelected:) withObject:cv.button afterDelay:delay];
            delay += HINT_DELAY;
        }
        [self performSelector:@selector(enableButton:) withObject:button afterDelay:delay];
    } else {
        [self animateMessage:@"No Set" inColor:[UIColor redColor]];
        [self handleNoSets];
    }
}

- (IBAction)noSetPressed:(id)sender {
    [self refreshBoard];
    NSArray *wrapper = [self.game findSets:1];
    if(!wrapper) {
        [self handleCorrectGuess:@"Correct!"];
        [self handleNoSets];
    } else {
        [self handleIncorrectGuess];
    }
}

- (IBAction)returnToGamePressed:(id)sender {
    UIView *littleMenu = [[alertView subviews] objectAtIndex:0];
    [self animatePopUpRemovalForView:littleMenu];
    if(!self.gameEnded) {
        [self togglePause:false];
    }
}

- (IBAction)exitGamePressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)menuPressed:(id)sender {
    if (![alertView isDescendantOfView:self.view]) {
        NSArray *xibObjects = [[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:self options:nil];
        alertView = [xibObjects objectAtIndex:0];
        UIView *littleMenu = [[alertView subviews] objectAtIndex:0];
        [self animatePopUpForView:littleMenu];
        if(!self.gameEnded) {
            [self togglePause:true];
        }
    }
}

-(void)resetGame {
    cardViews = [[NSMutableArray alloc] init];
    [self.game dealCards];
    currentHints = 0;
    HighScores *scores = [self getHighScores];
    popUpMenuView = [[PopUpMenuView alloc] initWithFrame:self.view.frame setGame:self.game highScores:scores];
    popUpMenuView.delegate = self;
    
    [self drawDeck];
    [self updateScoreboard];
    [self performSelector:@selector(arrangeCards) withObject:nil afterDelay:0];
    self.gameEnded = false;
    isPaused = false;
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:(DEAL_DELAY * (NUM_CARDS - 1))];
}

- (IBAction)leaderboardPressed:(id)sender {
    [pausedView removeFromSuperview];
    [self.popUpMenuView setUpLeaderboard:true];
    [self animatePopUpForView:self.popUpMenuView.menuView];
    if(!self.gameEnded) {
        [self togglePause:true];
    }
}

// Pop Up Menu Delegate Methods
-(void)cancelPressedForPopUp:(PopUpMenuView *)view {
    [self animatePopUpRemovalForView:view.menuView];
    if(!self.gameEnded) {
        [self togglePause:false];
    }
}

-(void)menuPressedForPopUp:(PopUpMenuView *)view {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initPuzzleGameWithCallback:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        game = [[PuzzleGame alloc] init];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

-(void)clearCardViews
{
    for(int i = 0; i < self.cardViews.count; i++) {
        [[self.cardViews objectAtIndex:i] removeFromSuperview];
    }
    [self.cardViews removeAllObjects];
}

-(void)playAgainPressedForPopUp:(PopUpMenuView *)view {
    if ([self.game isKindOfClass:[ClassicGame class]]) {
        [self clearCardViews];
        game = [[ClassicGame alloc] init];
        [view removeFromSuperview];
        [self resetGame];
    } else {
        view.spinner.hidden = NO;
        [view.spinner startAnimating];
        view.playAgainButton.hidden = YES;
        [self initPuzzleGameWithCallback:^{
            [self clearCardViews];
            [view removeFromSuperview];
            [view.spinner stopAnimating];
            view.spinner.hidden = YES;
            view.playAgainButton.hidden = NO;
            [self resetGame];
        }];
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self rearrangeCards];
    }
}
// Method stubs
-(void)replaceCards {}
-(bool)gameDidEnd {return false;}
-(void)saveScore {};
-(HighScores *)getHighScores {return nil;};

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    topMenu = nil;
    pauseButton = nil;
    noSetButton = nil;
    hintButton = nil;
    prompterView = nil;
    alertView = nil;
    [super viewDidUnload];
}
@end
