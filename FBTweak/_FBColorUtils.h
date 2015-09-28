/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

typedef struct { CGFloat red, green, blue, alpha; } RGB;
typedef struct { CGFloat hue, saturation, brightness, alpha; } HSB;
typedef struct { CGFloat hue, saturation, lightness, alpha; } HSL;
typedef struct { CGFloat cyan, magenta, yellow, key, alpha; } CMYK;
typedef struct { CGFloat lightness, a, b, alpha; } LAB;
typedef struct { CGFloat y, pb, pr, alpha; } YPBPR;
typedef struct { CGFloat x, y, z, alpha; } XYZ;

extern CGFloat const _FBRGBColorComponentMaxValue;
extern CGFloat const _FBLABLightnessColorComponentMaxValue;
extern CGFloat const _FBYPBPR_YColorComponentMaxValue;
extern CGFloat const _FBYPBPR_PBPRColorComponentMaxValue;
extern CGFloat const _FBLABColorComponentMaxValue;
extern CGFloat const _FBXYZColorComponentMaxValue;
extern CGFloat const _FBAlphaComponentMaxValue;
extern CGFloat const _FBHSBColorComponentMaxValue;
extern CGFloat const _FBHSLColorComponentMaxValue;
extern CGFloat const _FBCMYKColorComponentMaxValue;
extern NSUInteger const _FBRGBAColorComponentsSize;
extern NSUInteger const _FBHSBAColorComponentsSize;
extern NSUInteger const _FBHSLAColorComponentsSize;
extern NSUInteger const _FBCMYKAColorComponentsSize;
extern NSUInteger const _FBLABAColorComponentsSize;
extern NSUInteger const _FBYPBPRAColorComponentsSize;
extern NSUInteger const _FBXYZAColorComponentsSize;

typedef NS_ENUM(NSUInteger, _FBRGBColorComponent) {
  _FBRGBColorComponentRed,
  _FBRGBColorComponentGreed,
  _FBRGBColorComponentBlue,
  _FBRGBColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBHSBColorComponent) {
  _FBHSBColorComponentHue,
  _FBHSBColorComponentSaturation,
  _FBHSBColorComponentBrightness,
  _FBHSBColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBHSLColorComponent) {
  _FBHSLColorComponentHue,
  _FBHSLColorComponentSaturation,
  _FBHSLColorComponentLightness,
  _FBHSLColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBCMYKColorComponent) {
  _FBCMYKColorComponentCyan,
  _FBCMYKColorComponentMagenta,
  _FBCMYKColorComponentYellow,
  _FBCMYKColorComponentKey,
  _FBCMYKColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBLABColorComponent) {
  _FBLABColorComponentLightness,
  _FBLABColorComponentA,
  _FBLABColorComponentB,
  _FBLABColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBYPBPRColorComponent) {
  _FBYPBPRColorComponentY,
  _FBYPBPRColorComponentPb,
  _FBYPBPRColorComponentPr,
  _FBYPBPRColorComponentAlpha,
};

typedef NS_ENUM(NSUInteger, _FBXYZColorComponent) {
  _FBXYZColorComponentX,
  _FBXYZColorComponentY,
  _FBXYZColorComponentZ,
  _FBXYZColorComponentAlpha,
};

/**
  @abstract Converts an RGB color value to HSV.
  @discussion Assumes r, g, and b are contained in the set
      [0, 1] and returns h, s, and b in the set [0, 1].
  @param rgb   The rgb color values
  @return The hsb color values
 */
extern HSB _FBRGB2HSB(RGB rgb);

/**
  @abstract Converts an HSB color value to RGB.
  @discussion Assumes h, s, and b are contained in the set
      [0, 1] and returns r, g, and b in the set [0, 255].
  @param hsb The hsb color values
  @return The rgb color values
 */
extern RGB _FBHSB2RGB(HSB hsb);

/**
 @abstract Converts an RGB color value to HSL.
 @discussion Assumes r, g, and b are contained in the set
 [0, 1] and returns h, s, and l in its own range.
 @param rgb   The rgb color values
 @return The hsl color values
 */
