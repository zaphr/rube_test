//  Author: Chris Campbell - www.iforce2d.net
//  -----------------------------------------
//
//  BasicRUBELayer
//
//  This class extends CCLayer to load in a RUBE scene file on init.
//  It uses the debug draw display to show the scene, and  does not
//  load any images. The touch methods are used to zoom, pan, and to
//  create a mouse joint to drag dynamic bodies around.
//
//  This class is mostly here to keep the first example simple, and
//  concentrate on getting positions and scales correct before any
//  images are involved. In most cases you would subclass RUBELayer
//  to make a more useful layer.
//
//  The scene file to load, and the initial position and scale are
//  given by methods which should be overridden in subclasses.
//
//  The position of the layer is set with [self setPosition:(CGPoint)]
//  and specifies the location on screen where 0,0 in the physics world
//  will be located, in pixels. Hence you can check anytime where the
//  (0,0) point of the physics world is with [self position]
//
//  The scale of the layer is the number of pixels for one physics unit.
//  Eg. if the screen is 320 pixels high and you want it to be 10 units
//  high in the physics world, the scale would be 32. You can set this
//  with [self setScale:(float)] and check it with [self scale].
//
//  This class provides the screenToWorld and worldToScreen methods
//  which are invaluable when converting locations between screen and
//  physics world coordinates.
//

#import "cocos2d.h"
#include <Box2D/Box2D.h>
#include "GLES-Render.h"

@interface BasicRUBELayer : CCLayer
{
    b2World* m_world;                   // the physics world
	GLESDebugDraw* m_debugDraw;         // used to draw debug data
    b2MouseJoint* m_mouseJoint;         // used when dragging bodies around
    b2Body* m_mouseJointGroundBody;     // the other body for the mouse joint (static, no fixtures)

    CCMenu* m_menuLayer;                // only for this demo project, you can remove this in your own app
}

+(CCScene*)scene;                                                       // standard Cocos2d layer instantiator
-(CCLayer*)setupMenuLayer;                                              // only for this demo project, you can remove this in your own app
-(void)updateAfterOrientationChange:(NSNotification *)notification;     // only for this demo project (repositions the menu), you can remove this in your own app

-(NSString*)getFilename;                                                // override this in subclasses to specify which .json file to load
-(CGPoint)initialWorldOffset;                                           // override this in subclasses to set the inital view position
-(float)initialWorldScale;                                              // override this in subclasses to set the initial view scale

-(void)loadWorld:(id)item;                                              // attempts to load the world from the .json file given by getFilename
-(void)afterLoadProcessing:(class b2dJson*)json;                        // override this in a subclass to do something else after loading the world (before discarding the JSON info)
-(void)clear;                                                           // undoes everything done by loadWorld and afterLoadProcessing, so that they can be safely called again

-(void) tick: (ccTime) dt;                                              // standard Cocos2d layer method

-(b2Vec2) screenToWorld:(CGPoint)screenPos;                             // converts a position in screen pixels to a location in the physics world
-(CGPoint) worldToScreen:(b2Vec2)worldPos;                              // converts a location in the physics world to a position in screen pixels

@end
