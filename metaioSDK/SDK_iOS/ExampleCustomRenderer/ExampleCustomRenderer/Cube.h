#import <Foundation/Foundation.h>
#import <GLKit/GLKMatrix4.h>

@interface Cube : NSObject

- (void)draw:(GLKMatrix4)modelViewProjectionMatrix;

@end
