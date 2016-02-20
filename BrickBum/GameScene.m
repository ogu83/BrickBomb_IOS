//
//  GameScene.m
//  BrickBum
//
//  Created by Oğuz Köroğlu on 03/02/16.
//  Copyright (c) 2016 Oguz Koroglu. All rights reserved.
//

#import "GameScene.h"
#import "Brick.h"
#import "BrickCouple.h"
#import "MenuButton.h"
#import "Position.h"
#import "Constants.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import <Social/Social.h>
//#import <FacebookSDK/FacebookSDK.h>

@implementation GameScene

int posXCount = 9;
int posYCount = 16;
int xMargin = 10;
int yMargin = 40;
int newCoupleScreenDivider = 2;
float levelIntervalInSeconds = 0.5;

bool gamePaused;
bool gameOver;
bool onMenu;
bool onMoveBricksDown;
CFTimeInterval updatedTime;
BrickCouple *brickCouple;
BrickCouple *selectedCouple;
Brick *selectedBrick;
int firstTouchX;
bool brickMoved;
int score;
SKLabelNode *scoreLabel;
SKSpriteNode *levelUpSign;

SKAudioNode* music1;
SKAudioNode* music2;
AVAudioPlayer* player;
bool isSoundOn;

int level = 1;
int nextLevelScore = 100;
int levelPow = 10;
NSString* UserName;

#pragma mark - Functions
-(UIImage *)screenShot
{
    CGSize size = self.size;
    //CGSize size = CGSizeMake(your_width, your_height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rec = CGRectMake(0, 0, size.width, size.height);
    [_viewController.view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(int)CGPosXFromPosX:(int)x
{
    float frameW = CGRectGetWidth(self.frame);
    float w = (frameW - xMargin * 2) / (posXCount + 1);
    float bx = w * (x + 1) + xMargin - w / 2;
    return bx;
}
-(int)CGPosYFromPosY:(int)y
{
    float frameH = CGRectGetHeight(self.frame);
    float h = (frameH - yMargin * 2) / (posYCount + 1);
    float by = frameH - h * (y + 1) - yMargin + h / 2;
    return by;
}

- (UIImage *)cropBackgroundImage:(UIImage *)image
{
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    if (image.size.width>frameW || image.size.height>frameH)
        return image;
    
    // Center the crop area
    CGRect clippedRect = CGRectMake((image.size.width - frameW) / 2, (image.size.height - frameH) / 2, frameW, frameH);
    
    // Crop logic
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

#pragma mark - Actions
- (void)postTo:(NSString*)name
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if ([name isEqual:@"Facebook"])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    else if ([name isEqual:@"TencentWeibo"])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTencentWeibo];
    else if ([name isEqual:@"SinaWeibo"])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    
    [controller setInitialText: [NSString stringWithFormat:@"Hey, I completed #%@ with score %d", GameName, score]];
    [controller addURL:[NSURL URLWithString:WebSite]];
    UIImage* img = [self screenShot];
    [controller addImage:img];
    [[self viewController] presentViewController:controller animated:YES completion:^{ }];
}
- (void)postToTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText: [NSString stringWithFormat:@"Hey, I completed #%@ with score %d", GameName, score]];
        [controller addURL:[NSURL URLWithString:WebSite]];
        UIImage* img = [self screenShot];
        [controller addImage:img];
        [[self viewController] presentViewController:controller animated:YES completion:^{ }];
    }
}
- (void)postToFacebook
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText: [NSString stringWithFormat:@"Hey, I completed #%@ with score %d", GameName, score]];
        [controller addURL:[NSURL URLWithString:WebSite]];
        UIImage* img = [self screenShot];
        [controller addImage:img];
        [[self viewController] presentViewController:controller animated:YES completion:^{ }];
    }
    else
    {
        // Check if the Facebook app is installed and we can present the share dialog
        /*
         FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
         params.link = [NSURL URLWithString:ShareUrl];
         params.caption = @"Artwalk";
         params.linkDescription = [_Exhibition.Name ValueAtLangId:_localSettings.LangId];
         NSString *mediaUrlStr = [NSString stringWithFormat:@"%@/%@", GetExhibitionImageUrl, _Exhibition.FirstMediaId];
         NSURL *mediaUrl = [NSURL URLWithString:mediaUrlStr];
         params.picture = mediaUrl;
         // If the Facebook app is installed and we can present the share dialog
         if ([FBDialogs canPresentShareDialogWithParams:params])
         {
         // Present share dialog
         [FBDialogs presentShareDialogWithLink:params.link handler:^(FBAppCall *call, NSDictionary *results, NSError *error)
         {
         if(error)
         {
         // An error occurred, we need to handle the error
         // See: https://developers.facebook.com/docs/ios/errors
         NSLog(@"error share facebook: %@", error.description);
         }
         else
         NSLog(@"facebook share result %@", results);
         }];
         }
         else
         {
         // Present the feed dialog
         }
         */
    }
}

