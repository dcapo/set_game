//
//  MenuViewController.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "MenuViewController.h"
#import "PuzzleViewController.h"
#import "PuzzleGame.h"
#import "ClassicViewController.h"
#import "ClassicGame.h"
#import "UIView+Animation.h"
#import "LeaderboardViewController.h"

#define OVERSHOT 40
#define SMALL_CARD_WIDTH 65
#define SMALL_CARD_HEIGHT 56
#define EXPOSURE_Y 54.9408
#define EXPOSURE_X 63.9408
#define SHINE_DURATION 1.0
#define ANIMATION_INTERVAL 7.0

@interface MenuViewController () {
    NSTimer *animationTimer;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) PuzzleGame *puzzleGame;
@property (strong, nonatomic) NSMutableArray *cardViews;
@end

@implementation MenuViewController
@synthesize logo, classicButton, puzzleButton, activityIndicator;
@synthesize puzzleGame, cardViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.activityIndicator.hidden = YES;
    self.puzzleButton.hidden = NO;
    self.puzzleButton.enabled = YES;
    self.classicButton.enabled = YES;
    self.leaderboardButton.enabled = YES;
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

-(void)pumpSlideButtonsOnStartup {
    // Classic button slides in from right
    CGRect f = self.classicButton.frame;
    self.classicButton.frame = CGRectMake(self.view.frame.size.width, f.origin.y, f.size.width, f.size.height);
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
        self.classicButton.frame = CGRectMake(f.origin.x - OVERSHOT, f.origin.y, f.size.width, f.size.height);
    } completion: ^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            self.classicButton.frame = f;
        }];
    }];
    
    // Puzzle button slides in from left
    CGRect r = self.puzzleButton.frame;
    self.puzzleButton.frame = CGRectMake(0 - r.size.width, r.origin.y, r.size.width, r.size.height);
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
        self.puzzleButton.frame = CGRectMake(r.origin.x + OVERSHOT, r.origin.y, r.size.width, r.size.height);
    } completion: ^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            self.puzzleButton.frame = r;
        }];
    }];
    
    // Leaderboard button slides in from right
    CGRect l = self.leaderboardButton.frame;
    self.leaderboardButton.frame = CGRectMake(self.view.frame.size.width, l.origin.y, l.size.width, l.size.height);
    [UIView animateWithDuration:0.5 delay:0.7 options:UIViewAnimationOptionCurveLinear animations:^{
        self.leaderboardButton.frame = CGRectMake(l.origin.x - OVERSHOT, l.origin.y, l.size.width, l.size.height);
    } completion: ^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            self.leaderboardButton.frame = l;
        }];
    }];
}

-(void)pumpSlideButtonsOnExit:(float)time {
    
    CGRect f0 = self.classicButton.frame;
    CGRect f1 = CGRectMake(self.view.frame.size.width, f0.origin.y, f0.size.width, f0.size.height);
    [UIView animateWithDuration:0.375*time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.classicButton.frame = CGRectMake(f0.origin.x - OVERSHOT, f0.origin.y, f0.size.width, f0.size.height);
    } completion: ^(BOOL finished){
        [UIView animateWithDuration:0.625*time animations:^{
            self.classicButton.frame = f1;
        }];
    }];
    
    f0 = self.puzzleButton.frame;
    f1 = CGRectMake(0 - f0.size.width, f0.origin.y, f0.size.width, f0.size.height);
    [UIView animateWithDuration:0.375*time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.puzzleButton.frame = CGRectMake(f0.origin.x + OVERSHOT, f0.origin.y, f0.size.width, f0.size.height);
    } completion: ^(BOOL finished){
        [UIView animateWithDuration:0.625*time animations:^{
            self.puzzleButton.frame = f1;
        }];
    }];
}

-(void)scaleRotateTranslate:(id)argument {
    NSArray *args = (NSArray *)argument;
    CardView *cv = [args objectAtIndex:0];
    CGPoint scale = [[args objectAtIndex:1] CGPointValue];
    CGPoint translation = [[args objectAtIndex:2] CGPointValue];
    float rotation = [[args objectAtIndex:3] floatValue];
    float duration = [[args objectAtIndex:4] floatValue];
    [cv scale:scale rotate:rotation AndTranslate:translation duration:duration delay:0 option:UIViewAnimationOptionCurveLinear];
}

-(void)animateCardWheel {
    float delay;
    float x = EXPOSURE_X;
    float y = EXPOSURE_Y;
    
    float rotation = M_PI/2;
    for (int i = 0; i < 12; i++) {
        Card *card = [SetGame getRandomCard];
        float x0 = self.logo.frame.origin.x + (self.logo.frame.size.width - SMALL_CARD_WIDTH) / 2;
        float y0 = self.logo.frame.origin.y + (self.logo.frame.size.height - SMALL_CARD_HEIGHT) / 2;
        CardView *cv = [[CardView alloc] initWithFrame:CGRectMake(x0, y0, SMALL_CARD_WIDTH, SMALL_CARD_HEIGHT)
                                              FromCard:card];
        cv.button.adjustsImageWhenDisabled = NO;
        cv.button.enabled = NO;
        [cardViews addObject:cv];
        cv.transform = CGAffineTransformRotate(CGAffineTransformIdentity, rotation);
        [self.view insertSubview:cv belowSubview:self.logo];
        
        float delta;
        switch (i%6) {
            case 0:
                delta = -(y*sqrt(3));
                break;
            case 1:
                delta = -(2*y);
                break;
            case 2:
                delta = -(2*x);
                break;
            case 3:
                delta = -(x*sqrt(3));
                break;
            case 4:
                delta = -(2*x);
                break;
            case 5:
                delta = -(2*y);
                break;
            default: break;
        }
        float duration = 0.6;
        [UIView animateWithDuration:duration delay:delay options:0 animations:^{
            cv.transform = CGAffineTransformTranslate(cv.transform, delta - 8.0, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                cv.transform = CGAffineTransformTranslate(cv.transform, 8.0, 0);
            }];
        }];
        delay += 0.1;
        rotation += M_PI/6;
    }
}

