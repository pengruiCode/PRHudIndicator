//
//  ViewController.m
//  PRHudIndicator
//
//  Created by 彭睿 on 2018/1/20.
//  Copyright © 2018年 彭睿. All rights reserved.
//

#import "ViewController.h"
#import "PRHudIndicator.h"

@interface ViewController ()

@property (nonatomic,strong) PRHudIndicator *hud;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _hud = [PRHudIndicator sharedPRHudIndicator];
    _hud.hudColor = [UIColor purpleColor];
}


- (IBAction)defaultType {
    _hud.hudType = PRHudType_Round;
    [_hud show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud loadSucceedChangeAnimation];
        [_hud hide];
    });
}

- (IBAction)gifType {
    _hud.hudType = PRHudType_Gif;
    _hud.hudText = @"正在加载...as/fnsdlfbn'sdmlfg;sndfmS";
    [_hud show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud hide];
    });
}

- (IBAction)downloadType {
    _hud.hudType = PRHudType_DownLoad;
    [_hud show];
}




@end
