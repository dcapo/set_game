//
//  ClassicViewController.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "ClassicGame.h"

@interface ClassicViewController : GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil game:(ClassicGame *)aGame;
@end
