//
//  UIImage+ColorAtPixel.m
//  WeatherMap
//
//  Created by Boris Yurkevich on 09/09/2015.
//  Copyright (c) 2015 Boris Yurkevich. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

#import "UIImage+ColorAtPixel.h"

@implementation UIImage (ColorAtPixel)

- (UIColor *)colorForTemperature:(CGFloat)temperature{
	
	CGFloat xCoord = (temperature/100)*(self.size.width-1);
	CGFloat yCoord = self.size.height/2;
	
	//coordinates for 1 pixel on the image computed from the temperature value
	CGPoint point = CGPointMake(xCoord,yCoord);
	
	// Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
	// Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
	NSInteger pointX = trunc(point.x);
	NSInteger pointY = trunc(point.y);
	CGImageRef cgImage = self.CGImage;
	NSUInteger width = CGImageGetWidth(cgImage);
	NSUInteger height = CGImageGetHeight(cgImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	int bytesPerPixel = 4;
	int bytesPerRow = bytesPerPixel * 1;
	NSUInteger bitsPerComponent = 8;
	unsigned char pixelData[4] = { 0, 0, 0, 0 };
	CGContextRef context = CGBitmapContextCreate(pixelData,
												 1,
												 1,
												 bitsPerComponent,
												 bytesPerRow,
												 colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	// Draw the pixel we are interested in onto the bitmap context
	CGContextTranslateCTM(context, -pointX, -pointY);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
	CGContextRelease(context);
	
	// Convert color values [0..255] to floats [0.0..1.0]
	CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
	CGFloat green = (CGFloat)pixelData[1] / 255.0f;
	CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
	CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