-(void)bumpCard:(CardView *)cv delay:(float)delay {
    
    [UIView animateWithDuration:0.4 delay:delay options:0 animations:^{
        cv.transform = CGAffineTransformTranslate(cv.transform, -10.0, 0.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
            cv.transform = CGAffineTransformTranslate(cv.transform, 10.0, 0.0);
        } completion:^(BOOL finished) {
        }];
    }];
}

-(void)animateCardBumps {
    float delay = 0;
    for (int i = 0; i < self.cardViews.count; i++) {
        CardView *cv = [self.cardViews objectAtIndex:i];
        [self bumpCard:cv delay:delay];
        delay += 0.1;
    }
}

-(void)loopAnimations {
    [self performSelector:@selector(animateButtonShines) withObject:nil afterDelay:0];
    [self performSelector:@selector(animateCardBumps) withObject:nil afterDelay:ANIMATION_INTERVAL/2.0];
}

-(void)beginAnimationTimer {
    if (animationTimer == nil) {
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_INTERVAL target:self selector:@selector(loopAnimations) userInfo:nil repeats:YES];
    }
}

-(void)stopAnimationTimer {
    [animationTimer invalidate];
    animationTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Logo pops
    [self.logo setAnchorPoint:CGPointMake(0.5, 0.5)];
    self.logo.transform = CGAffineTransformScale(self.logo.transform, TINY_VALUE, TINY_VALUE);
    float scaleT1 = 1.2;
    [self.logo popToMaxSize:CGPointMake(scaleT1/TINY_VALUE, scaleT1/TINY_VALUE)
                             endSize:CGPointMake(1/scaleT1, 1/scaleT1)
                      withExpandTime:0.5
                         compactTime:0.75
                          completion:nil];
    cardViews = [[NSMutableArray alloc] init];
    [self performSelector:@selector(animateCardWheel) withObject:nil afterDelay:0.75];
    [self pumpSlideButtonsOnStartup];
    
    [self performSelector:@selector(animateButtonShines) withObject:nil afterDelay:3.5];
    [self beginAnimationTimer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [util addObserverForNotifications:self inSelector:@selector(appEnteredForeground) outSelector:@selector(appEnteredBackground)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)appEnteredForeground {
    [self beginAnimationTimer];
}

-(void)appEnteredBackground {
    [self stopAnimationTimer];
    for (UIView *view in [self.view subviews]) {
        [view.layer removeAllAnimations];
    }
}

- (void)viewDidUnload
{
    logo = nil;
    classicButton = nil;
    puzzleButton = nil;
    [self setLeaderboardButton:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)pushViewController:(id)argument {
    UIViewController *vc = (UIViewController *)argument;
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)classicPressed:(id)sender {
    ClassicGame *game = [[ClassicGame alloc] init];
    ClassicViewController *cvc = [[ClassicViewController alloc] initWithNibName:@"GameViewController" bundle:nil game:game];
    [self.navigationController pushViewController:cvc animated:YES];
}

-(void)popButton:(UIButton *)button delay:(float)delay
{
    [UIView animateWithDuration:0.5 delay:delay options:0 animations:^{
        button.transform = CGAffineTransformScale(button.transform, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            button.transform = CGAffineTransformIdentity;
        }];
    }];
}

-(void)animateButtonShines {
    NSArray *buttons = [NSArray arrayWithObjects:self.classicButton, self.puzzleButton, self.leaderboardButton, nil];
    float delay = 0;
    for (int i = 0; i < buttons.count; i++) {
        UIImageView *shineView = [[UIImageView alloc] initWithImage:[UIImage animatedImageNamed:@"glow" duration:SHINE_DURATION]];
        UIButton *button = buttons[i];
        shineView.frame = button.frame;
        [self.view performSelector:@selector(addSubview:) withObject:shineView afterDelay:delay];
        [shineView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:SHINE_DURATION + delay];
        delay += 0.25;
    }
}

- (IBAction)puzzlePressed:(id)sender {
    for (UIView *subview in self.view.subviews)
    {
        if (subview.frame.origin.x == self.puzzleButton.frame.origin.x &&
            subview.frame.origin.y == self.puzzleButton.frame.origin.y &&
            subview.frame.size.width == self.puzzleButton.frame.size.width &&
            subview.frame.size.height == self.puzzleButton.frame.size.height &&
            subview != self.puzzleButton) {
            [subview removeFromSuperview];
        }
    }
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.puzzleButton.enabled = NO;
    self.classicButton.enabled = NO;
    self.leaderboardButton.enabled = NO;
    self.puzzleButton.hidden = YES;
    [self initPuzzleGameWithCallback:^{
        PuzzleViewController *pvc = [[PuzzleViewController alloc] initWithNibName:@"GameViewController" bundle:nil game:self.puzzleGame];
        [self.navigationController pushViewController:pvc animated:YES];
        [self.activityIndicator stopAnimating];
    }];
}

- (void)initPuzzleGameWithCallback:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        puzzleGame = [[PuzzleGame alloc] init];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (IBAction)leaderboardPressed:(id)sender {
    LeaderboardViewController *lvc = [[LeaderboardViewController alloc] init];
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
