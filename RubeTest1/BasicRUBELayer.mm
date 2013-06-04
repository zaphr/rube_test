//  Author: Chris Campbell - www.iforce2d.net
//  -----------------------------------------
//
//  BasicRUBELayer
//
//  See header file for description.
//

//#import "ExamplesMenuLayer.h"
#import "BasicRUBELayer.h"
#include "rubestuff/b2dJson.h"
#include "QueryCallbacks.h"
#include "GLES-Render.h"

@implementation BasicRUBELayer

// Standard Cocos2d method, simply returns a scene with an instance of this class as a child
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	BasicRUBELayer *layer = [BasicRUBELayer node];	
	[scene addChild: layer];
    
    // only for this demo project, you can remove this in your own app
	[scene addChild: [layer setupMenuLayer]];
    
	return scene;
}


// Sets up a menu layer as a child of this layer, to allow the user to return to
// the previous scene, or reload the world.
// This is only for this demo project, you can remove this in your own app.
-(CCLayer*)setupMenuLayer
{
    CCMenuItem* backItem = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(goBack:)];
    CCMenuItem* reloadItem = [CCMenuItemFont itemFromString:@"Reload" target:self selector:@selector(loadWorld:)];
    m_menuLayer = [CCMenu menuWithItems:backItem,reloadItem,nil];
    [m_menuLayer alignItemsHorizontally];
    
    [self updateAfterOrientationChange:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateAfterOrientationChange:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
    return m_menuLayer;
}


// Repositions the menu child layer after the device orientation changes.
// This is only for this demo project, you can remove this in your own app.
-(void)updateAfterOrientationChange:(NSNotification *)notification
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    [m_menuLayer setPosition:CGPointMake(s.width/2,s.height-20)];
}


// Override this in subclasses to specify which .json file to load
-(NSString*)getFilename
{
    return @"jointTypes.json";
}


// Override this in subclasses to set the inital view position
-(CGPoint)initialWorldOffset
{
    // This method should return the location in pixels to place
    // the (0,0) point of the physics world. The screen position
    // will be relative to the bottom left corner of the screen.
    
    //place (0,0) of physics world at center of bottom edge of screen
    CGSize s = [[CCDirector sharedDirector] winSize];
    return CGPointMake( s.width/2, 0 );
}


// Override this in subclasses to set the inital view scale
-(float)initialWorldScale
{
    // This method should return the number of pixels for one physics unit.
    // When creating the scene in RUBE I can see that the jointTypes scene
    // is about 8 units high, so I want the height of the view to be about
    // 10 units, which for iPhone in landscape (480x320) we would return 32.
    // But for an iPad in landscape (1024x768) we would return 76.8, so to
    // handle the general case, we can make the return value depend on the
    // current screen height.
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    return s.height / 10; //screen will be 10 physics units high
}


// Standard Cocos2d method
-(id) init
{
	if( (self=[super init])) {
        
        self.isTouchEnabled = YES;
        
        // make screen position values relative to the bottom left of screen
        [self setAnchorPoint:CGPointMake(0,0)];
        
        // initialize a bunch of things to NULL first
        m_world = NULL;
        m_mouseJoint = NULL;
        m_mouseJointGroundBody = NULL;
        
        // set the starting scale and offset values from the subclass
        [self setPosition:[self initialWorldOffset]];
        [self setScale:[self initialWorldScale]];
        
        // load the world from RUBE .json file (this will also call afterLoadProcessing)
        [self loadWorld:nil];
        
        // tell Cocos2d we want tick events for this layer
		[self schedule: @selector(tick:)];
	}
	return self;
}


