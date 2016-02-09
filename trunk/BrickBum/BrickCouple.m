//
//  BrickCouple.m
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "BrickCouple.h"

@implementation BrickCouple

+(id)RandomBrickCouple
{
    Brick *b0;
    Brick *b1;
    while (true)
    {
        b0 = [Brick getRandomBrick];
        b1 = [Brick getRandomBrick];
        if (b1.BrickType != b0.BrickType) break;
    }
    
    BrickCouple *b = [BrickCouple spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(0, 0)];
    b0.Couple = b1;
    b1.Couple = b0;
    b.Brick1 = b0;
    b.Brick2 = b1;
    b.Brick1.ParentCouple = b;
    b.Brick2.ParentCouple = b;
    return b;
}

@end