-(IBAction)doExit
{
    //show confirmation message to user
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Exit"
                                                    message:@"Are you leaving?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 99;
    [alert show];
}

-(void)startGameWithBricks
{
    //[music2 removeFromParent];
    isSoundOn = YES;
    gamePaused = NO;
    [self createSoundButton:isSoundOn];
    [self createPlayPauseButton:gamePaused];
    [self createGotoMenuButton];
    
    [self createBackgroundMusic1];
    [self createGridLines];
    [self drawScore];
    [self removeMenu];
    
    gameOver = NO;
}
- (void)startGame
{
    if (_bricks !=nil)
        [self removeChildrenInArray:_bricks];
    
    _bricks = [[NSMutableArray alloc] init];
    //[self createBrickCouple];
    [self startGameWithBricks];
}

- (void)gotoMenu
{
    score = 0;
    scoreLabel = nil;
    [self removeAllActions];
    [self removeAllChildren];
    //[self destroyGridLines];
    [self createBackground];
    [self createGridLines];
    [self createMenu];
}

-(void)SendHighScoreToServerAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                        message:[NSString stringWithFormat:@"Great Score: %d. Enter your name to the high score table",score]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 124;
    [alertView show];
}
- (void)postToAlert
{
    UIAlertView * alert =[[UIAlertView alloc ]
                          initWithTitle:@"Congratulations"
                          message:[NSString stringWithFormat:@"You completed %@ with the score: %d. Do you want share the screenshot and score to your friends?", GameName, score]
                          delegate:self
                          cancelButtonTitle: @"Nope"
                          otherButtonTitles: nil];
    alert.tag = 123;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        [alert addButtonWithTitle:@"Twitter"];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        [alert addButtonWithTitle:@"Facebook"];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo])
        [alert addButtonWithTitle:@"TencentWeibo"];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
        [alert addButtonWithTitle:@"SinaWeibo"];
    
    [alert show];
}

-(void)SendHighScoreToServer
{
    //TODO: Send It To Server
    UserName = [UserName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    UIDevice *device = [UIDevice currentDevice];
    NSString  *deviceId = [[device identifierForVendor]UUIDString];
    
    NSString *post = @"";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString* url = [NSString stringWithFormat:@"%@/HighScore?appId=%@&deviceId=%@&name=%@&score=%d",ApiAddress,AppId,deviceId,UserName,score];
    
    //NSString* eUrl = url;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    NSLog([NSString stringWithFormat:@"Request URL: %@", url]);
    //NSLog([NSString stringWithFormat:@"Request EURL: %@", eUrl]);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString* responseString =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog([NSString stringWithFormat:@"Response: %@",responseString]);
    
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] &&
       ![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] &&
       ![SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo] &&
       ![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]
       )
    {
        [self gotoMenu];
    }
    else
    {
        [self postToAlert];
    }
}

#pragma mark - Create
-(void)createGridLines
{
    if (_gridLines != nil)
        [self removeChildrenInArray:_gridLines];
    
    _gridLines = [[NSMutableArray alloc] init];
    
    SKShapeNode *line = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    for (int x=0; x<posXCount+1; x++)
    {
        CGPathMoveToPoint(pathToDraw, NULL, [self CGPosXFromPosX:x], [self CGPosYFromPosY:0]);
        CGPathAddLineToPoint(pathToDraw, NULL, [self CGPosXFromPosX:x], [self CGPosYFromPosY:posYCount]);
    }
    for (int y=0; y<posYCount+1; y++)
    {
        CGPathMoveToPoint(pathToDraw, NULL, [self CGPosXFromPosX:0], [self CGPosYFromPosY:y]);
        CGPathAddLineToPoint(pathToDraw, NULL, [self CGPosXFromPosX:posXCount], [self CGPosYFromPosY:y]);
    }
    line.path = pathToDraw;
    [line setStrokeColor:[UIColor grayColor]];
    [_gridLines addObject:line];
    [self addChild:line];
}
-(void)destroyGridLines
{
    for (SKShapeNode* l in _gridLines)
        [l removeFromParent];
}

