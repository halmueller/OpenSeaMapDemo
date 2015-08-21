//: Playground - noun: a place where people can play

import UIKit

let numberFormatter = NSNumberFormatter()
numberFormatter

/*
result.numberFormatter.usesSignificantDigits = NO;
result.numberFormatter.minimumIntegerDigits = 5;
result.numberFormatter.maximumIntegerDigits = 5;
result.numberFormatter.paddingCharacter = @"0";
result.numberFormatter.minimumFractionDigits = 2;
result.numberFormatter.maximumFractionDigits = 3;
*/

numberFormatter.usesSignificantDigits = false
numberFormatter.minimumIntegerDigits = 2
numberFormatter.maximumIntegerDigits = 2
numberFormatter.minimumFractionDigits = 1
numberFormatter.maximumFractionDigits = 1

numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
numberFormatter.maximumSignificantDigits

numberFormatter.stringFromNumber(15.2)
numberFormatter.stringFromNumber(5.2)
numberFormatter.stringFromNumber(15.1237)
numberFormatter.stringFromNumber(165.1237)
numberFormatter.stringFromNumber(15)
numberFormatter.stringFromNumber(5.1237)

numberFormatter.stringFromNumber(5.4)

//import MapKit
////import OpenSeaMapOverlay
//let foo = OpenSeaMapOverlay()
//foo.URLTemplate
