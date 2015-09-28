/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorUtils.h"

CGFloat const _FBRGBColorComponentMaxValue = 255.0f;
CGFloat const _FBLABLightnessColorComponentMaxValue = 100.0f;
CGFloat const _FBLABColorComponentMaxValue = 128.0f;
CGFloat const _FBYPBPR_YColorComponentMaxValue = 255.0f;
CGFloat const _FBYPBPR_PBPRColorComponentMaxValue = 127.0f;
CGFloat const _FBXYZColorComponentMaxValue = 100.0f;
CGFloat const _FBAlphaComponentMaxValue = 100.0f;
CGFloat const _FBHSBColorComponentMaxValue = 1.0f;
CGFloat const _FBHSLColorComponentMaxValue = 1.0f;
CGFloat const _FBCMYKColorComponentMaxValue = 1.0f;
NSUInteger const _FBRGBAColorComponentsSize = 4;
NSUInteger const _FBHSBAColorComponentsSize = 4;
NSUInteger const _FBHSLAColorComponentsSize = 4;
NSUInteger const _FBCMYKAColorComponentsSize = 5;
NSUInteger const _FBLABAColorComponentsSize = 4;
NSUInteger const _FBYPBPRAColorComponentsSize = 4;
NSUInteger const _FBXYZAColorComponentsSize = 4;

extern HSB _FBRGB2HSB(RGB rgb)
{
  double rd = (double) rgb.red;
  double gd = (double) rgb.green;
  double bd = (double) rgb.blue;
  double max = fmax(rd, fmax(gd, bd));
  double min = fmin(rd, fmin(gd, bd));
  double h = 0, s, b = max;

  double d = max - min;
  s = max == 0 ? 0 : d / max;

  if (max == min) {
    h = 0; // achromatic
  } else {
    if (max == rd) {
      h = (gd - bd) / d + (gd < bd ? 6 : 0);
    } else if (max == gd) {
      h = (bd - rd) / d + 2;
    } else if (max == bd) {
      h = (rd - gd) / d + 4;
    }
    h /= 6;
  }

  return (HSB){.hue = h, .saturation = s, .brightness = b, .alpha = rgb.alpha};
}

extern RGB _FBHSB2RGB(HSB hsb)
{
  double r, g, b;

  int i = hsb.hue * 6;
  double f = hsb.hue * 6 - i;
  double p = hsb.brightness * (1 - hsb.saturation);
  double q = hsb.brightness * (1 - f * hsb.saturation);
  double t = hsb.brightness * (1 - (1 - f) * hsb.saturation);

  switch(i % 6){
    case 0: r = hsb.brightness, g = t, b = p; break;
    case 1: r = q, g = hsb.brightness, b = p; break;
    case 2: r = p, g = hsb.brightness, b = t; break;
    case 3: r = p, g = q, b = hsb.brightness; break;
    case 4: r = t, g = p, b = hsb.brightness; break;
    case 5: r = hsb.brightness, g = p, b = q; break;
  }

  return (RGB){.red = r, .green = g, .blue = b, .alpha = hsb.alpha};
}

extern HSL _FBRGB2HSL(RGB rgb)
{
  double r_percent = rgb.red;
  double g_percent = rgb.green;
  double b_percent = rgb.blue;
  
  double max_color = 0;
  if((r_percent >= g_percent) && (r_percent >= b_percent))
    max_color = r_percent;
  if((g_percent >= r_percent) && (g_percent >= b_percent))
    max_color = g_percent;
  if((b_percent >= r_percent) && (b_percent >= g_percent))
    max_color = b_percent;
  
  double min_color = 0;
  if((r_percent <= g_percent) && (r_percent <= b_percent))
    min_color = r_percent;
  if((g_percent <= r_percent) && (g_percent <= b_percent))
    min_color = g_percent;
  if((b_percent <= r_percent) && (b_percent <= g_percent))
    min_color = b_percent;
  
  double L = 0;
  double S = 0;
  double H = 0;
  
  L = (max_color + min_color)/2;
  
  if(max_color == min_color)
  {
    S = 0;
    H = 0;
  }
  else
  {
    if(L < .50)
      S = (max_color - min_color)/(max_color + min_color);
    else
      S = (max_color - min_color)/(2 - max_color - min_color);
    if(max_color == r_percent)
      H = (g_percent - b_percent)/(max_color - min_color);
    if(max_color == g_percent)
      H = 2 + (b_percent - r_percent)/(max_color - min_color);
    if(max_color == b_percent)
      H = 4 + (r_percent - g_percent)/(max_color - min_color);
  }
  S = (uint)(S*100);
  L = (uint)(L*100);
  H = H*60;
  if(H < 0)
    H += 360;
  H = (uint)H;
  
  return (HSL){.hue = H, .saturation = S, .lightness = L, .alpha = rgb.alpha};
}

