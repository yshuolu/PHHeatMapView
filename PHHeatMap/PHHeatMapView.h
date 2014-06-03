//
//  PHHeatMapView.h
//  PHHeatMap
//
//  Created by Phineas Lue on 5/27/14.
//  Copyright (c) 2014 Phineas Lue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHHeatMapView : UIView

/*
 * The dictionary whose key is point coordination and value is extent.
 * Key should be NSValue generated from CGPoint. 
 */
 
@property (nonatomic, strong) NSDictionary *pointDict;

-(id)initWithFrame:(CGRect)frame andDataPoints:(NSDictionary*)pointDict;

@end
