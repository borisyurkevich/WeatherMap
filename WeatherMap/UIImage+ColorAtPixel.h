//
//  UIImage+ColorAtPixel.h
//  WeatherMap
//
//  Created by Boris Yurkevich on 09/09/2015.
//  Copyright (c) 2015 Boris Yurkevich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorAtPixel)
- (UIColor *)colorForTemperature:(CGFloat)temperature;
@end
