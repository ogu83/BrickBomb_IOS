//
//  Position.h
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject
@property int X;
@property int Y;
+(id) PositionWithX:(int)x :(int)y;

-(Position*) Left;
-(Position*) Right;
-(Position*) Bottom;
-(Position*) Top;

-(bool) isEqualPos:(Position*) p;

@end
