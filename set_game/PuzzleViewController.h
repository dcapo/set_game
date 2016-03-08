//
//  PuzzleViewController.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "GameViewController.h"
#import "PuzzleGame.h"

@interface PuzzleViewController : GameViewController

@property (nonatomic, strong) UIButton *foundSetsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil game:(PuzzleGame *)aGame;

@end
