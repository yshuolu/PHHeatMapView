//
//  AppDelegate.h
//  PHHeatMap
//
//  Created by Phineas Lue on 5/27/14.
//  Copyright (c) 2014 Phineas Lue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHHeatMapView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSArray *points;

@property (nonatomic, strong) PHHeatMapView *heatmapView;

@end