// Attempts to load the world from the .json file given by getFilename.
// If successful, the method afterLoadProcessing will also be called,
// to allow subclasses to do something extra while the b2dJson information
// is still available.
-(void)loadWorld:(id)item
{
    // The clear method should undo anything that is done in this method,
    // and also whatever is done in the afterLoadProcessing method.
    [self clear];
    
    NSString* filename = [self getFilename];
    NSString* fullpath = [CCFileUtils fullPathFromRelativePath:filename];
    
    // This will print out the actual location on disk that the file is read from.
    // When using the simulator, exporting your RUBE scene to this folder means
    // you can edit the scene and reload it without needing to restart the app.
    CCLOG(@"Full path is: %@", fullpath);
    
    // Create the world from the contents of the RUBE .json file. If something
    // goes wrong, m_world will remain NULL and errMsg will contain some info
    // about what happened.
    b2dJson json;
    std::string errMsg;
    m_world = json.readFromFile([fullpath UTF8String], errMsg);
    
    if ( m_world ) {
        CCLOG(@"Loaded JSON ok");
        
        // Set up a debug draw so we can see what's going on in the physics engine.
        // The scale for rendering will be handled by the layer scale, which will affect
        // the entire layer, so we keep the PTM ratio here to 1 (ie. one physics unit
        // will be one pixel)
        //m_debugDraw = new GLESDebugDraw( 1 );
        // oh wait... actually, this should be 2 if using retina
        m_debugDraw = new GLESDebugDraw( [[CCDirector sharedDirector] contentScaleFactor] );
        
        // set the debug draw to show fixtures, and let the world know about it
        m_debugDraw->SetFlags( b2Draw::e_shapeBit );
        m_world->SetDebugDraw(m_debugDraw);

        // This body is needed if we want to use a mouse joint to drag things around.
        b2BodyDef bd;
        m_mouseJointGroundBody = m_world->CreateBody( &bd );
        
        [self afterLoadProcessing:&json];
    }
    else
        CCLOG([NSString stringWithUTF8String:errMsg.c_str()]); //if this warning bothers you, turn off "Typecheck calls to printf/scanf" in the project build settings
}


// Override this in subclasses to do some extra processing (eg. acquire references
// to named bodies, joints etc) after the world has been loaded, and while the b2dJson
// information is still available.
-(void)afterLoadProcessing:(b2dJson*)json
{
    
}

// This method should undo anything that was done by the loadWorld and afterLoadProcessing
// methods, and return to a state where loadWorld can safely be called again.
-(void)clear
{
    if ( m_world ) {
        CCLOG(@"Deleting Box2D world");
        delete m_world;
    }
    
    if ( m_debugDraw )
        delete m_debugDraw;
    
    m_world = NULL;
    m_mouseJoint = NULL;
    m_mouseJointGroundBody = NULL;
}


// Standard ObjC method
- (void) dealloc
{
    [self unschedule: @selector(tick:)];
    [self clear];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
}


// Standard Cocos2d method, just step the physics world with fixed time step length
-(void) tick: (ccTime) dt
{
    if ( m_world )
        m_world->Step(1/60.0, 8, 3);
}


// Standard Cocos2d method
-(void) draw
{
    if ( !m_world )
        return;
    
    glDisable(GL_TEXTURE_2D);
//	glDisableClientState(GL_COLOR_ARRAY);
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
    // Use debug draw to show fixtures
	m_world->DrawDebugData();
    
    // Draw mouse joint line
    if ( m_mouseJoint ) {
        b2Vec2 p1 = m_mouseJoint->GetAnchorB();
        b2Vec2 p2 = m_mouseJoint->GetTarget();
        
        b2Color c;
        c.Set(0.0f, 1.0f, 0.0f);
        m_debugDraw->DrawPoint(p1, 4.0f, c);
        m_debugDraw->DrawPoint(p2, 4.0f, c);
        
        c.Set(0.8f, 0.8f, 0.8f);
        m_debugDraw->DrawSegment(p1, p2, c);
    }
	
	glEnable(GL_TEXTURE_2D);
//	glEnableClientState(GL_COLOR_ARRAY);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}


// Converts a position in screen pixels to a location in the physics world
-(b2Vec2) screenToWorld:(CGPoint)screenPos
{
    screenPos.y = [[CCDirector sharedDirector] winSize].height - screenPos.y;
    
    CGPoint layerOffset = [self position];
    screenPos.x -= layerOffset.x;
    screenPos.y -= layerOffset.y;
    
    float layerScale = [self scale];
    
    return b2Vec2(screenPos.x / layerScale, screenPos.y / layerScale);
}


// Converts a location in the physics world to a position in screen pixels
-(CGPoint) worldToScreen:(b2Vec2)worldPos
{
    worldPos *= [self scale];
    CGPoint layerOffset = [self position];
    CGPoint p = CGPointMake(worldPos.x + layerOffset.x, worldPos.y + layerOffset.y);
    p.y = [[CCDirector sharedDirector] winSize].height - p.y;
    return p;
}


// Standard Cocos2d method. Here we make a mouse joint to drag dynamic bodies around.
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Only make one mouse joint at a time!
    if ( m_mouseJoint )
        return;
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint screenPos = [touch locationInView:[touch view]];    
    b2Vec2 worldPos = [self screenToWorld:screenPos];
    
    // Make a small box around the touched point to query for overlapping fixtures
    b2AABB aabb;
    b2Vec2 d(0.001f, 0.001f);
    aabb.lowerBound = worldPos - d;
    aabb.upperBound = worldPos + d;
    
    // Query the world for overlapping fixtures (the TouchDownQueryCallback simply
    // looks for any fixture that contains the touched point)
    TouchDownQueryCallback callback(worldPos);
    m_world->QueryAABB(&callback, aabb);
    
    // Check if we found something, and it was a dynamic body (can't drag static bodies)
    if (callback.m_fixture && callback.m_fixture->GetBody()->GetType() == b2_dynamicBody)
    {
        // The touched point was over a dynamic body, so make a mouse joint
        b2Body* body = callback.m_fixture->GetBody();
        b2MouseJointDef md;
        md.bodyA = m_mouseJointGroundBody;
        md.bodyB = body;
        md.target = worldPos;
        md.maxForce = 2500.0f * body->GetMass();
        m_mouseJoint = (b2MouseJoint*)m_world->CreateJoint(&md);
        body->SetAwake(true);
    }
}


