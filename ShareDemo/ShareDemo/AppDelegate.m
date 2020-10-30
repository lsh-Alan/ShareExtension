//
//  AppDelegate.m
//  ShareDemo
//
//  Created by Alan on 2020/10/29.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    ViewController *vc = [[ViewController alloc] init];
    
    self.window.rootViewController = vc;
    
    
    
    
    
    return YES;
}



- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSLog(@"   ===========app被拉起");
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.alan.ShareDemo"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches"];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:containerURL.path]) {
        NSString *path = containerURL.path;
        NSArray *array = [self allFilesAtPath:path];
        for (NSString *str  in array) {
            
            NSData *data = [NSData dataWithContentsOfFile:str];
            NSLog(@"============地址%@\n文件%@\n",str,data);
        }
    }
    
    
    return YES;
}



-(UIViewController*) findBestViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side （A container that is similar to UINavigationViewController and tabbarViewController, difference is their different layout, UISplitViewController much used in the IPad device）
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
        
    } else {
        
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}

- (UIViewController*) currentViewController {
    
    // Find best view controller
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
    
}

- (NSArray*) allFilesAtPath:(NSString*) dirString {
       NSMutableArray* array = [NSMutableArray array];

       NSFileManager* fileMgr = [NSFileManager defaultManager];

       NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];

       for (NSString* fileName in tempArray) {
           BOOL flag = YES;

           NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];

           if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
               if (!flag) {
                   [array addObject:fullPath];

               }

           }

       }

       return array;

   }






@end
