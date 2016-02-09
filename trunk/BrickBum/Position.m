//
//  Position.m
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "Position.h"

@implementation Position

+(id) PositionWithX:(int)x :(int)y
{
    Position* p = [[Position alloc] init];
    p.X = x;
    p.Y = y;
    return p;
}

-(Position*) Left { return [Position PositionWithX:self.X-1 :self.Y]; }
-(Position*) Right { return [Position PositionWithX:self.X+1 :self.Y]; }
-(Position*) Bottom { return [Position PositionWithX:self.X :self.Y+1]; }
-(Position*) Top { return [Position PositionWithX:self.X :self.Y-1]; }

-(bool) isEqualPos:(Position*) p
{
    return p.X == self.X && p.Y == self.Y;
}

@end
