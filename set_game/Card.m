//
//  Card.m
//  set-game
//
//  Created by Daniel Capo.
//  Copyright (c) 2012. All rights reserved.
//

#import "Card.h"

@implementation Card

@synthesize number, color, shading, shape;
@synthesize title;

-(id)initWithNumber:(NSString *)aNumber color:(NSString *)aColor shading:(NSString *)aShading shape:(NSString *)aShape
{
    self = [super init];
    if (self) {
        number = aNumber;
        color = aColor;
        shading = aShading; 
        shape = aShape;
        title = [NSString stringWithFormat:@"%@ %@ %@ %@", self.number, self.color, self.shading, self.shape];
    }
    return self;
}

-(NSString *)getFeature:(NSString *)feature
{
    if ([feature isEqualToString:@"number"]) {
        return self.number;
    } else if ([feature isEqualToString:@"color"]) {
        return self.color;
    } else if ([feature isEqualToString:@"shading"]) {
        return self.shading;
    } else if ([feature isEqualToString:@"shape"]) {
        return self.shape;
    } else {
        return nil;
    }
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ %@ %@", self.number, self.color, self.shading, self.shape];
}


@end
