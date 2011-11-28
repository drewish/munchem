//
//  HelloWorldLayer.m
//  munchem
//
//  Created by andrew morton on 11/27/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

int count = 50;
NSMutableArray *edible;
CCSprite *eater;
CCLabelTTF *label;

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize distance;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        self.distance = 0;
                
        edible = [[NSMutableArray alloc] initWithCapacity: count];
        for (int i = 0; i < count; i++) {
            CCSprite *p = [CCSprite spriteWithFile: @"Icon-Small.png"];
            p.position = ccp(
                (arc4random() % ((int) size.width - 50)) + 25,
                (arc4random() % ((int) size.height - 50)) + 25
            );
            [self addChild: p];
            [edible addObject: p];
        }
        
        eater = [CCSprite spriteWithFile: @"Icon.png"];
        eater.position = ccp(50, 50);
        [self addChild: eater];
        
		label = [CCLabelTTF labelWithString:@"Go munch 'em!" dimensions:CGSizeMake(size.width,50) alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:32];
		label.position = ccp(size.width/2, size.height/2);
		[self addChild: label];
        
        self.isTouchEnabled = YES;

        [self scheduleUpdate];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [edible release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) update:(ccTime) dt
{
    NSString *str;
    
    if ([edible count] == 0) {
        str = @"Good Job!";
    }
    else {
        str = [NSString stringWithFormat:@"%4d", distance];
    }
    [label setString:str];        
}


-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	// Figure out our destination...
    CGPoint location = [self convertTouchToNodeSpace: touch];
        
    // ...and how big of a bite we take.
    int width = [eater boundingBox].size.width,
        height = [eater boundingBox].size.height;
    CGRect bite = CGRectMake(location.x - width / 2, location.y - height / 2, width, height);
    
    int d = ccpDistance(location, eater.position);
    
    ccTime moveDuration = 0.3;
    __block ccTime chewAt = moveDuration;
    // Then find what's going into our mouth.
    NSMutableArray *mouthful = [[NSMutableArray alloc] init]; 
    [edible enumerateObjectsUsingBlock:^(id s, NSUInteger idx, BOOL *stop) {
        int w = [s boundingBox].size.width,
            h = [s boundingBox].size.height;
        CGRect piece = CGRectMake([s position].x - w / 2, [s position].y - h / 2, w, h);
        if (CGRectIntersectsRect(bite, piece)) {
            [mouthful addObject: s];
            chewAt = chewAt + 0.01;
            [self runAction: [CCSequence actions: 
                              [CCDelayTime actionWithDuration: chewAt], 
                              [CCCallBlock actionWithBlock:^{ [s removeFromParentAndCleanup:YES]; }], 
                              nil]];
        }
    }];

    // Now move them from edible to eaten.
    [edible removeObjectsInArray: mouthful];

    // TODO: we should have it do a "chomping" animation if it eats something.
    [eater runAction: [CCMoveTo actionWithDuration: moveDuration position: location]];
    [self runAction: [CCActionTween actionWithDuration: moveDuration key: @"distance" from: distance to: (d + distance)]];
    
    [mouthful release];
}

@end
