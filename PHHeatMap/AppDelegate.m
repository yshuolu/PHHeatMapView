//
//  AppDelegate.m
//  PHHeatMap
//
//  Created by Phineas Lue on 5/27/14.
//  Copyright (c) 2014 Phineas Lue. All rights reserved.
//

#import "AppDelegate.h"
#import "PHHeatMapView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test.png"]];
    
    backgroundView.frame = [[UIScreen mainScreen] applicationFrame];
    
    backgroundView.backgroundColor = [UIColor clearColor];
    
    backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.window addSubview:backgroundView];
    
    NSDictionary *testDict = @{
                [NSValue valueWithCGPoint:CGPointMake(150, 200)]: @100,
                [NSValue valueWithCGPoint:CGPointMake(150, 250)]: @140,
                [NSValue valueWithCGPoint:CGPointMake(200, 200)]: @140,
                [NSValue valueWithCGPoint:CGPointMake(200, 250)]: @140};
    
    self.heatmapView = [[PHHeatMapView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]andDataPoints:testDict];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setHeat:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    self.points = @[
                    [NSValue valueWithCGPoint:CGPointMake(100, 100)],
                    [NSValue valueWithCGPoint:CGPointMake(100, 200)],
                    [NSValue valueWithCGPoint:CGPointMake(100, 300)],
                    [NSValue valueWithCGPoint:CGPointMake(100, 400)],
                    [NSValue valueWithCGPoint:CGPointMake(100, 500)],
                    [NSValue valueWithCGPoint:CGPointMake(200, 100)],
                    [NSValue valueWithCGPoint:CGPointMake(200, 200)],
                    [NSValue valueWithCGPoint:CGPointMake(200, 300)],
                    [NSValue valueWithCGPoint:CGPointMake(200, 400)],
                    [NSValue valueWithCGPoint:CGPointMake(200, 500)]
                    ];
    
    [self.window addSubview:self.heatmapView];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)setHeat:(NSTimer*)timer{
    NSMutableDictionary *pointDict = [NSMutableDictionary dictionary];
    
    for (NSValue *point in self.points){
        [pointDict setObject:[NSNumber numberWithFloat:arc4random()%100] forKey:point];
    }
    
    self.heatmapView.pointDict = pointDict;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
