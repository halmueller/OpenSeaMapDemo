//
//  TTTGeocoordinateFormatter.h
//  SkunkTracker Mac
//
//  Created by Hal Mueller on 5/23/14.
//  Copyright (c) 2014 Mobile Geographics. All rights reserved.
//

#import "TTTLocationFormatter.h"

typedef NS_ENUM(NSUInteger, TTTGeocoordinateFormatterStyle) {
    TTTGeocoordinateDecimalDegreesStyle = 0,       // e.g. N 30.2669°
    TTTGeocoordinateDegreesDecimalMinutesStyle,    // e.g. N 30°16.0'
    TTTGeocoordinateDegreesMinutesSecondsStyle,    // e.g. N 30°16'01.0"
};


@interface TTTGeocoordinateFormatter : TTTLocationFormatter
@property (nonatomic, assign) TTTGeocoordinateFormatterStyle geocoordinateStyle;


- (NSString *)stringFromDegrees:(CLLocationDegrees)rawDegrees isLongitude:(BOOL)isLongitude;
+ (instancetype)decimalDegreesGeocoordinateFormatter;
+ (instancetype)degreesMinutesGeocoordinateFormatter;
+ (instancetype)degreesMinutesSecondsGeocoordinateFormatter;

@end
