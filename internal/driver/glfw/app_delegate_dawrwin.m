#import "app_delegate_dawrwin.h"
#import <objc/runtime.h>

// part of your application
extern void forwardLoadMessage(char **, int len);

@implementation GLFWCustomDelegate

+ (void)load{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = objc_getClass("GLFWApplicationDelegate");

    [GLFWCustomDelegate swizzle:class src:@selector(application:openFile:) tgt:@selector(swz_application:openFile:)];
    [GLFWCustomDelegate swizzle:class src:@selector(application:openFiles:) tgt:@selector(swz_application:openFiles:)];
  });
}

+ (void) swizzle:(Class) original_c src:(SEL)original_s tgt:(SEL)target_s{
  Class target_c = [GLFWCustomDelegate class];
  Method originalMethod = class_getInstanceMethod(original_c, original_s);
  Method swizzledMethod = class_getInstanceMethod(target_c, target_s);

  BOOL didAddMethod =
  class_addMethod(original_c,
          original_s,
          method_getImplementation(swizzledMethod),
          method_getTypeEncoding(swizzledMethod));

  if (didAddMethod) {
    class_replaceMethod(original_c,
              target_s,
              method_getImplementation(originalMethod),
              method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}

- (BOOL)swz_application:(NSApplication *)sender openFile:(NSString *)filename{
  NSLog(@"Open file ... %s", filename.UTF8String); 
  //forwardLoadMessage(); //
  return YES;  
}

- (void)swz_application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames{
  int count = [filenames count];
  // https://stackoverflow.com/questions/3091251/objective-c-nsarray-to-c-array
  char **cargs = (char **) malloc(sizeof(char *) * (count + 1));
  int i;
  for(i = 0; i < count; i++) {
      NSString *s = [filenames objectAtIndex:i];
      const char *cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];
      int len = strlen(cstr);
      char *cstr_copy = (char *) malloc(sizeof(char) * (len + 1));
      strcpy(cstr_copy, cstr);
      cargs[i] = cstr_copy;
  }
  cargs[i] = NULL;
  forwardLoadMessage(cargs, [filenames count]);
}

@end
