//
//  GameScene.h
//  BrickBum
//

//  Copyright (c) 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MenuButton.h"
#import "GameViewController.h"

@interface GameScene : SKScene

@property MenuButton *btnStart;
@property MenuButton *btnHighScore;
@property MenuButton *btnExit;
@property MenuButton *btnHowToPlay;
@property MenuButton *btnRate;

@property NSMutableArray *bricks;
@property NSMutableArray *gridLines;

@property GameViewController* viewController;

@property SKSpriteNode *soundButton;
@property SKSpriteNode *playPauseButton;
@property SKSpriteNode *gotoMenuButton;

@property SKSpriteNode *howToPlayScreen;
@property SKSpriteNode *howToPlayCloseButton;

@end