extern HSL _FBRGB2HSL(RGB rgb);

/**
 @abstract Converts an HSL color value to RGB.
 @discussion Assumes h, s, and l are contained in its own range
 and returns r, g, and b in the set [0, 255].
 @param hsl The hsl color values
 @return The rgb color values
 */
extern RGB _FBHSL2RGB(HSL hsl);

/**
 @abstract Converts an RGB color value to CMYK.
 @discussion Assumes r, g, and b are contained in the set
 [0, 1] and returns c, m, y, and k in the set [0, 100].
 @param rgb   The rgb color values
 @return The cmyk color values
 */
extern CMYK _FBRGB2CMYK(RGB rgb);

/**
 @abstract Converts an CMYK color value to RGB.
 @discussion Assumes c, m, y, and k are contained in the set
 [0, 100] and returns r, g, and b in the set [0, 255].
 @param cmyk The cmyk color values
 @return The rgb color values
 */
extern RGB _FBCMYK2RGB(CMYK cmyk);

/**
 @abstract Converts an RGB color value to LAB.
 @discussion Assumes r, g, and b are contained in the set
 [0, 1] and returns l, a, and b its own set range.
 @param rgb   The rgb color values
 @return The lab color values
 */
extern LAB _FBRGB2LAB(RGB rgb);

/**
 @abstract Converts an LAB color value to RGB.
 @discussion Assumes l, a, and b are contained in its own range
 and returns r, g, and b in the set [0, 255].
 @param hsb The lab color values
 @return The rgb color values
 */
extern RGB _FBLAB2RGB(LAB lab);

/**
 @abstract Converts an RGB color value to HD YpbPr.
 @discussion Assumes r, g, and b are contained in the set
 [0, 1] and y is [0 255] and pb, pr are in set [-127 +127].
 @param rgb   The rgb color values
 @return The ypbpr color values
 */
extern YPBPR _FBRGB2YPbPr(RGB rgb);

/**
 @abstract Converts an HD YPBPR color value to RGB.
 @discussion returns r, g, and b in the set [0, 255].
 @param ypbpr The ypbpr color values
 @return The rgb color values
 */
extern RGB _FBYPbPr2RGB(YPBPR ypbpr);

/**
 @abstract Converts an RGB color value to XYZ.
 @discussion Assumes r, g, and b are contained in the set
 [0, 1] and returns x, y, and z in the set [0, 100].
 @param rgb   The rgb color values
 @return The xyz color values
 */
extern XYZ _FBRGB2XYZ(RGB rgb);

/**
 @abstract Converts an XYZ color value to RGB.
 @discussion Assumes x, y, and z are contained in the set
 [0, 100] and returns r, g, and b in the set [0, 255].
 @param xyz The hsb color values
 @return The rgb color values
 */
extern RGB _FBXYZ2RGB(XYZ xyz);

/**
  @abstract Returns the rgb values of the color components.
  @param color The color value.
  @return The values of the color components (including alpha).
 */
extern RGB _FBRGBColorComponents(UIColor *color);

/**
  @abstract Returns the color wheel's hue value according to the position, color wheel's center and radius.
  @param position The position in the color wheel.
  @param center The color wheel's center.
  @param radius The color wheel's radius.
  @return The hue value.
 */
extern CGFloat _FBGetColorWheelHue(CGPoint position, CGPoint center, CGFloat radius);

/**
  @abstract Returns the color wheel's saturation value according to the position, color wheel's center and radius.
  @param position The position in the color wheel.
  @param center The color wheel's center.
  @param radius The color wheel's radius.
  @return The saturation value.
 */
extern CGFloat _FBGetColorWheelSaturation(CGPoint position, CGPoint center, CGFloat radius);

/**
  @abstract Creates the color wheel with specified diameter.
  @param diameter The color wheel's diameter.
  @return The color wheel image.
 */
extern CGImageRef _FBCreateColorWheelImage(CGFloat diameter);