- (void)createBackground
{
    [self setBackgroundColor:[SKColor colorWithRed:0.9 green:0.9 blue:1 alpha:1]];
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    UIImage* image = [UIImage imageNamed:@"InvertedLightClouds"];
    //UIImage* cropped = [self cropBackgroundImage:image];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    sprite.size = self.frame.size;
    sprite.position = CGPointMake(frameW / 2, frameH / 2);
    sprite.zPosition = -1;
    [self addChild:sprite];
}

-(void)createBackgroundMusic1
{
    //music1 = [[SKAudioNode alloc] initWithFileNamed:@"Music1.wav"];
    //[self addChild:music2];
    NSString *dataPath=[[NSBundle mainBundle] pathForResource:@"Music1" ofType:@"wav"];
    NSData* musicData = [NSData dataWithContentsOfFile:dataPath];
    player = [[AVAudioPlayer alloc] initWithData:musicData error:nil];
    player.numberOfLoops=-1;
    [player play];
}
-(void)createBackgroundMusic2
{
    //music2 = [[SKAudioNode alloc] initWithFileNamed:@"Music2.wav"];
    //[self addChild:music2];
    NSString *dataPath=[[NSBundle mainBundle] pathForResource:@"Music2" ofType:@"wav"];
    NSData* musicData = [NSData dataWithContentsOfFile:dataPath];
    player = [[AVAudioPlayer alloc] initWithData:musicData error:nil];
    player.numberOfLoops=-1;
    [player play];
}

- (void)createMenu
{
    float frameW = CGRectGetWidth(self.frame);
    //float frameH = CGRectGetHeight(self.frame);
    float menuBtnW = frameW / 2;
    float menuBtnH = menuBtnW * [MenuButton buttonScaleRatio];
    
    
    _btnStart = [MenuButton startButton];
    _btnStart.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + menuBtnH * 1.1 * 2);
    [_btnStart setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_btnStart setZPosition:9];
    [self addChild:_btnStart];
    
    
    _btnHowToPlay = [MenuButton howToPlay];
    _btnHowToPlay.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + menuBtnH * 1.1);
    [_btnHowToPlay setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_btnHowToPlay setZPosition:9];
    [self addChild:_btnHowToPlay];
    
    
    _btnHighScore = [MenuButton highScoreButton];
    _btnHighScore.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + menuBtnH * 0);
    [_btnHighScore setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_btnHighScore setZPosition:9];
    [self addChild:_btnHighScore];
    
    
    _btnRate = [MenuButton rate];
    _btnRate.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + menuBtnH * -1.1);
    [_btnRate setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_btnRate setZPosition:9];
    [self addChild:_btnRate];
    
    
    _btnExit = [MenuButton exitButton];
    _btnExit.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame) + menuBtnH * -1.1 * 2);
    [_btnExit setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_btnExit setZPosition:9];
    [self addChild:_btnExit];
    
    //float duration = 0.3;
    //[_btnStart runAction:[SKAction fadeInWithDuration:duration]];
    //[_btnHighScore runAction:[SKAction fadeInWithDuration:duration]];
    //[_btnExit runAction:[SKAction fadeInWithDuration:duration]];
    
    onMenu = YES;
}
- (void)removeMenu
{
    [_btnStart removeFromParent];
    [_btnHowToPlay removeFromParent];
    [_btnHighScore removeFromParent];
    [_btnRate removeFromParent];
    [_btnExit removeFromParent];
    onMenu = NO;
}

- (void)createSoundButton:(bool)isOn
{
    //float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float ratio = 403 / 300;
    float h = frameH / 16;
    float w = h * ratio;
    
    NSString* imageName = isOn ? @"SoundOn" : @"SoundOff";
    
    _soundButton = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _soundButton.name = @"soundButton";
    [_soundButton setSize:CGSizeMake(w, h)];
    _soundButton.position = CGPointMake(xMargin + w, yMargin - h/2);
    [_soundButton setZPosition:1];
    [self addChild:_soundButton];
}

-(void)createPlayPauseButton:(bool)isPaused
{
    //float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float ratio = 1;
    float h = frameH / 16;
    float w = h * ratio;
    
    NSString* imageName = isPaused ? @"Play" : @"Pause";
    
    _playPauseButton = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _playPauseButton.name = @"playPauseButton";
    [_playPauseButton setSize:CGSizeMake(w, h)];
    _playPauseButton.position = CGPointMake(_soundButton.size.width + 2*xMargin + w, yMargin - h/2);
    [_playPauseButton setZPosition:1];
    [self addChild:_playPauseButton];
}

-(void)createGotoMenuButton
{
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float ratio = 1;
    float h = frameH / 16;
    float w = h * ratio;
    
    NSString* imageName = @"GotoMenu";
    
    _gotoMenuButton = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _gotoMenuButton.name = @"gotoMenuButton";
    [_gotoMenuButton setSize:CGSizeMake(w, h)];
    _gotoMenuButton.position = CGPointMake(frameW - xMargin - w, yMargin - h/2);
    [_gotoMenuButton setZPosition:1];
    [self addChild:_gotoMenuButton];
}

