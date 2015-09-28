//
//  _FBTweakColorViewControllerCMYKDataSource.m
//  FBTweak
//
//  Created by Alireza Arabi on 9/27/15.
//  Copyright © 2015 Facebook. All rights reserved.
//

#import "_FBTweakColorViewControllerCMYKDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerCMYKDataSource () <_FBColorComponentCellDelegate>

@end

@implementation _FBTweakColorViewControllerCMYKDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  CMYK _cmykColorComponents;
  RGB _rgbColorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"C", @"M", @"Y", @"K", @"A"];
    _maxValues = @[
                   @(_FBCMYKColorComponentMaxValue),
                   @(_FBCMYKColorComponentMaxValue),
                   @(_FBCMYKColorComponentMaxValue),
                   @(_FBCMYKColorComponentMaxValue),
                   @(_FBAlphaComponentMaxValue),
                   ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  _cmykColorComponents = _FBRGB2CMYK(_FBRGBColorComponents(value));
  _rgbColorComponents = _FBCMYK2RGB(_cmykColorComponents);
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
  NSArray *components = [self _colorComponentsWithCMYK:_cmykColorComponents];
  
  _rgbColorComponents = _FBCMYK2RGB(_cmykColorComponents);
  _colorSampleCell.backgroundColor = [UIColor colorWithRed:_rgbColorComponents.red/255.0 green:_rgbColorComponents.green/255.0 blue:_rgbColorComponents.blue/255.0 alpha:_rgbColorComponents.alpha];
  
  for (int i = 0; i < _FBCMYKAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    
    NSArray *colorArray = [self colorsForMask:_cmykColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.value = [components[i] floatValue] * (i == _FBCMYKAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
  }
}

- (void)_createCells
{
  NSArray *components = [self _colorComponentsWithCMYK:_cmykColorComponents];
  
  NSMutableArray *tmp = [NSMutableArray array];
  for (int i = 0; i < _FBCMYKAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    
    NSArray *colorArray = [self colorsForMask:_cmykColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.format = i == _FBCMYKAColorComponentsSize - 1 ? @"%.f" : @"%.2f";
    cell.value = [components[i] floatValue] * (i == _FBCMYKAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
    cell.title = _titles[i];
    cell.maximumValue = [_maxValues[i] floatValue];
    cell.delegate = self;
    [tmp addObject:cell];
  }
  _colorComponentCells = [tmp copy];
  
  _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  _colorSampleCell.backgroundColor = self.value;
}

- (void)_setValue:(CGFloat)value forColorComponent:(_FBCMYKColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  
  switch (colorComponent) {
    case _FBCMYKColorComponentCyan:
      _cmykColorComponents.cyan = value * 100;
      break;
    case _FBCMYKColorComponentMagenta:
      _cmykColorComponents.magenta = value * 100;
      break;
    case _FBCMYKColorComponentYellow:
      _cmykColorComponents.yellow = value * 100;
      break;
    case _FBCMYKColorComponentKey:
      _cmykColorComponents.key = value * 100;
      break;
    case _FBCMYKColorComponentAlpha:
      _cmykColorComponents.alpha = value / _FBAlphaComponentMaxValue;
      break;
  }
  
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (NSArray *)_colorComponentsWithCMYK:(CMYK)cmyk
{
  return @[@(cmyk.cyan / 100.0), @(cmyk.magenta / 100.0), @(cmyk.yellow / 100.0), @(cmyk.key / 100.0), @(cmyk.alpha)];
}

- (NSArray *)colorsForMask:(CMYK)cmykColor forColorComponent:(_FBCMYKColorComponent)colorComponent
{
  RGB firstRGB, secondRGB;
  CMYK firstCMYK, secondCMYK;
  
  switch (colorComponent) {
    case _FBCMYKColorComponentCyan:
      firstCMYK = (CMYK) {.cyan = 0.0, .magenta = cmykColor.magenta, .yellow = cmykColor.yellow, .key = cmykColor.key, .alpha = cmykColor.alpha};
      secondCMYK = (CMYK) {.cyan = 100.0, .magenta = cmykColor.magenta, .yellow = cmykColor.yellow, .key = cmykColor.key, .alpha = cmykColor.alpha};
      firstRGB = _FBCMYK2RGB(firstCMYK);
      secondRGB = _FBCMYK2RGB(secondCMYK);
      break;
    case _FBCMYKColorComponentMagenta:
      firstCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = 0.0, .yellow = cmykColor.yellow, .key = cmykColor.key, .alpha = cmykColor.alpha};
      secondCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = 100.0, .yellow = cmykColor.yellow, .key = cmykColor.key, .alpha = cmykColor.alpha};
      firstRGB = _FBCMYK2RGB(firstCMYK);
      secondRGB = _FBCMYK2RGB(secondCMYK);
      break;
    case _FBCMYKColorComponentYellow:
      firstCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = cmykColor.magenta, .yellow = 0.0, .key = cmykColor.key, .alpha = cmykColor.alpha};
      secondCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = cmykColor.magenta, .yellow = 100.0, .key = cmykColor.key, .alpha = cmykColor.alpha};
      firstRGB = _FBCMYK2RGB(firstCMYK);
      secondRGB = _FBCMYK2RGB(secondCMYK);
      break;
    case _FBCMYKColorComponentKey:
      firstCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = cmykColor.magenta, .yellow = cmykColor.yellow, .key = 0.0, .alpha = cmykColor.alpha};
      secondCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = cmykColor.magenta, .yellow = cmykColor.yellow, .key = 100.0, .alpha = cmykColor.alpha};
      firstRGB = _FBCMYK2RGB(firstCMYK);
      secondRGB = _FBCMYK2RGB(secondCMYK);
      break;
    case _FBCMYKColorComponentAlpha:
      firstCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = cmykColor.magenta, .yellow = cmykColor.yellow, .key = cmykColor.key, .alpha = 0};
      secondCMYK = (CMYK) {.cyan = cmykColor.cyan, .magenta = cmykColor.magenta, .yellow = cmykColor.yellow, .key = cmykColor.key, .alpha = 1};
      firstRGB = _FBCMYK2RGB(firstCMYK);
      secondRGB = _FBCMYK2RGB(secondCMYK);
      
  }
  
  UIColor *firstColor = [UIColor colorWithRed:firstRGB.red/255.0 green:firstRGB.green/255.0 blue:firstRGB.blue/255.0 alpha:firstRGB.alpha];
  UIColor *secondColor = [UIColor colorWithRed:secondRGB.red/255.0 green:secondRGB.green/255.0 blue:secondRGB.blue/255.0 alpha:secondRGB.alpha];
  
  return @[firstColor,secondColor];
}

@end
