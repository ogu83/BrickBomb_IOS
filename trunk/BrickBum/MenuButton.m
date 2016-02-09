//
//  MenuButton.m
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "MenuButton.h"

@implementation MenuButton

+(id)startButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"Start"];
    b.name = @"startButton";
    return b;
}
+(id)highScoreButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"HighScore"];
    b.name = @"highScoreButton";
    return b;
}
+(id)exitButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"Exit"];
    b.name = @"exitButton";
    return b;
}
+(id)howToPlay
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"HowToPlay"];
    b.name = @"howToPlay";
    return b;
}
+(id)rate
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"Rate"];
    b.name = @"rate";
    return b;
}

+(float)buttonScaleRatio
{
    return 266.0 / 845.0;
}

@end