// Standard Cocos2d method
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [touches count] > 1 ) {
        // At least two touches are moving at the same time. Take the first two
        // touches and use their movement to pan and zoom the scene.
        UITouch *touch0 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch1 = [[touches allObjects] objectAtIndex:1];
        CGPoint screenPos0 = [touch0 locationInView:[touch0 view]];
        CGPoint screenPos1 = [touch1 locationInView:[touch1 view]];
        CGPoint previousScreenPos0 = [touch0 previousLocationInView:[touch0 view]];
        CGPoint previousScreenPos1 = [touch1 previousLocationInView:[touch1 view]];
        
        CGPoint layerOffset = [self position];
        float layerScale = [self scale];
        
        // Panning
        // The midpoint is the point exactly between the two touches. The scene
        // should move by the same distance that the midpoint just moved.
        CGPoint previousMidpoint = ccpMidpoint(previousScreenPos0, previousScreenPos1);
        CGPoint currentMidpoint = ccpMidpoint(screenPos0, screenPos1);
        CGPoint moved = ccpSub(currentMidpoint, previousMidpoint);
        moved.y *= -1;
        layerOffset = ccpAdd(layerOffset, moved);

        // Zooming
        // The scale should change by the same ratio as the previous and current
        // distance between the two touches. Unfortunately simply setting the scale
        // has the side-effect of moving the view center. We want to keep the midpoint
        // of the touches unchanged by scaling, so we need to look at what it was
        // before we scale...
        b2Vec2 worldCenterBeforeScaling = [self screenToWorld:currentMidpoint];
        
        // ... then perform the scale change...
        float previousSeparation = ccpDistance(previousScreenPos0, previousScreenPos1);
        float currentSeparation = ccpDistance(screenPos0, screenPos1);
        if ( previousSeparation > 10 ) { //just in case, prevent divivde by zero
            layerScale *= currentSeparation / previousSeparation;
            [self setScale:layerScale];
        }

        // ... now check how that affected the midpoint, and cancel out the change:
        CGPoint screenCenterAfterScaling = [self worldToScreen:worldCenterBeforeScaling];
        CGPoint movedCausedByScaling = ccpSub(screenCenterAfterScaling, currentMidpoint);
        movedCausedByScaling.y *= -1;
        layerOffset = ccpSub(layerOffset, movedCausedByScaling);
        
        [self setPosition:layerOffset];        
    }
    else if ( m_mouseJoint ) {
        // Only one touch is moving. Assume it is the touch for the mouse joint
        // and move the target of the mouse joint accordingly (this is not quite
        // correct because the touch may not be the one for the mouse joint).
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint screenPos = [touch locationInView:[touch view]];        
        b2Vec2 worldPos = [self screenToWorld:screenPos];
        
        m_mouseJoint->SetTarget(worldPos);
    }
}


// Standard Cocos2d method
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Destroy the mouse joint if it exists - note that we are not checking
    // if this touch was actually the touch that created the mouse joint, so
    // any touch end event will destroy it.
    if ( m_mouseJoint )
        m_world->DestroyJoint(m_mouseJoint);
    m_mouseJoint = NULL;
}


// Standard Cocos2d method
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self ccTouchesEnded:touches withEvent:event];
}

@end















