#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// from: https://github.com/glfw/glfw/issues/1024

NS_ASSUME_NONNULL_BEGIN

@interface GLFWCustomDelegate : NSObject
+ (void)load; // load is called before even main() is run (as part of objc class registration)
@end

NS_ASSUME_NONNULL_END
