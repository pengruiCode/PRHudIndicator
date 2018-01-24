//
//  PRHudIndicator.h
//  PRHudIndicator
//
//  Created by 彭睿 on 2018/1/20.
//  Copyright © 2018年 彭睿. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^animationFinishReturnBlock)(void);

@interface PRHudIndicator : UIView

//指示文字
@property (nonatomic,copy) NSString *hudText;
//颜色
@property (nonatomic,strong) UIColor *hudColor;
//加载完成回调
@property (nonatomic,strong) animationFinishReturnBlock finishBlock;


//单例创建
+ (instancetype)sharedPRHudIndicator;

- (void)animationFinishReturnBlock:(animationFinishReturnBlock)block;

//显示
- (void)show;

//隐藏
- (void)hide;

//
- (void)loadSucceedChangeAnimation;




@end
