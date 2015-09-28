//
//  _FBTweakColorViewControllerLABDataSource.m
//  FBTweak
//
//  Created by Alireza Arabi on 9/28/15.
//  Copyright © 2015 Facebook. All rights reserved.
//

#import "_FBTweakColorViewControllerLABDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerLABDataSource () <_FBColorComponentCellDelegate>

@end

@implementation _FBTweakColorViewControllerLABDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  LAB _labColorComponents;
  RGB _rgbColorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"L", @"A", @"B", @"A"];
    _maxValues = @[
                   @(_FBLABLightnessColorComponentMaxValue),
                   @(_FBLABColorComponentMaxValue),
                   @(_FBLABColorComponentMaxValue),
                   @(_FBAlphaComponentMaxValue),
                   ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  _labColorComponents = _FBRGB2LAB(_FBRGBColorComponents(value));
  _rgbColorComponents = _FBLAB2RGB(_labColorComponents);
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
  NSArray *components = [self _colorComponentsWithLAB:_labColorComponents];
  
  _rgbColorComponents = _FBLAB2RGB(_labColorComponents);
  _colorSampleCell.backgroundColor = [UIColor colorWithRed:_rgbColorComponents.red/255.0 green:_rgbColorComponents.green/255.0 blue:_rgbColorComponents.blue/255.0 alpha:_rgbColorComponents.alpha];
  
  for (int i = 0; i < _FBLABAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    
    NSArray *colorArray = [self colorsForMask:_labColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.value = [components[i] floatValue] * (i == _FBLABAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
  }
}

- (void)_createCells
{
  NSArray *components = [self _colorComponentsWithLAB:_labColorComponents];
  
  NSMutableArray *tmp = [NSMutableArray array];
  for (int i = 0; i < _FBLABAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    
    NSArray *colorArray = [self colorsForMask:_labColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.format = @"%.f";
    cell.value = [components[i] floatValue] * (i == _FBLABAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
    cell.title = _titles[i];
    cell.maximumValue = [_maxValues[i] floatValue];
    if (i == 1 || i == 2)
      cell.minimumValue = (-1 * [_maxValues[i] floatValue]);
    cell.delegate = self;
    [tmp addObject:cell];
  }
  _colorComponentCells = [tmp copy];
  
  _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  _colorSampleCell.backgroundColor = self.value;
}

- (void)_setValue:(CGFloat)value forColorComponent:(_FBLABColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  
  switch (colorComponent) {
    case _FBLABColorComponentLightness:
      _labColorComponents.lightness = value;
      break;
    case _FBLABColorComponentA:
      _labColorComponents.a = value;
      break;
    case _FBLABColorComponentB:
      _labColorComponents.b = value;
      break;
    case _FBLABColorComponentAlpha:
      _labColorComponents.alpha = value / _FBAlphaComponentMaxValue;
      break;
    default:
      break;
  }
  
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (NSArray *)_colorComponentsWithLAB:(LAB)lab
{
  return @[@(lab.lightness), @(lab.a), @(lab.b), @(lab.alpha)];
}

- (NSArray *)colorsForMask:(LAB)labColor forColorComponent:(_FBLABColorComponent)colorComponent
{
  RGB firstRGB, secondRGB;
  LAB firstLAB, secondLAB;
  
  switch (colorComponent) {
    case _FBLABColorComponentLightness:
      firstLAB = (LAB) {.lightness = 0, .a = labColor.a, .b = labColor.b, .alpha = labColor.alpha};
      secondLAB = (LAB) {.lightness = 100, .a = labColor.a, .b = labColor.b, .alpha = labColor.alpha};
      firstRGB = _FBLAB2RGB(firstLAB);
      secondRGB = _FBLAB2RGB(secondLAB);
      break;
    case _FBLABColorComponentA:
      firstLAB = (LAB) {.lightness = labColor.lightness, .a = -128, .b = labColor.b, .alpha = labColor.alpha};
      secondLAB = (LAB) {.lightness = labColor.lightness, .a = +128, .b = labColor.b, .alpha = labColor.alpha};
      firstRGB = _FBLAB2RGB(firstLAB);
      secondRGB = _FBLAB2RGB(secondLAB);
      break;
    case _FBLABColorComponentB:
      firstLAB = (LAB) {.lightness = labColor.lightness, .a = labColor.a, .b = -128, .alpha = labColor.alpha};
      secondLAB = (LAB) {.lightness = labColor.lightness, .a = labColor.a, .b = +128, .alpha = labColor.alpha};
      firstRGB = _FBLAB2RGB(firstLAB);
      secondRGB = _FBLAB2RGB(secondLAB);
      break;
    case _FBLABColorComponentAlpha:
      firstLAB = (LAB) {.lightness = labColor.lightness, .a = labColor.a, .b = labColor.b, .alpha = 0};
      secondLAB = (LAB) {.lightness = labColor.lightness, .a = labColor.a, .b = labColor.b, .alpha = 1};
      firstRGB = _FBLAB2RGB(firstLAB);
      secondRGB = _FBLAB2RGB(secondLAB);
      break;
  }
  
  UIColor *firstColor = [UIColor colorWithRed:firstRGB.red/255.0 green:firstRGB.green/255.0 blue:firstRGB.blue/255.0 alpha:firstRGB.alpha];
  UIColor *secondColor = [UIColor colorWithRed:secondRGB.red/255.0 green:secondRGB.green/255.0 blue:secondRGB.blue/255.0 alpha:secondRGB.alpha];
  
  return @[firstColor,secondColor];
}

@end
