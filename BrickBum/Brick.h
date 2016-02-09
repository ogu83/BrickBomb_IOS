//
//  Brick.h
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Position.h"

@interface Brick : SKSpriteNode

typedef NS_ENUM(NSUInteger, BrickType)
{
    Red,
    Blue,
    Green,
    Yellow,
    Orange,
    f,
    t,
    Purple,
};

@property(nonatomic) BrickType BrickType;
@property(nonatomic) int PositionX;
@property(nonatomic) int PositionY;
@property(nonatomic) Brick* Couple;
@property(nonatomic) bool IsMoved;
@property(nonatomic) bool IsReadyToExplode;
@property(nonatomic) SKSpriteNode* ParentCouple;

+(id)redBrick;
+(id)blueBrick;
+(id)greenBrick;
+(id)yellowBrick;
+(id)orangeBrick;
+(id)fBrick;
+(id)tBrick;

+(id)brickWithType: (BrickType) BrickType;

+(id)getRandomBrick;

-(Position*) Pos;
-(void) setPos:(Position*) pos;

@end