#pragma mark - Birck Calculations
- (void)setBrickPosition:(Brick *)b
{
    if (b==nil)
        return;
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float bx = (b.size.width)*(b.PositionX+1) + xMargin;
    float by = frameH - (b.size.height) * (b.PositionY +1 ) - yMargin;
    b.position = CGPointMake(bx,by);
    
    if (![self.children containsObject:b])
    {
        [b setSize:CGSizeMake((frameW-xMargin*2)/(posXCount+1), (frameH-yMargin*2)/(posYCount+1))];
        [self addChild:b];
    }
}

- (void)createBrickCouple
{
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    brickCouple = [BrickCouple RandomBrickCouple];
    
    [brickCouple.Brick1 setSize:CGSizeMake((frameW-xMargin*2)/(posXCount+1), (frameH-yMargin*2)/(posYCount+1))];
    brickCouple.Brick1.PositionX = arc4random_uniform(posXCount-1);
    brickCouple.Brick1.PositionY = 0;
    
    [brickCouple.Brick2 setSize:CGSizeMake((frameW-xMargin*2)/(posXCount+1), (frameH-yMargin*2)/(posYCount+1))];
    brickCouple.Brick2.PositionY = arc4random_uniform(2);
    brickCouple.Brick2.PositionX = brickCouple.Brick2.PositionY == 0 ? brickCouple.Brick1.PositionX+1: brickCouple.Brick1.PositionX;
    
    brickCouple.rotationPos = brickCouple.Brick2.PositionY == 0 ? 1 : 0;
    
    [self addChild:brickCouple.Brick2];
    [self addChild:brickCouple.Brick1];
    
    [_bricks addObject:brickCouple.Brick1];
    [_bricks addObject:brickCouple.Brick2];
    
    [self setBrickPosition:brickCouple.Brick1];
    [self setBrickPosition:brickCouple.Brick2];
}

-(bool)canMoveDown:(Brick*)brick
{
    bool retVal = brick.PositionY + 1 < posYCount;
    if (retVal)
        for (Brick *b in _bricks)
            if (b != brick)
                if (b.PositionY == brick.PositionY + 1 && b.PositionX == brick.PositionX)
                {
                    retVal = NO;
                    break;
                }
    return retVal;
}
-(bool)canMoveUp:(Brick*)brick
{
    bool retVal = brick.PositionY - 1 > 0;
    if (retVal)
        for (Brick *b in _bricks)
            if (b != brick)
                if (b.PositionY == brick.PositionY - 1 && b.PositionX == brick.PositionX)
                {
                    retVal = NO;
                    break;
                }
    return retVal;
}
-(bool)canMoveRight:(Brick*)brick
{
    bool retVal = brick.PositionX + 1 < posXCount;
    if (retVal)
        for (Brick *b in _bricks)
            if (b != brick)
                if (b.PositionX == brick.PositionX + 1 && b.PositionY == brick.PositionY)
                {
                    retVal = NO;
                    break;
                }
    return retVal;
}
-(bool)canMoveLeft:(Brick*)brick
{
    bool retVal = brick.PositionX > 0;
    if (retVal)
        for (Brick *b in _bricks)
            if (b != brick)
                if (b.PositionX == brick.PositionX - 1 && b.PositionY == brick.PositionY)
                {
                    retVal = NO;
                    break;
                }
    return retVal;
}
-(bool)anyBrickAtPosition: (Position*) p
{
    for (Brick *b in _bricks)
        if ([p isEqualPos:b.Pos])
            return YES;
    return NO;
}

- (void)moveBricksDown
{
    onMoveBricksDown = YES;
    bool newCoupleNeed = YES;
    
    for (Brick *b in _bricks)
        b.IsMoved = NO;
    
    for (Brick *b in _bricks)
    {
        if ([self canMoveDown:b])
        {
            if (b.Couple != nil)
            {
                if (b.Couple.PositionX != b.PositionX)
                {
                    if ([self canMoveDown:b.Couple])
                    {
                        b.PositionY++;
                        b.IsMoved = YES;
                        newCoupleNeed = NO;
                    }
                    else if (b.Couple.IsMoved)
                    {
                        b.PositionY++;
                        b.IsMoved = YES;
                        newCoupleNeed = NO;
                    }
                }
                else
                {
                    b.PositionY++;
                    b.IsMoved=YES;
                    b.Couple.PositionY++;
                    b.Couple.IsMoved=YES;
                    newCoupleNeed = NO;
                }
            }
            else
            {
                b.PositionY++;
                b.IsMoved = YES;
                newCoupleNeed = NO;
            }
        }
        newCoupleNeed = newCoupleNeed || (b.PositionY > posYCount / newCoupleScreenDivider);
        [self setBrickPosition:b];
        [self setBrickPosition:b.Couple];
    }
    
    if (newCoupleNeed)
        [self createBrickCouple];
    
    onMoveBricksDown = NO;
}

