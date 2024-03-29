//
//  HelloWorldLayer.h
//  munchem
//
//  Created by andrew morton on 11/27/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
}

@property int score;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) setupGame;
- (NSArray*) biteAt: (CGPoint) location;
- (void) chewPieces: (NSArray*) mouthful at: (CGPoint) location;
@end
