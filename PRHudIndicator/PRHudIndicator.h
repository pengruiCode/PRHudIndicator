//
//  PRHudIndicator.h
//  PRHudIndicator
//
//  Created by 彭睿 on 2018/1/20.
//  Copyright © 2018年 彭睿. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger , PRHudType) {
    PRHudType_Round = 0,        //普通的小圆圈
    PRHudType_Gif   = 1,        //动图
} ;


//加载完成回调
typedef void(^animationFinishReturnBlock)(void);

@interface PRHudIndicator : UIView

//指示文字
@property (nonatomic,copy) NSString *hudText;
//颜色
@property (nonatomic,strong) UIColor *hudColor;
//加载完成回调
@property (nonatomic,strong) animationFinishReturnBlock finishBlock;
//是否正在旋转
@property (nonatomic,assign) BOOL isRotate;
//hud类型
@property (nonatomic,assign) PRHudType hudType;


//单例创建
+ (instancetype)sharedPRHudIndicator;

- (void)animationFinishReturnBlock:(animationFinishReturnBlock)block;

//显示
- (void)show;

//隐藏
- (void)hide;

//显示加载完成对号
- (void)loadSucceedChangeAnimation;




@end