extern RGB _FBHSL2RGB(HSL hsl)
{
  double v;
  double r,g,b;
  
  double h = hsl.hue / 360.0;
  double sl = hsl.saturation / 100.0;
  double l = hsl.lightness / 100.0;
  
  r = hsl.lightness;
  g = hsl.lightness;
  b = hsl.lightness;
  v = (l <= 0.5) ? (l * (1.0 + sl)) : (l + sl - l * sl);
  if (v > 0)
  {
    double m;
    double sv;
    int sextant;
    double fract, vsf, mid1, mid2;
    
    m = l + l - v;
    sv = (v - m ) / v;
    h *= 6.0;
    sextant = (int)h;
    fract = h - sextant;
    vsf = v * sv * fract;
    mid1 = m + vsf;
    mid2 = v - vsf;
    switch (sextant)
    {
      case 0: r = v; g = mid1; b = m; break;
      case 1: r = mid2; g = v; b = m; break;
      case 2: r = m; g = v; b = mid1; break;
      case 3: r = m; g = mid2; b = v; break;
      case 4: r = mid1; g = m; b = v; break;
      case 5: r = v; g = m; b = mid2; break;
    }
  }
  
  return (RGB){.red = (r * 255.0f), .green = (g * 255.0f), .blue = (b * 255.0f), .alpha = hsl.alpha};
}

extern CMYK _FBRGB2CMYK(RGB rgb)
{
  double R = rgb.red;
  double G = rgb.green;
  double B = rgb.blue;

  double K = 1 - MAX((MAX(R, G)), B);
  double C = (1 - R - K) / (1 - K);
  double M = (1 - G - K) / (1 - K);
  double Y = (1 - B - K) / (1 - K);
  
  return (CMYK){.cyan = C * 100, .magenta = M * 100, .yellow = Y * 100, .key = K * 100, .alpha = rgb.alpha};
}

extern RGB _FBCMYK2RGB(CMYK cmyk)
{
  double C = cmyk.cyan / 100;
  double M = cmyk.magenta / 100;
  double Y = cmyk.yellow / 100;
  double K = cmyk.key / 100;
  
  double R = 255 * (1 - C) * (1 - K);
  double G = 255 * (1 - M) * (1 - K);
  double B = 255 * (1 - Y) * (1 - K);
  
  return (RGB){.red = R, .green = G, .blue = B, .alpha = cmyk.alpha};
}

extern LAB _FBRGB2LAB(RGB rgb)
{
  float var_R = rgb.red;
  float var_G = rgb.green;
  float var_B = rgb.blue;
  
  if (var_R > 0.04045) var_R = pow(((var_R + 0.055) / 1.055), 2.4);
  else var_R = var_R / 12.92;
  if (var_G > 0.04045) var_G = pow(((var_G + 0.055) / 1.055), 2.4);
  else var_G = var_G / 12.92;
  if (var_B > 0.04045) var_B = pow(((var_B + 0.055) / 1.055), 2.4);
  else var_B = var_B / 12.92;
  
  var_R = var_R * 100.;
  var_G = var_G * 100.;
  var_B = var_B * 100.;
  
  float X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
  float Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
  float Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;
  
  float var_X = X / 95.047 ;
  float var_Y = Y / 100.000;
  float var_Z = Z / 108.883;
  
  if (var_X > 0.008856) var_X = pow(var_X , (1./3.));
  else var_X = (7.787 * var_X) + (16. / 116. );
  if (var_Y > 0.008856) var_Y = pow(var_Y , (1./3.));
  else var_Y = (7.787 * var_Y) + (16. / 116. );
  if (var_Z > 0.008856) var_Z = pow(var_Z , (1./3.));
  else var_Z = (7.787 * var_Z) + (16. / 116.);
  
  return (LAB) {.lightness = (116. * var_Y) - 16. , .a = 500. * (var_X - var_Y) , .b = 200. * (var_Y - var_Z), .alpha = rgb.alpha};
}

