//
//  TemplateLayer.mm
//  RubeTest1
//
//  Created by gb on 9/07/13.
//  Copyright (c) 2013 zaphr. All rights reserved.
//

#include "TemplateLayer.h"

@implementation TemplateLayer

// Standard Cocos2d method, simply returns a scene with an instance of this class as a child
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	TemplateLayer *layer = [TemplateLayer node];
    
	[scene addChild: layer];
    
    // only for this demo project, you can remove this in your own app
    //	[scene addChild: [layer setupMenuLayer]];
    
	return scene;
}


// Override superclass to load different RUBE scene
-(NSString*)getFilename
{
    return @"template.json";
}

// Override superclass to set different starting offset
-(CGPoint)initialWorldOffset
{
    // If you are not sure what to set the starting position as, you can
    // pan and zoom the scene until you get the right fit, and then set
    // a breakpoint in the draw or tick methods to see what the values
    // of [self scale] and [self position] are.
    //
    // For the images.json scene, I did this on my iPad in landscape (1024x768)
    // and came up with a value of 475,397 for the position. Since the
    // offset is measured in pixels, we need to set this as a percentage of
    // the current screen height instead of a fixed value, to get the same
    // result on different devices.
    //
    CGSize s = [[CCDirector sharedDirector] winSize];
    //    return CGPointMake( s.width * (475 / 1024.0), s.height * (397 / 768.0) );
    
    return CGPointMake( s.width /2, s.height / 2 );
    //            return CGPointMake( s.width / 2, s.height / 2 );
}

// Override superclass to set different starting scale
-(float)initialWorldScale
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    CCLOG(@"screen height: %f", s.height);
    
    //    return s.height / 35; //screen will be 35 physics units high
    return (s.height ) / 40;
}


//// Override this in subclasses to set the inital view position
//-(CGPoint)initialWorldOffset
//{
//    // This method should return the location in pixels to place
//    // the (0,0) point of the physics world. The screen position
//    // will be relative to the bottom left corner of the screen.
//    
//    //place (0,0) of physics world at center of bottom edge of screen
//    CGSize s = [[CCDirector sharedDirector] winSize];
//    return CGPointMake( s.width/2, 0 );
//}


//// Override this in subclasses to set the inital view scale
//-(float)initialWorldScale
//{
//    // This method should return the number of pixels for one physics unit.
//    // When creating the scene in RUBE I can see that the jointTypes scene
//    // is about 8 units high, so I want the height of the view to be about
//    // 10 units, which for iPhone in landscape (480x320) we would return 32.
//    // But for an iPad in landscape (1024x768) we would return 76.8, so to
//    // handle the general case, we can make the return value depend on the
//    // current screen height.
//    
//    CGSize s = [[CCDirector sharedDirector] winSize];
//    return s.height / 10; //screen will be 10 physics units high
//}


@end
