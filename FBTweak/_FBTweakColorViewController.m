/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakColorViewController.h"
#import "_FBTweakColorViewControllerHSBDataSource.h"
#import "_FBTweakColorViewControllerRGBDataSource.h"
#import "_FBTweakColorViewControllerHSLDataSource.h"
#import "_FBTweakColorViewControllerCMYKDataSource.h"
#import "_FBTweakColorViewControllerLABDataSource.h"
#import "_FBTweakColorViewControllerYPBPRDataSource.h"
#import "_FBTweakColorViewControllerXYZDataSource.h"
#import "_FBKeyboardManager.h"
#import "FBTweak.h"

static void *kContext = &kContext;
static CGFloat const _FBTweakColorCellDefaultHeight = 44.0;
static CGFloat const _FBColorWheelCellHeight = 220.0f;

@interface _FBTweakColorViewController () <UITableViewDelegate>

@end

@implementation _FBTweakColorViewController {
  NSObject<_FBTweakColorViewControllerDataSource> *_rgbDataSource;
  NSObject<_FBTweakColorViewControllerDataSource> *_hsbDataSource;
  NSObject<_FBTweakColorViewControllerDataSource> *_hslDataSource;
  NSObject<_FBTweakColorViewControllerDataSource> *_cmykDataSource;
  NSObject<_FBTweakColorViewControllerDataSource> *_labDataSource;
  NSObject<_FBTweakColorViewControllerDataSource> *_ypbprDataSource;
  NSObject<_FBTweakColorViewControllerDataSource> *_xyzDataSource;
  FBTweak *_tweak;
  _FBKeyboardManager *_keyboardManager;
  UITableView *_tableView;
}

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  NSParameterAssert([tweak.defaultValue isKindOfClass:[UIColor class]]);
  if (self = [super init]) {
    _tweak = tweak;
    _rgbDataSource = [[_FBTweakColorViewControllerRGBDataSource alloc] init];
    _hsbDataSource = [[_FBTweakColorViewControllerHSBDataSource alloc] init];
    _hslDataSource = [[_FBTweakColorViewControllerHSLDataSource alloc] init];
    _cmykDataSource = [[_FBTweakColorViewControllerCMYKDataSource alloc] init];
    _labDataSource = [[_FBTweakColorViewControllerLABDataSource alloc] init];
    _ypbprDataSource = [[_FBTweakColorViewControllerYPbPrDataSource alloc] init];
    _xyzDataSource = [[_FBTweakColorViewControllerXYZDataSource alloc] init];
    [_rgbDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_hsbDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_hslDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_cmykDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_labDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_ypbprDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_xyzDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
  }
  return self;
}

- (void)dealloc
{
  [_rgbDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_hsbDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_hslDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_cmykDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_labDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_ypbprDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_xyzDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  _tableView.delegate = self;
  [self.view addSubview:_tableView];

  _keyboardManager = [[_FBKeyboardManager alloc] initWithViewScrollView:_tableView];

  UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 40 , self.view.frame.size.width, 40)];
  
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"RGB", @"HSB", @"HSL", @"CMYK", @"LAB", @"YPbPr", @"XYZ"]];
  [segmentedControl addTarget:self action:@selector(_segmentControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  [toolbar addSubview:segmentedControl];
  [segmentedControl setFrame:CGRectMake(5,5, self.view.frame.size.width - 10, 30)];
  
  NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:segmentedControl
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:30];
  [segmentedControl addConstraint:heightConstraint];
  
  NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:segmentedControl
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:(self.view.frame.size.width - 10)];
  [segmentedControl addConstraint:widthConstraint];
  
  [self.view addSubview:toolbar];

  segmentedControl.selectedSegmentIndex = 0;
  [self _segmentControlDidChangeValue:segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [_keyboardManager enable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_keyboardManager disable];
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject<_FBTweakColorViewControllerDataSource> *)dataSource change:(NSDictionary *)change context:(void *)context
{
  if (context != kContext) {
    return;
  }
  _tweak.currentValue = dataSource.value;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView.dataSource == _hsbDataSource && indexPath.section == 1 && indexPath.row == 0) {
    return _FBColorWheelCellHeight;
  }
  return _FBTweakColorCellDefaultHeight;
}

#pragma mark - Private methods

- (UIColor *)_colorValue
{
  return _tweak.currentValue ?: _tweak.defaultValue;
}

- (void)_segmentControlDidChangeValue:(UISegmentedControl *)sender
{
  NSObject<_FBTweakColorViewControllerDataSource> *dataSource;
  switch (sender.selectedSegmentIndex) {
    case 0:
      dataSource = _rgbDataSource;
      break;
    case 1:
      dataSource = _hsbDataSource;
      break;
    case 2:
      dataSource = _hslDataSource;
      break;
    case 3:
      dataSource = _cmykDataSource;
      break;
    case 4:
      dataSource = _labDataSource;
      break;
    case 5:
      dataSource = _ypbprDataSource;
      break;
    case 6:
      dataSource = _xyzDataSource;
      break;
      
    default:
      break;
  }
  dataSource.value = [self _colorValue];
  _tableView.dataSource = dataSource;
  [_tableView reloadData];
}

@end