- (void)slideBrick:(CGPoint)positionInScene
{
    if (selectedBrick != nil && selectedBrick.Couple!=nil)
    {
        if (fabs(positionInScene.x - [self CGPosXFromPosX:selectedBrick.PositionX]) > selectedBrick.size.width)
        {
            int xDeltaPos = (int)roundf((positionInScene.x - xMargin/2) / (selectedBrick.size.width));
            xDeltaPos = MIN(xDeltaPos, posXCount-1);
            xDeltaPos = MAX(xDeltaPos, 0);
            
            if (positionInScene.x > firstTouchX)
            {
                if (selectedBrick.PositionX == selectedBrick.Couple.PositionX)
                {
                    while (xDeltaPos > selectedBrick.PositionX)
                    {
                        if ([self canMoveRight:selectedBrick] && [self canMoveRight:selectedBrick.Couple])
                        {
                            selectedBrick.IsMoved = selectedBrick.Couple.IsMoved = YES;
                            selectedBrick.PositionX ++;
                            selectedBrick.Couple.PositionX ++;
                            [self setBrickPosition:selectedBrick];
                            [self setBrickPosition:selectedBrick.Couple];
                            break;
                        }
                        else
                            break;
                    }
                }
                else if (selectedBrick.PositionX > selectedBrick.Couple.PositionX)
                {
                    while (xDeltaPos > selectedBrick.PositionX)
                    {
                        if ([self canMoveRight:selectedBrick])
                        {
                            selectedBrick.IsMoved = selectedBrick.Couple.IsMoved = YES;
                            selectedBrick.PositionX++;
                            selectedBrick.Couple.PositionX++;
                            [self setBrickPosition:selectedBrick];
                            [self setBrickPosition:selectedBrick.Couple];
                            break;
                        }
                        else
                            break;
                    }
                }
                else
                {
                    while (xDeltaPos > selectedBrick.Couple.PositionX)
                    {
                        if ([self canMoveRight:selectedBrick.Couple])
                        {
                            selectedBrick.IsMoved = selectedBrick.Couple.IsMoved = YES;
                            selectedBrick.PositionX ++;
                            selectedBrick.Couple.PositionX ++;
                            [self setBrickPosition:selectedBrick];
                            [self setBrickPosition:selectedBrick.Couple];
                            break;
                        }
                        else
                            break;
                    }
                }
                //NSLog(@"Right Move");
            }
            else
            {
                if (selectedBrick.PositionX == selectedBrick.Couple.PositionX)
                {
                    while (xDeltaPos < selectedBrick.PositionX)
                    {
                        if ([self canMoveLeft:selectedBrick] && [self canMoveLeft:selectedBrick.Couple])
                        {
                            selectedBrick.IsMoved = selectedBrick.Couple.IsMoved = YES;
                            selectedBrick.PositionX --;
                            selectedBrick.Couple.PositionX --;
                            [self setBrickPosition:selectedBrick];
                            [self setBrickPosition:selectedBrick.Couple];
                            break;
                        }
                        else
                            break;
                    }
                }
                else if (selectedBrick.PositionX < selectedBrick.Couple.PositionX)
                {
                    while (xDeltaPos < selectedBrick.PositionX)
                    {
                        if ([self canMoveLeft:selectedBrick])
                        {
                            selectedBrick.IsMoved = selectedBrick.Couple.IsMoved = YES;
                            selectedBrick.PositionX --;
                            selectedBrick.Couple.PositionX --;
                            [self setBrickPosition:selectedBrick];
                            [self setBrickPosition:selectedBrick.Couple];
                            break;
                        }
                        else
                            break;
                    }
                }
                else
                {
                    while (xDeltaPos < selectedBrick.Couple.PositionX)
                    {
                        if ([self canMoveLeft:selectedBrick.Couple])
                        {
                            selectedBrick.IsMoved = selectedBrick.Couple.IsMoved = YES;
                            selectedBrick.PositionX --;
                            selectedBrick.Couple.PositionX --;
                            [self setBrickPosition:selectedBrick];
                            [self setBrickPosition:selectedBrick.Couple];
                            break;
                        }
                        else
                            break;
                    }
                }
                //NSLog(@"Left Move");
            }
            brickMoved = YES;
            firstTouchX = positionInScene.x;
        }
    }
}

