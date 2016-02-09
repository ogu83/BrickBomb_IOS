//
//  Brick.m
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "Brick.h"

@implementation Brick

+(id)redBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"redBrick"];
    brick.BrickType = (BrickType)Red;
    return  brick;
}
+(id)blueBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"blueBrick"];
    brick.BrickType = (BrickType)Blue;
    return brick;
}
+(id)greenBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:51.0/255.0 green:204.0/255.0 blue:51.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"greenBrick"];
    brick.BrickType = (BrickType)Green;
    return brick;
}
+(id)yellowBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"yellowBrick"];
    brick.BrickType = (BrickType)Yellow;
    return brick;
}
+(id)orangeBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:51.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"orangeBrick"];
    brick.BrickType = (BrickType)Orange;
    return brick;
}
+(id)fBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:255.0/255.0 green:26.0/255.0 blue:254.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"fBrick"];
    brick.BrickType = (BrickType)f;
    return brick;
}
+(id)tBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"tBrick"];
    brick.BrickType = (BrickType)t;
    return brick;
}
+(id)purpleBrick
{
    //Brick *brick = [Brick spriteNodeWithColor:[UIColor colorWithRed:102.0/255.0 green:0.0/255.0 blue:204.0/255.0 alpha:1] size:CGSizeMake(100, 100)];
    Brick *brick = [Brick spriteNodeWithImageNamed:@"purpleBrick"];
    brick.BrickType = (BrickType)Purple;
    return brick;
}


+(id)brickWithType:(BrickType) BrickType {
    switch (BrickType) {
        case Red:
            return [Brick redBrick];
        case Blue:
            return [Brick blueBrick];
        case Green:
            return [Brick greenBrick];
        case Yellow:
            return [Brick yellowBrick];
        case Orange:
            return [Brick orangeBrick];
        case f:
            return [Brick fBrick];
        case t:
            return [Brick tBrick];
        case Purple:
            return [Brick purpleBrick];
        default:
            return nil;
    }
}

+(id)getRandomBrick {
    int number = arc4random_uniform(8);
    return [Brick brickWithType:number];
}

-(Position*) Pos
{
    return [Position PositionWithX:self.PositionX :self.PositionY];
}

-(void) setPos:(Position*) pos
{
    self.PositionX = pos.X;
    self.PositionY = pos.Y;
}

@end
