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
    _hud.hudText = @"正在加载...";
    
    [_hud animationFinishReturnBlock:^{
        NSLog(@"加载完成");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud show];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud loadSucceedChangeAnimation];
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_hud show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud loadSucceedChangeAnimation];
    });
}



@end