extern RGB _FBLAB2RGB(LAB lab)
{
  double l_s = lab.lightness;
  double a_s = lab.a;
  double b_s = lab.b;
  
  float var_Y = (l_s + 16.) / 116.;
  float var_X = a_s / 500. + var_Y;
  float var_Z = var_Y - b_s / 200.;
  
  if (pow(var_Y,3) > 0.008856) var_Y = pow(var_Y,3);
  else var_Y = (var_Y - 16. / 116.) / 7.787;
  if (pow(var_X,3) > 0.008856) var_X = pow(var_X,3);
  else var_X = (var_X - 16. / 116.) / 7.787;
  if (pow(var_Z,3) > 0.008856) var_Z = pow(var_Z,3);
  else var_Z = (var_Z - 16. / 116.) / 7.787;
  
  float X = 95.047 * var_X ;
  float Y = 100.000 * var_Y ;
  float Z = 108.883 * var_Z ;
  
  var_X = X / 100. ;
  var_Y = Y / 100. ;
  var_Z = Z / 100. ;
  
  float var_R = var_X *  3.2406 + var_Y * -1.5372 + var_Z * -0.4986;
  float var_G = var_X * -0.9689 + var_Y *  1.8758 + var_Z *  0.0415;
  float var_B = var_X *  0.0557 + var_Y * -0.2040 + var_Z *  1.0570;
  
  if (var_R > 0.0031308) var_R = 1.055 * pow(var_R , (1 / 2.4)) - 0.055;
  else var_R = 12.92 * var_R;
  if (var_G > 0.0031308) var_G = 1.055 * pow(var_G , (1 / 2.4)) - 0.055;
  else var_G = 12.92 * var_G;
  if (var_B > 0.0031308) var_B = 1.055 * pow(var_B , (1 / 2.4)) - 0.055;
  else var_B = 12.92 * var_B;
  
  return (RGB){.red = var_R * 255., .green = var_G * 255., .blue = var_B * 255., .alpha = lab.alpha};
}

extern YPBPR _FBRGB2YPbPr(RGB rgb)
{
  double R = rgb.red * 255.;
  double G = rgb.green * 255.;
  double B = rgb.blue * 255.;
  
  double Y = 0.213 * R + 0.715 * G + 0.072 * B;
  double Pb = -0.115 * R + -0.385 * G + 0.5 * B;
  double Pr = 0.5 * R + -0.454 * G + -0.046 * B;
  
  return (YPBPR){.y = Y, .pb = Pb, .pr = Pr, .alpha = rgb.alpha};
}

extern RGB _FBYPbPr2RGB(YPBPR ypbpr)
{
  double Y = ypbpr.y;
  double Pb = ypbpr.pb;
  double Pr = ypbpr.pr;
  
  double R = Y + 1.575 * Pr;
  double G = Y + -0.187 * Pb + -0.468 * Pr;
  double B = Y + 1.856 * Pb;
  
  return (RGB){.red = R, .green = G, .blue = B, .alpha = ypbpr.alpha};
}

extern XYZ _FBRGB2XYZ(RGB rgb)
{
  float var_R = rgb.red;
  float var_G = rgb.green;
  float var_B = rgb.blue;
  
  if (var_R > 0.04045) var_R = pow(((var_R + 0.055) / 1.055), 2.4);
  else var_R = var_R / 12.92;
  if (var_G > 0.04045) var_G = pow(((var_G + 0.055) / 1.055), 2.4);
  else var_G = var_G / 12.92;
  if (var_B > 0.04045) var_B = pow(((var_B + 0.055) / 1.055), 2.4);
  else var_B = var_B / 12.92;
  
  var_R = var_R * 100.;
  var_G = var_G * 100.;
  var_B = var_B * 100.;
  
  float X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
  float Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
  float Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;

  return (XYZ) {.x = X, .y = Y, .z = Z, .alpha = rgb.alpha};
}

