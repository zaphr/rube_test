//
//  HummerLayer.m
//  RubeTest1
//
//  Created by gb on 4/06/13.
//  Copyright (c) 2013 zaphr. All rights reserved.
//

#import "HummerLayer.h"

@implementation HummerLayer

// Standard Cocos2d method, simply returns a scene with an instance of this class as a child
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	HummerLayer *layer = [HummerLayer node];
        
	[scene addChild: layer];
    
    // only for this demo project, you can remove this in your own app
    //	[scene addChild: [layer setupMenuLayer]];
    
	return scene;
}


// Override superclass to load different RUBE scene
-(NSString*)getFilename
{
    return @"plane.json";
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

        return CGPointMake( s.width / 4, s.height / 4 );
//            return CGPointMake( s.width / 2, s.height / 2 );
}

// Override superclass to set different starting scale
-(float)initialWorldScale
{
    CGSize s = [[CCDirector sharedDirector] winSize];
//    return s.height / 35; //screen will be 35 physics units high
    return 10.0;
}

@end
