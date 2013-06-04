//  Author: Chris Campbell - www.iforce2d.net
//  -----------------------------------------
//
//  RUBEImageInfo
//
//  Holds information about one image in the layer, most importantly
//  the body it is attached to and its position relative to that body.
//
//  When the body is moved by the physics engine, this information is
//  used to place the image in the correct position to match the physics.
//  If the body is NULL, the position is relative to 0,0 and angle zero.
//
//  This could just as easily have been a C-style struct, but ended up a
//  somewhat misguided attempt to placate those who like everything to be
//  as Obj-C as possible. I also didn't know about NSValue valueWithPointer
//  which lets you put C-style pointers into a NSMutableArray.
//

#import "cocos2d.h"

@interface RUBEImageInfo : NSObject {
    
    @public CCSprite* sprite;               // the image
    @public NSString* name;                 // the file the image was loaded from
    @public class b2Body* body;             // the body this image is attached to (can be NULL)
    @public float scale;                    // a scale of 1 means the image is 1 physics unit high
    @public float angle;                    // 'local angle' - relative to the angle of the body
    @public CGPoint center;                 // 'local center' - relative to the position of the body
    @public float opacity;                  // 0 - 1
    @public bool flip;                      // horizontal flip
    @public int colorTint[4];               // 0 - 255 RGBA values
}

@end