- (void)rotateBrick:(Brick *)node
{
    if (!onMoveBricksDown)
    {
        Brick* b = (Brick*)node;
        if (b.Couple != nil)
        {
            BrickCouple* bc = (BrickCouple*)b.ParentCouple;
            if (bc == nil) return;
            if ([self canMoveDown:b] || [self canMoveDown:b.Couple])
            {
                if (bc.rotationPos == 0)
                {
                    if ([self canMoveRight:bc.Brick2] && ![self anyBrickAtPosition:bc.Brick1.Pos.Right])
                    {
                        bc.Brick2.Pos = bc.Brick1.Pos.Right;
                        bc.rotationPos = 1;
                        bc.Brick2.IsMoved = YES;
                        [self setBrickPosition:bc.Brick2];
                    }
                }
                else if (bc.rotationPos == 1)
                {
                    if ([self canMoveUp:bc.Brick2] && ![self anyBrickAtPosition:bc.Brick1.Pos.Top])
                    {
                        bc.Brick2.Pos = bc.Brick1.Pos.Top;
                        bc.rotationPos = 2;
                        bc.Brick2.IsMoved = YES;
                        [self setBrickPosition:bc.Brick2];
                    }
                }
                else if (bc.rotationPos == 2)
                {
                    if ([self canMoveLeft:bc.Brick2] && ![self anyBrickAtPosition:bc.Brick1.Pos.Left])
                    {
                        bc.Brick2.Pos = bc.Brick1.Pos.Left;
                        bc.rotationPos = 3;
                        bc.Brick2.IsMoved = YES;
                        [self setBrickPosition:bc.Brick2];
                    }
                }
                else
                {
                    if ([self canMoveDown:bc.Brick2] && ![self anyBrickAtPosition:bc.Brick1.Pos.Bottom])
                    {
                        bc.Brick2.Pos = bc.Brick1.Pos.Bottom;
                        bc.rotationPos = 0;
                        bc.Brick2.IsMoved = YES;
                        [self setBrickPosition:bc.Brick2];
                    }
                }
            }
        }
    }
}

-(void)explodeBircks
{
    NSMutableArray *discardedItems = [NSMutableArray array];
    for (int b0 = 0; b0 < _bricks.count; b0++)
    {
        for (int b1 = b0 + 1; b1 < _bricks.count; b1++)
        {
            Brick* bb0 = _bricks[b0];
            Brick* bb1 = _bricks[b1];
            if (bb0.Couple != bb1 && bb1.Couple != bb0 && bb0 != bb1
                && !bb0.IsReadyToExplode && !bb1.IsReadyToExplode
                && bb1.BrickType == bb0.BrickType)
            {
                bool isbb0Stuck = !bb0.IsMoved;
                bool isbb1Stuck = !bb1.IsMoved;
                
                if (isbb0Stuck && isbb1Stuck)
                {
                    bb0.IsReadyToExplode = bb1.IsReadyToExplode =
                    ([[bb0.Pos Right] isEqualPos:bb1.Pos]  ||
                     [[bb0.Pos Left] isEqualPos:bb1.Pos]   ||
                     [[bb0.Pos Top] isEqualPos:bb1.Pos]    ||
                     [[bb0.Pos Bottom] isEqualPos:bb1.Pos] );
                    
                    if (bb0.IsReadyToExplode)
                    {
                        [discardedItems addObject:bb0];
                        [discardedItems addObject:bb1];
                    }
                }
            }
        }
    }
    
    if (discardedItems.count>0)
    {
        [_bricks removeObjectsInArray:discardedItems];
        for (Brick* b in discardedItems)
        {
            b.Couple.Couple = nil;
            b.Couple = nil;
            [b removeFromParent];
            
            score += posXCount * posYCount * newCoupleScreenDivider / levelIntervalInSeconds / 100;
            [self drawScore];
            
            SKAction* bum = [SKAction playSoundFileNamed:@"Bum4.wav" waitForCompletion:NO];
            [self runAction:bum];
        }
    }
}

#pragma mark - Score & Game Calcutions

