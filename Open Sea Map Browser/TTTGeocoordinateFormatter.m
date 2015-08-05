//
//  TTTGeocoordinateFormatter.m
//  SkunkTracker Mac
//
//  Created by Hal Mueller on 5/23/14.
//  Copyright (c) 2014 Mobile Geographics. All rights reserved.
//

#import "TTTGeocoordinateFormatter.h"

static double const kTTTMinutesPerDegree = 60.0;
static double const kTTTSecondsPerMinute = 60.0;
NSString * const kTTTRoundingOverflowPrefix = @"60";
NSString * const kTTTDegreesSymbol = @"°";
NSString * const kTTTArcMinutesSymbol = @"'";
NSString * const kTTTArcSecondsSymbol = @"\"";

@implementation TTTGeocoordinateFormatter

@synthesize geocoordinateStyle = _geocoordinateStyle;

- (id)init {
    if (self = [super init]) {
        _geocoordinateStyle = TTTGeocoordinateDecimalDegreesStyle;
    }
    return self;
}

+ (instancetype)decimalDegreesGeocoordinateFormatter
{
    TTTGeocoordinateFormatter *result = [[self class] new];
    result.geocoordinateStyle = TTTGeocoordinateDecimalDegreesStyle;
    result.numberFormatter.usesSignificantDigits = NO;
    result.numberFormatter.minimumFractionDigits = 0;
    result.numberFormatter.maximumFractionDigits = 4;
    return result;
}

+ (instancetype)degreesMinutesGeocoordinateFormatter
{
    TTTGeocoordinateFormatter *result = [[self class] new];
    result.geocoordinateStyle = TTTGeocoordinateDegreesDecimalMinutesStyle;
//    result.numberFormatter.formatWidth = 4;
    result.numberFormatter.usesSignificantDigits = NO;
    result.numberFormatter.minimumIntegerDigits = 2;
    result.numberFormatter.maximumIntegerDigits = 2;
    result.numberFormatter.paddingCharacter = @"0";
    result.numberFormatter.minimumFractionDigits = 1;
    result.numberFormatter.maximumFractionDigits = 1;
    return result;
}

+ (instancetype)degreesMinutesSecondsGeocoordinateFormatter
{
    TTTGeocoordinateFormatter *result = [[self class] new];
    result.geocoordinateStyle = TTTGeocoordinateDegreesMinutesSecondsStyle;
    result.numberFormatter.usesSignificantDigits = NO;
    result.numberFormatter.minimumIntegerDigits = 2;
    result.numberFormatter.maximumIntegerDigits = 2;
    result.numberFormatter.minimumFractionDigits = 2;
    result.numberFormatter.maximumFractionDigits = 2;
    return result;
}

- (NSString *)stringFromDegrees:(CLLocationDegrees)rawDegrees isLongitude:(BOOL)isLongitude
{
    NSString *hemisphere;
    if (isLongitude) {
        if (rawDegrees >= 0) {
            hemisphere = NSLocalizedStringFromTable(@"E", @"FormatterKit", @"East Direction Abbreviation");
        }
        else {
            hemisphere = NSLocalizedStringFromTable(@"W", @"FormatterKit", @"West Direction Abbreviation");
        }
    }
    else {
        if (rawDegrees >= 0) {
            hemisphere = NSLocalizedStringFromTable(@"N", @"FormatterKit", @"North Direction Abbreviation");
        }
        else {
            hemisphere = NSLocalizedStringFromTable(@"S", @"FormatterKit", @"South Direction Abbreviation");
        }
    }
    double absoluteDoubleDegrees = fabs(rawDegrees);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
    NSUInteger integerDegrees = absoluteDoubleDegrees;
#pragma clang diagnostic pop
    double doubleMinutes = (absoluteDoubleDegrees - integerDegrees) * kTTTMinutesPerDegree;
    switch (self.geocoordinateStyle) {
        case TTTGeocoordinateDecimalDegreesStyle:
            return [NSString stringWithFormat:@"%@ %@%@", hemisphere, [self.numberFormatter stringFromNumber:@(absoluteDoubleDegrees)], kTTTDegreesSymbol];
        case TTTGeocoordinateDegreesDecimalMinutesStyle: {
            NSString *minutesString = [self.numberFormatter stringFromNumber:@(doubleMinutes)];
            // We can end up with, say, 60.0 for the minutes value if we try to round 59.99 minutes.
            if ([minutesString hasPrefix:kTTTRoundingOverflowPrefix]) {
                minutesString = [self.numberFormatter stringFromNumber:@0];
                integerDegrees++;
            }
            if (isLongitude) {
                return [NSString stringWithFormat:@"%@ %03zd%@%@%@", hemisphere, integerDegrees, kTTTDegreesSymbol, minutesString, kTTTArcMinutesSymbol];
            }
            else {
                return [NSString stringWithFormat:@"%@ %02zd%@%@%@", hemisphere, integerDegrees, kTTTDegreesSymbol, minutesString, kTTTArcMinutesSymbol];
            }
        }
        case TTTGeocoordinateDegreesMinutesSecondsStyle: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
            NSUInteger integerMinutes = doubleMinutes;
#pragma clang diagnostic pop
            double doubleSeconds = (doubleMinutes - integerMinutes) * kTTTSecondsPerMinute;
            NSString *secondsString = [self.numberFormatter stringFromNumber:@(doubleSeconds)];
            // the same gotcha for minutesString starting with 60 can bite us here for secondsString
            if ([secondsString hasPrefix:kTTTRoundingOverflowPrefix]) {
                secondsString = [self.numberFormatter stringFromNumber:@0];
                if (integerMinutes < (kTTTMinutesPerDegree - 1)) {
                    integerMinutes++;
                }
                else {
                    integerMinutes = 0;
                    integerDegrees++;
                }
            }
            if (isLongitude) {
                return [NSString stringWithFormat:@"%@ %03zd%@%02zd%@%@%@", hemisphere, integerDegrees, kTTTDegreesSymbol, integerMinutes, kTTTArcMinutesSymbol, secondsString, kTTTArcSecondsSymbol];
            }
            else {
                return [NSString stringWithFormat:@"%@ %02zd%@%02zd%@%@%@", hemisphere, integerDegrees, kTTTDegreesSymbol, integerMinutes, kTTTArcMinutesSymbol, secondsString, kTTTArcSecondsSymbol];
            }
        }
    }
    return nil;
}

- (NSString *)stringFromCoordinate:(CLLocationCoordinate2D)coordinate {
    return [NSString stringWithFormat:@"%@, %@", [self stringFromDegrees:coordinate.latitude isLongitude:NO], [self stringFromDegrees:coordinate.longitude isLongitude:YES]];
}
@end
