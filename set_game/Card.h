//
//  Card.h
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *shading;
@property (nonatomic, strong) NSString *shape;
@property (nonatomic, strong) NSString *title;

-(id)initWithNumber:(NSString *)aNumber color:(NSString *)aColor shading:(NSString *)aShading shape:(NSString *)aShape;
-(NSString *)getFeature:(NSString *)feature;
@end
