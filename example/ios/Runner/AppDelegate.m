#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "PMManager.h"
#import "ResultHandler.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
        
        PMManager *manager = [PMManager new];
        long long ret = [manager getAssetLength:@"4C6A2FE8-49FE-4B30-BFB2-85FAAF35E91E/L0/001"];
        NSLog(@"file size: %lld", ret);
        
        [manager calculateAssetSimilarity:@"DB97943B-DF48-4BF3-B70A-53A71F61BC47/L0/001" assetIdB:@"4C6A2FE8-49FE-4B30-BFB2-85FAAF35E91E/L0/001" resultHandler:[ResultHandler handlerWithResult:^(id  _Nullable result) {
            NSLog(@"image similarity: %@", result);
        }]];
    });
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