-(void)calculateScore
{
    score += 10 / levelIntervalInSeconds;
    [self drawScore];
}
-(void)drawScore
{
    if (scoreLabel == nil)
    {
        float frameW = CGRectGetWidth(self.frame);
        float frameH = CGRectGetHeight(self.frame);
        scoreLabel =  [SKLabelNode labelNodeWithFontNamed:@"Chalkboard SE"];
        scoreLabel.fontSize = (int)(frameH / 16);
        scoreLabel.fontColor = [SKColor purpleColor];
        scoreLabel.position = CGPointMake(frameW / 2, frameH - yMargin / 2 - frameH / 32);
        [self addChild:scoreLabel];
    }
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    
    if (nextLevelScore < score)
        [self levelUp];
}

-(void)levelUp
{
    level++;
    levelPow=2;
    nextLevelScore *= levelPow;
    
    if ((float)levelIntervalInSeconds > 4.0/(float)posYCount)
        levelIntervalInSeconds -= 0.05;
    else if (newCoupleScreenDivider < 2)
        newCoupleScreenDivider *= 2;
    else
    {
        //Remove Objects
        [self destroyGridLines];
        [_gotoMenuButton removeFromParent];
        _gotoMenuButton=nil;
        [_soundButton removeFromParent];
        _soundButton=nil;
        [_playPauseButton removeFromParent];
        _playPauseButton=nil;
        [scoreLabel removeFromParent];
        scoreLabel = nil;
        for (Brick* b in _bricks)
            [b removeFromParent];
        //Resize Grid & Add Old Bricks
        posXCount *= 1.125;
        posYCount *= 1.125;
        [self startGameWithBricks];
        for (Brick* b in _bricks)
            [self setBrickPosition:b];
    }
    
    if (levelUpSign != nil)
    {
        [levelUpSign removeFromParent];
        levelUpSign = nil;
    }
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    levelUpSign = [SKSpriteNode spriteNodeWithImageNamed:@"LevelUp"];
    [levelUpSign setPosition:CGPointMake(frameW/2,frameH/2)];
    [levelUpSign setSize:CGSizeMake(7.5, 5.92)];
    [self addChild:levelUpSign];

    SKAction* e0 = [SKAction fadeInWithDuration:0.25];
    SKAction* e1 = [SKAction scaleBy:50 duration:0.5];
    SKAction* e2 = [SKAction fadeOutWithDuration:0.25];
    SKAction* sequence = [SKAction sequence:@[e0,e1,e2]];
    [levelUpSign runAction:sequence];
}

-(void)checkGameOver
{
    if (gameOver)
        return;
    
    for (Brick *b in _bricks)
    {
        if (b.PositionY == 0)
        {
            if (b.Couple == nil)
            {
                if (![self canMoveDown:b])
                {
                    [self gameOver];
                    return;
                }
            }
            else
            {
                
                if ((b.Couple.PositionX == b.PositionX && ![self canMoveDown:b] && ![self canMoveDown:b.Couple])
                    ||
                    (b.Couple.PositionY == b.PositionY && (![self canMoveDown:b] || ![self canMoveDown:b.Couple])))
                {
                    [self gameOver];
                    return;
                }
            }
        }
    }
}
-(void)gameOver
{
    gameOver = YES;
    [self createBackgroundMusic2];
    
    [self SendHighScoreToServerAlert];
}

