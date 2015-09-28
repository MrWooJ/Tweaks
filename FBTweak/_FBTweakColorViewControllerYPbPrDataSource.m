//
//  _FBTweakColorViewControllerYPbPrDataSource.m
//  FBTweak
//
//  Created by Alireza Arabi on 9/28/15.
//  Copyright © 2015 Facebook. All rights reserved.
//

#import "_FBTweakColorViewControllerYPbPrDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerYPbPrDataSource () <_FBColorComponentCellDelegate>

@end

@implementation _FBTweakColorViewControllerYPbPrDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  YPBPR _ypbprColorComponents;
  RGB _rgbColorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"Y", @"Pb", @"Pr", @"A"];
    _maxValues = @[
                   @(_FBYPBPR_YColorComponentMaxValue),
                   @(_FBYPBPR_PBPRColorComponentMaxValue),
                   @(_FBYPBPR_PBPRColorComponentMaxValue),
                   @(_FBAlphaComponentMaxValue),
                   ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  _ypbprColorComponents = _FBRGB2YPbPr(_FBRGBColorComponents(value));
  _rgbColorComponents = _FBYPbPr2RGB(_ypbprColorComponents);
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
  NSArray *components = [self _colorComponentsWithYPBPR:_ypbprColorComponents];

  _rgbColorComponents = _FBYPbPr2RGB(_ypbprColorComponents);
  _colorSampleCell.backgroundColor = [UIColor colorWithRed:_rgbColorComponents.red/255.0 green:_rgbColorComponents.green/255.0 blue:_rgbColorComponents.blue/255.0 alpha:_rgbColorComponents.alpha];
  
  for (int i = 0; i < _FBYPBPRAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    
    NSArray *colorArray = [self colorsForMask:_ypbprColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.value = [components[i] floatValue] * (i == _FBYPBPRAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
  }
}

- (void)_createCells
{
  NSArray *components = [self _colorComponentsWithYPBPR:_ypbprColorComponents];
  
  NSMutableArray *tmp = [NSMutableArray array];
  for (int i = 0; i < _FBYPBPRAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    
    NSArray *colorArray = [self colorsForMask:_ypbprColorComponents forColorComponent:i];
    UIColor *firstColor = [colorArray firstObject];
    UIColor *secondColor = [colorArray lastObject];
    cell.colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
    
    cell.format = @"%.f";
    cell.value = [components[i] floatValue] * (i == _FBYPBPRAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
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

- (void)_setValue:(CGFloat)value forColorComponent:(_FBYPBPRColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  
  switch (colorComponent) {
    case _FBYPBPRColorComponentY:
      _ypbprColorComponents.y = value;
      break;
    case _FBYPBPRColorComponentPb:
      _ypbprColorComponents.pb = value;
      break;
    case _FBYPBPRColorComponentPr:
      _ypbprColorComponents.pr = value;
      break;
    case _FBYPBPRColorComponentAlpha:
      _ypbprColorComponents.alpha = value / _FBAlphaComponentMaxValue;
      break;
    default:
      break;
  }
  
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (NSArray *)_colorComponentsWithYPBPR:(YPBPR)ypbpr
{
  return @[@(ypbpr.y), @(ypbpr.pb), @(ypbpr.pr), @(ypbpr.alpha)];
}

- (NSArray *)colorsForMask:(YPBPR)ypbprColor forColorComponent:(_FBYPBPRColorComponent)colorComponent
{
  RGB firstRGB, secondRGB;
  YPBPR firstYPBPR, secondYPBPR;
  
  switch (colorComponent) {
    case _FBYPBPRColorComponentY:
      firstYPBPR = (YPBPR) {.y = 0, .pb = ypbprColor.pb, .pr = ypbprColor.pr, .alpha = ypbprColor.alpha};
      secondYPBPR = (YPBPR) {.y = 255, .pb = ypbprColor.pb, .pr = ypbprColor.pr, .alpha = ypbprColor.alpha};
      firstRGB = _FBYPbPr2RGB(firstYPBPR);
      secondRGB = _FBYPbPr2RGB(secondYPBPR);
      break;
    case _FBYPBPRColorComponentPb:
      firstYPBPR = (YPBPR) {.y = ypbprColor.y, .pb = -127, .pr = ypbprColor.pr, .alpha = ypbprColor.alpha};
      secondYPBPR = (YPBPR) {.y = ypbprColor.y, .pb = +127, .pr = ypbprColor.pr, .alpha = ypbprColor.alpha};
      firstRGB = _FBYPbPr2RGB(firstYPBPR);
      secondRGB = _FBYPbPr2RGB(secondYPBPR);
      break;
    case _FBYPBPRColorComponentPr:
      firstYPBPR = (YPBPR) {.y = ypbprColor.y, .pb = ypbprColor.pb, .pr = -127, .alpha = ypbprColor.alpha};
      secondYPBPR = (YPBPR) {.y = ypbprColor.y, .pb = ypbprColor.pb, .pr = +127, .alpha = ypbprColor.alpha};
      firstRGB = _FBYPbPr2RGB(firstYPBPR);
      secondRGB = _FBYPbPr2RGB(secondYPBPR);
      break;
    case _FBYPBPRColorComponentAlpha:
      firstYPBPR = (YPBPR) {.y = ypbprColor.y, .pb = ypbprColor.pb, .pr = ypbprColor.pr, .alpha = 0};
      secondYPBPR = (YPBPR) {.y = ypbprColor.y, .pb = ypbprColor.pb, .pr = ypbprColor.pr, .alpha = 1};
      firstRGB = _FBYPbPr2RGB(firstYPBPR);
      secondRGB = _FBYPbPr2RGB(secondYPBPR);
      break;
  }
  
  UIColor *firstColor = [UIColor colorWithRed:firstRGB.red/255.0 green:firstRGB.green/255.0 blue:firstRGB.blue/255.0 alpha:firstRGB.alpha];
  UIColor *secondColor = [UIColor colorWithRed:secondRGB.red/255.0 green:secondRGB.green/255.0 blue:secondRGB.blue/255.0 alpha:secondRGB.alpha];
  
  return @[firstColor,secondColor];
}

@end
