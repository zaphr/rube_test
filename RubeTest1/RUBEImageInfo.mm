//  Author: Chris Campbell - www.iforce2d.net
//  -----------------------------------------
//
//  RUBEImageInfo
//
//  See header file for description.
//

#import "RUBEImageInfo.h"

@implementation RUBEImageInfo

// Nothing much to see here. Just make sure the body starts as NULL.
-(id)init
{
    if( (self=[super init])) {
        body = NULL;
	}
	return self;
}

@end