#pragma mark - events
-(void)didMoveToView:(SKView *)view
{
    /* Setup your scene here */
    [self createGridLines];
    [self createMenu];
    [self createBackground];
    [self createBackgroundMusic2];
    
    _bricks = [[NSMutableArray alloc] init];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99)
    {
        if (buttonIndex != 0)  // 0 == the cancel button
        {
            //home button press programmatically
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
            //wait 2 seconds while app is going background
            [NSThread sleepForTimeInterval:2.0];
            //exit app when app is in background
            exit(0);
        }
    }
    else if (alertView.tag == 98)
    {
        if (buttonIndex != 0)  // 0 == the cancel button
            [self gameOver];
        else
        {
            gamePaused = NO;
            if (isSoundOn)
                [player play];
        }
    }
    else if (alertView.tag == 123)
    {
        if (buttonIndex == 0)  // 0 == the cancel button
        {
            
        }
        else
        {
            NSString* btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
            [self postTo:btnTitle];
        }
        
        [self gotoMenu];
    }
    else if (alertView.tag == 124)
    {
        if (buttonIndex == 0)  // 0 == the cancel button
        {
            [self postToAlert];
        }
        else
        {
            UserName = [alertView textFieldAtIndex:0].text;
            [self SendHighScoreToServer];
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /*
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    */
    
    if(!onMenu)
        if (selectedBrick != nil && !brickMoved)
            [self rotateBrick:selectedBrick];
    
    brickMoved = NO;
    selectedBrick =nil;
    firstTouchX = 0;
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    //CGPoint previousPosition = [touch previousLocationInNode:self];
    
    if(!onMenu)
        [self slideBrick:positionInScene];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    firstTouchX = location.x;
    
    if ([node.name isEqualToString:_btnExit.name])
    {
        [self doExit];
        return;
    }
    if ([node.name isEqualToString:_btnStart.name])
    {
        [self startGame];
        return;
    }
    if ([node.name isEqualToString:_btnHowToPlay.name])
    {
        if (_howToPlayScreen != nil)
        {
            [_howToPlayScreen removeFromParent];
            _howToPlayScreen = nil;
        }
        if (_howToPlayCloseButton != nil)
        {
            [_howToPlayCloseButton removeFromParent];
            _howToPlayCloseButton = nil;
        }
        
        float frameW = CGRectGetWidth(self.frame);
        float frameH = CGRectGetHeight(self.frame);
        _howToPlayScreen = [SKSpriteNode spriteNodeWithImageNamed:@"HowToPlayScreen"];
        float ratio = 1199.0/1921.0;
        float h = frameH - yMargin*2;
        float w = h*ratio;
        [_howToPlayScreen setSize:CGSizeMake(w,h)];
        [_howToPlayScreen setPosition:CGPointMake(frameW/2, frameH/2)];
        [_howToPlayScreen setZPosition:12];
        [self addChild:_howToPlayScreen];
        
        _howToPlayCloseButton = [SKSpriteNode spriteNodeWithImageNamed:@"GotoMenu"];
        _howToPlayCloseButton.name = @"HowToPlayClose";
        float h1 = frameH/16;
        float w1 = h1;
        [_howToPlayCloseButton setSize:CGSizeMake(w1, h1)];
        [_howToPlayCloseButton setPosition:CGPointMake(frameW/2+w/2-xMargin/2, frameH/2+h/2-yMargin/2)];
        [_howToPlayCloseButton setZPosition:13];
        [self addChild:_howToPlayCloseButton];
        
        return;
    }
    if ([node.name isEqualToString:_howToPlayCloseButton.name])
    {
        [_howToPlayCloseButton removeFromParent];
        [_howToPlayScreen removeFromParent];
        
        return;
    }
    if ([node.name isEqualToString:_btnRate.name])
    {
        NSString* itunesLink=[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",AppId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: itunesLink]];
        
        return;
    }
    if ([node.name isEqualToString:_btnHighScore.name])
    {
        NSString* link=[NSString stringWithFormat:@"%@/HighScore",WebSite];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: link]];
        return;
    }
    
    
    if ([node.name isEqualToString:@"soundButton"])
    {
        isSoundOn = !isSoundOn;
        if (!isSoundOn)
            [player stop];
        else
            [self createBackgroundMusic1];
        
        [node removeFromParent];
        [self createSoundButton:isSoundOn];
        return;
    }
    
    if ([node.name isEqualToString:@"playPauseButton"])
    {
        gamePaused = !gamePaused;
        if (gamePaused)
            [player stop];
        else if (isSoundOn)
            [player play];
            
        [node removeFromParent];
        [self createPlayPauseButton:gamePaused];
        return;
    }
    
    if ([node.name isEqualToString:@"gotoMenuButton"])
    {
        gamePaused = YES;
        [player stop];
        
        //show confirmation message to user
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"End Game"
                                                        message:@"Are you leaving?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = 98;
        [alert show];
        
        return;
    }
    
    if([node isKindOfClass:[Brick class]])
    {
        selectedBrick = (Brick*)node;
        return;
    }
    else
    {
        for (Brick* b in _bricks)
        {
            float left = [self CGPosXFromPosX:[[[b Pos] Left] Left].X];
            float right = [self CGPosXFromPosX:[[[b Pos] Right] Right].X];
            float top = [self CGPosYFromPosY:[[[b Pos] Top] Top].Y];
            float bottom = [self CGPosYFromPosY:[[[b Pos] Bottom] Bottom].Y];
            
            if (location.x > left && location.x < right &&
                location.y > bottom && location.y < top)
            {
                selectedBrick = b;
                return;
            }
        }
    }
    
    /*
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.xScale = 0.5;
        sprite.yScale = 0.5;
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
    */
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
    if (!onMenu && !gameOver && !gamePaused)
    {
        if (updatedTime == 0 || currentTime - updatedTime > levelIntervalInSeconds)
        {
            [self checkGameOver];
            [self explodeBircks];
            [self moveBricksDown];
            //[self calculateScore];
            updatedTime=currentTime;
        }
    }
    else if (onMenu)
    {
        if (updatedTime == 0 || currentTime - updatedTime > 0.25)
        {
            [self moveBricksDown];
            updatedTime=currentTime;
        }
    }
}

@end