//
//  LeaderboardViewController.h
//  set_game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UITableView *classicTableView;
@property (strong, nonatomic) UITableView *puzzleTableView;

@end
