//
//  HelloWorldLayer.m
//  munchem
//
//  Created by andrew morton on 11/27/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

int count = 25;
NSMutableArray *edible, *eaten;
CCSprite *eater;
CCLabelTTF *label;

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize score;

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
           
        edible = [[NSMutableArray alloc] initWithCapacity: count];
        eaten = [[NSMutableArray alloc] initWithCapacity: count];
        for (int i = 0; i < count; i++) {
            CCSprite *p = [CCSprite spriteWithFile: @"Icon-Small.png"];
            [p setVisible: FALSE];
            [self addChild: p];
            [edible addObject: p];
        }
        
        eater = [CCSprite spriteWithFile: @"Icon.png"];
        [self addChild: eater];
        
		label = [CCLabelTTF labelWithString:@"Go munch 'em!" dimensions:CGSizeMake(size.width, 50) alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:32];
		label.position = ccp(size.width / 2, size.height - 50);
		[self addChild: label z: 1];
         
        CCMenuItemFont *item = [CCMenuItemFont itemFromString: @"Again!" target: self selector: @selector(setupGame)];
		[item setFontSize: 20];
		[item setFontName: @"Marker Felt"];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
// @TODO Figure out the right way to position these.
		menu.position = CGPointZero;
		item.position = ccp(size.width - 50, size.height - 50);
		[self addChild: menu z: 1];	
        
        self.isTouchEnabled = YES;

        [self setupGame];
        
        [self scheduleUpdate];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [edible release];
    [eaten release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) setupGame
{
    // ask director the the window size
    CGSize size = [[CCDirector sharedDirector] winSize];

    // Put everything back into edible the reposition it.
    [edible addObjectsFromArray: eaten];
    [eaten removeAllObjects];
    [edible enumerateObjectsUsingBlock:^(id s, NSUInteger idx, BOOL *stop) {
        [s setVisible: FALSE];
        [s setPosition: ccp(arc4random_uniform((int) size.width - 50) + 25, arc4random_uniform((int) size.height - 50) + 25)];
        [s setVisible: TRUE];
    }];
    
    [eater setPosition: ccp(size.width / 2, size.height / 2)];
    
    score = 0;
}
                                
-(void) update:(ccTime) dt
{
    NSString *format = ([edible count] == 0) ? @"%4d Good Job!" : @"%4d";
    [label setString: [NSString stringWithFormat: format, [self score]]];        
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
        
    NSArray *mouthful = [self biteAt: location];
    [self chewPieces: mouthful at: location];
}
     
- (NSArray*) biteAt: (CGPoint) location {
    // ...and how big of a bite we take.
    int width = [eater boundingBox].size.width,
    height = [eater boundingBox].size.height;
    CGRect bite = CGRectMake(location.x - width / 2, location.y - height / 2, width, height);
    
    
    // Then find what's going into our mouth.
    NSMutableArray *mouthful = [NSMutableArray array]; 
    [edible enumerateObjectsUsingBlock:^(id s, NSUInteger idx, BOOL *stop) {
        // TODO might be better to compute these and save them... I'm not sure
        // if it's better to use CPU or memory.
        int w = [s boundingBox].size.width,
            h = [s boundingBox].size.height;
        CGRect piece = CGRectMake([s position].x - w / 2, [s position].y - h / 2, w, h);
        if (CGRectIntersectsRect(bite, piece)) {
            [mouthful addObject: s];
        }
    }];
    
    return [NSArray arrayWithArray: mouthful];
}

- (void) chewPieces:(NSArray*) mouthful at: (CGPoint) location {
    ccTime moveDuration = 0.3;
    int distance = ccpDistance(location, eater.position);
    int points = [mouthful count] * 50;
    
    NSMutableArray *eaterActions = [NSMutableArray arrayWithObject: 
                                    [CCMoveTo actionWithDuration: moveDuration position: location]];
    if ([mouthful count] > 0) {
        [eaterActions addObject: [CCRotateTo actionWithDuration: 0.02 angle: 20.0]];
        
        NSMutableArray *mouthfulActions = [NSMutableArray arrayWithObject: [CCDelayTime actionWithDuration: moveDuration]];
        [mouthful enumerateObjectsUsingBlock:^(id s, NSUInteger idx, BOOL *stop) {
            // Swing back and forth while we eat it...
            [eaterActions addObject: [CCRotateTo actionWithDuration: 0.02 angle: -20.0]];
            [eaterActions addObject: [CCRotateTo actionWithDuration: 0.02 angle: 20.0]];
            // ...and have it disappear
            [mouthfulActions addObject: [CCDelayTime actionWithDuration: 0.04]];
            [mouthfulActions addObject: [CCCallBlock actionWithBlock:^{ [s setVisible: FALSE]; }]];
        }];
        [self runAction: [CCSequence actionsWithArray: [NSArray arrayWithArray: mouthfulActions]]];
        
        [eaterActions addObject: [CCRotateTo actionWithDuration: 0.02 angle: 0]];
        
        [edible removeObjectsInArray: mouthful];
        [eaten addObjectsFromArray: mouthful];
    }
    [eater runAction: [CCSequence actionsWithArray: [NSArray arrayWithArray: eaterActions]]];
    
    [self runAction: [CCActionTween actionWithDuration: moveDuration key: @"score" from: score to: (score - distance + points)]];
}

@end
