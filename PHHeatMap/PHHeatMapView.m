//
//  PHHeatMapView.m
//  PHHeatMap
//
//  Created by Phineas Lue on 5/27/14.
//  Copyright (c) 2014 Phineas Lue. All rights reserved.
//

#import "PHHeatMapView.h"

#define MAX_ALPHA_INT 180

#define EFFECT_RADIUS 120

#define SHADOW_BIAS 1500

#define SHADOW_BLUR 48.

@interface PHHeatMapView (){
    UInt8 *_pallete;
}

@property (nonatomic, readonly) UInt8 *pallete;

@end

@implementation PHHeatMapView

-(void)dealloc{
    free(self.pallete);
}

-(id)initWithFrame:(CGRect)frame andDataPoints:(NSDictionary *)pointDict{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.pointDict = pointDict;
    }
    
    return self;
}

-(void)setPointDict:(NSDictionary *)pointDict{
    if (_pointDict != pointDict) {
        _pointDict = pointDict;
        
        //when assgin new data points, should redraw the heatmap
        [self setNeedsDisplay];
    }
}

/*
 * In drawRect, we create a bitmap context first.
 * Then for each point, get the weight (relative to max value) and draw shadow (just alpha).
 * The shadow is just a way to deliver the data point effect to neihbor points with different weights.
 * Then we iterate the whole bitmap and apply corresponding color to each pixel due to their alpha 
 * value, which represents the extent of point.
 */
-(void)drawRect:(CGRect)rect{
    //If it is retina device, then the bitmap size should be double
    float scale = [[UIScreen mainScreen] scale];
    size_t pixelWidth = CGRectGetWidth(rect) * scale;
    size_t pixelHeight = CGRectGetHeight(rect) * scale;
    
    //creat bitmap context
    CGContextRef context = [self bitmapContextWithWidth:pixelWidth andHeight:pixelHeight];
    
    //get the max value in all points
    float maxValue = [[self.pointDict.allValues valueForKeyPath:@"@max.floatValue"] floatValue];
    
    //We are going to draw circles and actually utilize their shadows.
    //So the circles should be out of view rect, and thus invisible!
    //Although the circle is invisible, we should assgin not clear color to fill, otherwise
    //the shadow will be clear color.
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    //draw shadow for each point, thus deliver effect
    for (NSValue *coordinationValue in self.pointDict){
        
        //the point in bitmap
        CGPoint point = [self bitmapCoordinationFromUIViewCoordination:coordinationValue.CGPointValue
                                                                       inRect:rect];
        
        //the value for this point
        float pointValue = [[self.pointDict objectForKey:coordinationValue] floatValue];
        
        //weight is t
        float weight = pointValue / maxValue;
        
        //assign weight to shadow color alpha, so the alpha components in the shadow reflect
        //the influence of this data point
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(SHADOW_BIAS, SHADOW_BIAS),
                                    SHADOW_BLUR,
                                    [UIColor colorWithRed:0. green:0. blue:0. alpha:weight].CGColor);
        
        CGContextBeginPath(context);
        
        CGContextAddArc(context,
                        point.x - SHADOW_BIAS,
                        point.y - SHADOW_BIAS,
                        EFFECT_RADIUS,
                        0,
                        M_PI * 2,
                        0);
        
        CGContextClosePath(context);
        
        CGContextFillPath(context);
    }
    
    //the extent of each point (the shadow alpha value) is already assigned, then we should
    //colorize the bitmap to show the heat distribution
    //first get the bitmap data
    UInt8 *data = CGBitmapContextGetData(context);
    
    //iterate all bitmap pixels, int this case alpha component of each point
    for (int i = 3; i <= pixelWidth * pixelHeight * 4 - 1; i += 4) {
        //the heat degree of this point
        NSInteger heat = data[i];
        
        if (heat == 0) {
            //purely cool, keep this point clear
            continue;
        }
        
        //the byte offset of pallete color point which will be used to colorize this point
        NSInteger palleteOffset = heat * 4;
        
        //set alpha value first, should be bounded above to make heat map transparent
        data[i] = MIN(heat, MAX_ALPHA_INT);
        
        //get alpha scale to multiply the RGB value, because the bitmap is AlphaPremultiplied
        float alphaScale = (float)data[i] / 255.;
        
        //red
        data[i-3] = self.pallete[palleteOffset] * alphaScale;
        //green
        data[i-2] = self.pallete[palleteOffset+1] * alphaScale;
        //blue
        data[i-1] = self.pallete[palleteOffset+2] * alphaScale;
    }
    
    [[UIImage imageWithCGImage:CGBitmapContextCreateImage(context)] drawInRect:rect];
    
    //release bitmap context
    CGContextRelease(context);
    free(data);
}

-(CGContextRef)bitmapContextWithWidth:(NSInteger)width andHeight:(NSInteger)height{
    //RGBA per pixel
    size_t bytesPerRow =  width * 4;
    
    UInt8 *data = calloc(sizeof(UInt8), bytesPerRow * height);
    
    return CGBitmapContextCreate(data,
                                 width,
                                 height,
                                 8,
                                 bytesPerRow,
                                 CGColorSpaceCreateDeviceRGB(),
                                 (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
}

-(UInt8 *)pallete{
    //lazy initialized
    if (!_pallete) {
        //create gradient with the colorize scheme, which is defined in colorScheme.json
        //basically the scheme is Blue -> Red
        NSDictionary *colorSchemeDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colorScheme" ofType:@"json"]] options:0 error:NULL];
        
        NSInteger count;
        CGFloat *locations, *components;
        
        [self parseColorScheme:colorSchemeDict withComponents:&components locations:&locations andCount:&count];
        
        //create gradient
        CGGradientRef gradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), components, locations, count);
        
        //draw gradient in one 1 x 256 bitmap, and the result is a 256-length pixel array to represent
        //different heat degree increasingly
        CGContextRef context = [self bitmapContextWithWidth:1 andHeight:256];
        //should draw from high bitmap location to low!
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 255), CGPointMake(0, 0), 0);
        
        //the 256-length pixel array
        _pallete = CGBitmapContextGetData(context);
        
        //
        CGContextRelease(context);
        CGGradientRelease(gradient);
        free(locations);
        free(components);
    }
    
    return _pallete;
}

-(void)parseColorScheme:(NSDictionary*)colorSchemeDict
         withComponents:(CGFloat**)components
              locations:(CGFloat**)locations
               andCount:(NSInteger*)count{
    
    *count = [colorSchemeDict[@"locations"] count];
    
    *locations = malloc( sizeof(CGFloat) * (*count) );
    *components = malloc( sizeof(CGFloat) * (*count) * 4 );
    
    for (int i=0; i<=*count-1; i++) {
        (*locations)[i] = [[colorSchemeDict[@"locations"] objectAtIndex:i] floatValue];
    }
    
    for (int i=0; i<=*count*4-1; i++) {
        (*components)[i] = [[colorSchemeDict[@"components"] objectAtIndex:i] floatValue];
    }
}

-(CGPoint)bitmapCoordinationFromUIViewCoordination:(CGPoint)point inRect:(CGRect)rect{
    point.y = CGRectGetHeight(rect) - point.y;
    
    float scale = [[UIScreen mainScreen] scale];
    
    point.x *= scale;
    point.y *= scale;
    
    return point;
}

@end