extern RGB _FBXYZ2RGB(XYZ xyz)
{
  double var_X = xyz.x / 100;
  double var_Y = xyz.y / 100;
  double var_Z = xyz.z / 100;
  
  double var_R = var_X *  3.2406 + var_Y * -1.5372 + var_Z * -0.4986;
  double var_G = var_X * -0.9689 + var_Y *  1.8758 + var_Z *  0.0415;
  double var_B = var_X *  0.0557 + var_Y * -0.2040 + var_Z *  1.0570;
  
  if (var_R > 0.0031308) var_R = 1.055 * (pow(var_R, ( 1 / 2.4))) - 0.055;
  else var_R = 12.92 * var_R;
  if (var_G > 0.0031308) var_G = 1.055 * (pow(var_G, ( 1 / 2.4 ))) - 0.055;
  else var_G = 12.92 * var_G;
  if (var_B > 0.0031308) var_B = 1.055 * (pow(var_B, ( 1 / 2.4 ))) - 0.055;
  else var_B = 12.92 * var_B;
  
  return (RGB){.red = var_R * 255, .green = var_G * 255, .blue = var_B * 255, .alpha = xyz.alpha};
}

extern RGB _FBRGBColorComponents(UIColor *color)
{
  RGB result;
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return result;
  }
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
    result.red = result.green = result.blue = components[0];
    result.alpha = components[1];
  } else {
    result.red = components[0];
    result.green = components[1];
    result.blue = components[2];
    result.alpha = components[3];
  }
  return result;
}

extern CGFloat _FBGetColorWheelHue(CGPoint position, CGPoint center, CGFloat radius)
{
  CGFloat dx = (CGFloat)(position.x - center.x) / radius;
  CGFloat dy = (CGFloat)(position.y - center.y) / radius;
  CGFloat d = sqrtf(dx*dx + dy*dy);
  CGFloat hue = 0;
  if (d != 0) {
    hue = acosf(dx / d) / M_PI / 2.0f;
    if (dy < 0) {
      hue = 1.0 - hue;
    }
  }
  return hue;
}

extern CGFloat _FBGetColorWheelSaturation(CGPoint position, CGPoint center, CGFloat radius)
{
  CGFloat dx = (CGFloat)(position.x - center.x) / radius;
  CGFloat dy = (CGFloat)(position.y - center.y) / radius;
  return sqrtf(dx*dx + dy*dy);
}

extern CGImageRef _FBCreateColorWheelImage(CGFloat diameter)
{
  CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
  CFDataSetLength(bitmapData, diameter * diameter * 4);
  UInt8 * bitmap = CFDataGetMutableBytePtr(bitmapData);
  for (int y = 0; y < diameter; y++) {
    for (int x = 0; x < diameter; x++) {
      CGFloat hue = _FBGetColorWheelHue(CGPointMake(x, y), (CGPoint){diameter / 2, diameter / 2}, diameter / 2);
      CGFloat saturation = _FBGetColorWheelSaturation(CGPointMake(x, y), (CGPoint){diameter / 2, diameter / 2}, diameter / 2);
      CGFloat a = 0.0f;
      RGB rgb = {0.0f, 0.0f, 0.0f, 0.0f};
      if (saturation < 1.0) {
        // Antialias the edge of the circle.
        if (saturation > 0.99) a = (1.0 - saturation) * 100;
        else a = 1.0;
        HSB hsb = {hue, saturation, 1.0f, a};
        rgb = _FBHSB2RGB(hsb);
      }

      int i = 4 * (x + y * diameter);
      bitmap[i] = rgb.red * 0xff;
      bitmap[i+1] = rgb.green * 0xff;
      bitmap[i+2] = rgb.blue * 0xff;
      bitmap[i+3] = rgb.alpha * 0xff;
    }
  }

  CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(bitmapData);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGImageRef imageRef = CGImageCreate(diameter, diameter, 8, 32, diameter * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  CGColorSpaceRelease(colorSpace);
  CFRelease(bitmapData);
  return imageRef;
}
