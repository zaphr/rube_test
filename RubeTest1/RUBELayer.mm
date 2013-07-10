//  Author: Chris Campbell - www.iforce2d.net
//  -----------------------------------------
//
//  RUBELayer
//
//  See header file for description.
//

#import "RUBELayer.h"
#include "b2dJson.h"
#include "b2dJsonImage.h"
#import "RUBEImageInfo.h"

@implementation RUBELayer

// Standard Cocos2d method, simply returns a scene with an instance of this class as a child
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	RUBELayer *layer = [RUBELayer node];
	[scene addChild: layer];
    
    // only for this demo project, you can remove this in your own app
//	[scene addChild: [layer setupMenuLayer]];
    
	return scene;
}


// Override superclass to load different RUBE scene
-(NSString*)getFilename
{
    return @"images.json";
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
    return CGPointMake( s.width * (475 / 1024.0), s.height * (397 / 768.0) );
}


// Override superclass to set different starting scale
-(float)initialWorldScale
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    return s.height / 35; //screen will be 35 physics units high
}


// This is called after the Box2D world has been loaded, and while the b2dJson information
// is still available to do extra loading. Here is where we load the images.
-(void)afterLoadProcessing:(b2dJson*)json
{
    // fill a vector with all images in the RUBE scene
    std::vector<b2dJsonImage*> b2dImages;
    json->getAllImages(b2dImages);
 
    // allocate the member array to store the image infos
    m_imageInfos = [NSMutableArray arrayWithCapacity:b2dImages.size()];
    
    // for retina, should make images twice as large in pixels
    float contentScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
    
    // loop through the vector, create CCSprites for each image and store them in m_imageInfos
    for (uint i = 0; i < b2dImages.size(); i++) {
        b2dJsonImage* img = b2dImages[i];

        CCLOG(@"Loading image: %s", img->file.c_str());
        
        // try to load the sprite image, and ignore if it fails
        CCSprite* sprite = [CCSprite spriteWithFile:[NSString stringWithUTF8String:img->file.c_str()]];
        if ( nil == sprite )
            continue;
        
        // add the sprite to this layer and set the render order
        [self addChild:sprite z:img->renderOrder]; //watch out - RUBE render order is float but cocos2d uses integer (why not float?)
        
        // these will not change during simulation so we can set them now
//    TODO    [sprite setScale:img->scale / [sprite contentSizeInPixels].height * contentScaleFactor];
        CCLOG(@"contentScaleFactor: %f", contentScaleFactor);
//        [sprite setScale:img->scale / contentScaleFactor];
        [sprite setScale:0.1 ];
        
        [sprite setFlipX:img->flip];
        [sprite setColor:ccc3(img->colorTint[0], img->colorTint[1], img->colorTint[2])];
        [sprite setOpacity:img->colorTint[3]];
        
        // create an info structure to hold the info for this image (body and position etc)
        RUBEImageInfo* imgInfo = [[RUBEImageInfo alloc] init];
        imgInfo->sprite = sprite;
        imgInfo->name = [NSString stringWithUTF8String:img->name.c_str()];
        imgInfo->body = img->body;
        imgInfo->scale = img->scale;
        imgInfo->angle = img->angle;
        imgInfo->center = CGPointMake(img->center.x, img->center.y);
        imgInfo->opacity = img->opacity;
        imgInfo->flip = img->flip;
        for (int n = 0; n < 4; n++)
            imgInfo->colorTint[n] = img->colorTint[n];
        
        // add the info for this image to the list
        [m_imageInfos addObject:imgInfo];
    }
    
    // start the images at their current positions on the physics bodies
    [self setImagePositionsFromPhysicsBodies];
}


// This method should undo anything that was done by afterLoadProcessing, and make sure
// to call the superclass method so it can do the same
-(void)clear
{
    for (RUBEImageInfo *imgInfo in m_imageInfos)
        [self removeChild:imgInfo->sprite cleanup:YES];
    
    [super clear];
}


// Standard Cocos2d method. Call the super class to step the physics world, and then
// move the images to match the physics body positions
-(void) tick: (ccTime) dt
{
    //superclass will Step the physics world
    [super tick:dt];
    [self setImagePositionsFromPhysicsBodies];
}


// Move all the images to where the physics engine says they should be
-(void)setImagePositionsFromPhysicsBodies
{
    for (RUBEImageInfo *imgInfo in m_imageInfos) {
        CGPoint pos = imgInfo->center;
        float angle = -imgInfo->angle;
        if ( imgInfo->body ) {            
            //need to rotate image local center by body angle
            b2Vec2 localPos( pos.x, pos.y );
            b2Rot rot( imgInfo->body->GetAngle() );
            localPos = b2Mul(rot, localPos) + imgInfo->body->GetPosition();
            pos.x = localPos.x;
            pos.y = localPos.y;
            angle += -imgInfo->body->GetAngle();
        }
        [imgInfo->sprite setRotation:CC_RADIANS_TO_DEGREES(angle)];
        [imgInfo->sprite setPosition:pos];
    }
}


// Remove one body and any images is had attached to it from the layer
-(void)removeBodyFromWorld:(b2Body*)body
{
    //destroy the body in the physics world
    m_world->DestroyBody( body );
    
    //go through the image info array and remove all sprites that were attached to the body we just deleted
    NSMutableArray *imagesToRemove = [NSMutableArray array];
    for (RUBEImageInfo *imgInfo in m_imageInfos) {
        if ( imgInfo->body == body ) {
            [self removeChild:imgInfo->sprite cleanup:YES];
            [imagesToRemove addObject:imgInfo];
        }
    }
    
    //also remove the infos for those images from the image info array
    [m_imageInfos removeObjectsInArray:imagesToRemove];
}


// Remove one image from the layer
-(void)removeImageFromWorld:(RUBEImageInfo*)imgInfo
{
    [self removeChild:imgInfo->sprite cleanup:YES];
    [m_imageInfos removeObject:imgInfo];
}

@end






