//
//  BrickCouple.h
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Brick.h"

@interface BrickCouple : SKSpriteNode

@property Brick* Brick1;
@property Brick* Brick2;
@property int rotationPos;

+(id)RandomBrickCouple;

@end
