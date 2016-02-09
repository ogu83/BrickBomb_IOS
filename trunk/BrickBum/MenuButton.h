//
//  MenuButton.h
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MenuButton : SKSpriteNode

+(id)startButton;
+(id)highScoreButton;
+(id)exitButton;
+(id)howToPlay;
+(id)rate;

+(float)buttonScaleRatio;

@end
