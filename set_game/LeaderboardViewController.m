//
//  LeaderboardViewController.m
//  set_game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "util.h"
#import "HighScores.h"
#import "LeaderboardDetailCell.h"

#define TABLE_WIDTH 307
#define TABLE_HEIGHT 286
#define TABLE_Y 100
#define TABLE_HEADER_Y 77
#define TABLE_HEADER_MARGIN 15
#define SCORE_LABEL_X 10
#define TIME_LABEL_X 70
#define SUBSCORE_LABEL_X 110
#define INCORRECT_LABEL_X 180
#define HINT_LABEL_X 230
#define DATE_LABEL_X 270
#define TITLE_Y 3

@interface LeaderboardViewController ()
@property (strong, nonatomic) NSMutableArray *classicHighScores;
@property (strong, nonatomic) NSMutableArray *puzzleHighScores;
@property (weak, nonatomic) IBOutlet LeaderboardDetailCell *leaderboardDetailCell;
@end

@implementation LeaderboardViewController
@synthesize scrollView, pageControl, leaderboardDetailCell;
@synthesize classicTableView, puzzleTableView;
@synthesize classicHighScores, puzzleHighScores;

-(CGRect)getTableFrameForPage:(int)page
{
    float tableX = page*self.view.frame.size.width + (self.view.frame.size.width - TABLE_WIDTH) / 2;
    CGRect tableViewFrame = CGRectMake(tableX, TABLE_Y, TABLE_WIDTH, TABLE_HEIGHT);
    return tableViewFrame;
}

-(UITableView *)classicTableView
{
    if (!classicTableView) {
        classicTableView = [[UITableView alloc] initWithFrame:[self getTableFrameForPage:0] style:UITableViewStylePlain];
        [util configureLeaderboardTableView:classicTableView delegate:self];
    }
    return classicTableView;
}

-(UITableView *)puzzleTableView
{
    if (!puzzleTableView) {
        puzzleTableView = [[UITableView alloc] initWithFrame:[self getTableFrameForPage:1] style:UITableViewStylePlain];
        [util configureLeaderboardTableView:puzzleTableView delegate:self];
    }
    return puzzleTableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        classicHighScores = [[[HighScores alloc] initWithScores:CLASSIC_HIGH_SCORES] highScoresArray];
        puzzleHighScores = [[[HighScores alloc] initWithScores:PUZZLE_HIGH_SCORES] highScoresArray];
        scrollView.delegate = self;
    }
    return self;
}

-(UILabel *)emptyTableLabelOnPage:(int)page
{
    NSString *text = @"(No high scores yet)";
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:NOTHING_THERE_FONT_SIZE]];
    CGPoint origin = CGPointMake(page*self.view.frame.size.width + self.scrollView.frame.size.width/2 - size.width/2, TABLE_Y + NOTHING_THERE_MARGIN);
    UILabel *emptyTableLabel = [util labelWithOrigin:origin text:text fontSize:NOTHING_THERE_FONT_SIZE];
    return emptyTableLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    float frameWidth = self.view.frame.size.width;
    UIImageView *classicTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"classic_high_scores.png"]];
    float x = (self.view.frame.size.width - classicTitleView.frame.size.width) / 2;
    classicTitleView.frame = CGRectMake(x,
                                        TITLE_Y,
                                        classicTitleView.frame.size.width,
                                        classicTitleView.frame.size.height);
    [self.scrollView addSubview:classicTitleView];
    
    UIImageView *puzzleTitleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"puzzle_high_scores.png"]];
    x = self.view.frame.size.width + (self.view.frame.size.width - puzzleTitleView.frame.size.width) / 2;
    puzzleTitleView.frame = CGRectMake(x,
                                       TITLE_Y,
                                       puzzleTitleView.frame.size.width,
                                       puzzleTitleView.frame.size.height);
    [self.scrollView addSubview:puzzleTitleView];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    
    NSArray *headers = [NSArray arrayWithObjects:@"Score", @"Time", @"Subscore", @"Wrong",
                        @"Hints", @"Date", nil];
    for (int i = 0; i < 2; i++) {
        float headerX = SCORE_LABEL_X;
        for (int j = 0; j < headers.count; j++) {
            CGPoint labelOrigin = CGPointMake(i*frameWidth + headerX, TABLE_HEADER_Y);
            UILabel *label = [util labelWithOrigin:labelOrigin text:[headers objectAtIndex:j] fontSize:TABLE_HEADER_FONT_SIZE];
            [self.scrollView addSubview:label];
            headerX += (label.frame.size.width + TABLE_HEADER_MARGIN);
        }
    }
    
    if (self.classicHighScores.count > 0) {
        [self.classicTableView reloadData];
        [self.scrollView addSubview:self.classicTableView];
    } else {
        UILabel *emptyTableLabel = [self emptyTableLabelOnPage:0];
        [self.scrollView addSubview:emptyTableLabel];
    }
    
    if (self.puzzleHighScores.count > 0) {
        [self.puzzleTableView reloadData];
        [self.scrollView addSubview:self.puzzleTableView];
    } else {
        UILabel *emptyTableLabel = [self emptyTableLabelOnPage:1];
        [self.scrollView addSubview:emptyTableLabel];
    }
}

#pragma mark - TableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.classicTableView) {
        return self.classicHighScores.count;
    } else {
        return self.puzzleHighScores.count;
    }
}

-(LeaderboardDetailCell *)configureCellForTable:(UITableView *)tableView FromScores:(NSMutableArray *)scores atIndexPath:(NSIndexPath *)indexPath
{
    LeaderboardDetailCell *cell = (LeaderboardDetailCell *)[tableView dequeueReusableCellWithIdentifier:[LeaderboardDetailCell reuseIdentifier]];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LeaderboardDetailCell" owner:self options:nil];
        cell = leaderboardDetailCell;
        leaderboardDetailCell = nil;
    }
    NSArray *scoreEntry = [scores objectAtIndex:indexPath.row];
    if(scoreEntry) {
        cell.score.text = [NSString stringWithFormat:@"%d", [[scoreEntry objectAtIndex:0] intValue]];
        int time = [[scoreEntry objectAtIndex:1] intValue];
        cell.time.text = [util intToHms:time];
        cell.subscore.text = [NSString stringWithFormat:@"%d", [[scoreEntry objectAtIndex:2] intValue]];
        cell.incorrect.text = [NSString stringWithFormat:@"%d", [[scoreEntry objectAtIndex:3] intValue]];
        cell.hints.text = [NSString stringWithFormat:@"%d", [[scoreEntry objectAtIndex:4] intValue]];
        NSDate *date = [scoreEntry objectAtIndex:5];
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM-dd"];
        cell.date.text = [dateFormatter stringFromDate:date];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeaderboardDetailCell *cell;
    if (tableView == self.classicTableView) {
        cell = [self configureCellForTable:tableView FromScores:self.classicHighScores atIndexPath:indexPath];
    } else {
        cell = [self configureCellForTable:tableView FromScores:self.puzzleHighScores atIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - ScrollView methods
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage:(id)sender {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setLeaderboardDetailCell:nil];
    [super viewDidUnload];
}
@end
