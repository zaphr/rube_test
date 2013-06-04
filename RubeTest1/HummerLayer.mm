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
    return @"hummer.json";
}

@end
