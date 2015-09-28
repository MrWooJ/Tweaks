//
//  _FBTweakColorViewControllerXYZDataSource.m
//  FBTweak
//
//  Created by Alireza Arabi on 9/28/15.
//  Copyright © 2015 Facebook. All rights reserved.
//

#import "_FBTweakColorViewControllerXYZDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerXYZDataSource () <_FBColorComponentCellDelegate>

@end

@implementation _FBTweakColorViewControllerXYZDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  XYZ _xyzColorComponents;
  RGB _rgbColorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"X", @"Y", @"Z", @"A"];
    _maxValues = @[
                   @(_FBXYZColorComponentMaxValue),
                   @(_FBXYZColorComponentMaxValue),
                   @(_FBXYZColorComponentMaxValue),
                   @(_FBAlphaComponentMaxValue),
                   ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  _xyzColorComponents = _FBRGB2XYZ(_FBRGBColorComponents(value));
  _rgbColorComponents = _FBXYZ2RGB(_xyzColorComponents);
  [self _reloadData];
}

- (UIColor *)value
{
  return [UIColor colorWithRed:_rgbColorComponents.red / 255.0 green:_rgbColorComponents.green / 255.0 blue:_rgbColorComponents.blue / 255.0 alpha:_rgbColorComponents.alpha];
}

#pragma mark - _FBColorComponentCellDelegate

- (void)colorComponentCell:(_FBColorComponentCell *)cell didChangeValue:(CGFloat)value
{
  [self _setValue:value forColorComponent:[_colorComponentCells indexOfObject:cell]];
  [self _reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 1;
  }
  return _colorComponentCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    return _colorSampleCell;
  }
  return _colorComponentCells[indexPath.row];
}

#pragma mark - Private methods

- (void)_reloadData
{
  NSArray *components = [self _colorComponentsWithXYZ:_xyzColorComponents];

  _rgbColorComponents = _FBXYZ2RGB(_xyzColorComponents);
  _colorSampleCell.backgroundColor = [UIColor colorWithRed:_rgbColorComponents.red/255.0 green:_rgbColorComponents.green/255.0 blue:_rgbColorComponents.blue/255.0 alpha:_rgbColorComponents.alpha];
  
  for (int i = 0; i < _FBXYZAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    
    NSArray *colorArray = [self colorsForMask:_xyzColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.value = [components[i] floatValue] * (i == _FBXYZAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
  }
}

- (void)_createCells
{
  NSArray *components = [self _colorComponentsWithXYZ:_xyzColorComponents];
  
  NSMutableArray *tmp = [NSMutableArray array];
  for (int i = 0; i < _FBXYZAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    
    NSArray *colorArray = [self colorsForMask:_xyzColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.format = @"%.f";
    cell.value = [components[i] floatValue] * (i == _FBXYZAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
    cell.title = _titles[i];
    cell.maximumValue = [_maxValues[i] floatValue];
    cell.delegate = self;
    [tmp addObject:cell];
  }
  _colorComponentCells = [tmp copy];
  
  _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  _colorSampleCell.backgroundColor = self.value;
}

- (void)_setValue:(CGFloat)value forColorComponent:(_FBXYZColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  
  switch (colorComponent) {
    case _FBXYZColorComponentX:
      _xyzColorComponents.x = value;
      break;
    case _FBXYZColorComponentY:
      _xyzColorComponents.y = value;
      break;
    case _FBXYZColorComponentZ:
      _xyzColorComponents.z = value;
      break;
    case _FBXYZColorComponentAlpha:
      _xyzColorComponents.alpha = value / _FBAlphaComponentMaxValue;
      break;
    default:
      break;
  }
  
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (NSArray *)_colorComponentsWithXYZ:(XYZ)xyz
{
  return @[@(xyz.x), @(xyz.y), @(xyz.z), @(xyz.alpha)];
}

- (NSArray *)colorsForMask:(XYZ)xyzColor forColorComponent:(_FBXYZColorComponent)colorComponent
{
  RGB firstRGB, secondRGB;
  XYZ firstXYZ, secondXYZ;
  
  switch (colorComponent) {
    case _FBXYZColorComponentX:
      firstXYZ = (XYZ) {.x = 0, .y = xyzColor.y, .z = xyzColor.z, .alpha = xyzColor.alpha};
      secondXYZ = (XYZ) {.x = 100, .y = xyzColor.y, .z = xyzColor.z, .alpha = xyzColor.alpha};
      firstRGB = _FBXYZ2RGB(firstXYZ);
      secondRGB = _FBXYZ2RGB(secondXYZ);
      break;
    case _FBXYZColorComponentY:
      firstXYZ = (XYZ) {.x = xyzColor.x, .y = 0, .z = xyzColor.z, .alpha = xyzColor.alpha};
      secondXYZ = (XYZ) {.x = xyzColor.x, .y = 100, .z = xyzColor.z, .alpha = xyzColor.alpha};
      firstRGB = _FBXYZ2RGB(firstXYZ);
      secondRGB = _FBXYZ2RGB(secondXYZ);
      break;
    case _FBXYZColorComponentZ:
      firstXYZ = (XYZ) {.x = xyzColor.x, .y = xyzColor.y, .z = 0, .alpha = xyzColor.alpha};
      secondXYZ = (XYZ) {.x = xyzColor.x, .y = xyzColor.y, .z = 100, .alpha = xyzColor.alpha};
      firstRGB = _FBXYZ2RGB(firstXYZ);
      secondRGB = _FBXYZ2RGB(secondXYZ);
      break;
    case _FBXYZColorComponentAlpha:
      firstXYZ = (XYZ) {.x = xyzColor.x, .y = xyzColor.y, .z = xyzColor.z, .alpha = 0};
      secondXYZ = (XYZ) {.x = xyzColor.x, .y = xyzColor.y, .z = xyzColor.z, .alpha = 1};
      firstRGB = _FBXYZ2RGB(firstXYZ);
      secondRGB = _FBXYZ2RGB(secondXYZ);
      break;
  }
  
  UIColor *firstColor = [UIColor colorWithRed:firstRGB.red/255.0 green:firstRGB.green/255.0 blue:firstRGB.blue/255.0 alpha:firstRGB.alpha];
  UIColor *secondColor = [UIColor colorWithRed:secondRGB.red/255.0 green:secondRGB.green/255.0 blue:secondRGB.blue/255.0 alpha:secondRGB.alpha];
  
  return @[firstColor,secondColor];
}

@end
