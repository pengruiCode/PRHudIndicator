//
//  PRHudIndicator.m
//  PRHudIndicator
//
//  Created by 彭睿 on 2018/1/20.
//  Copyright © 2018年 彭睿. All rights reserved.
//

#import "PRHudIndicator.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define LINE_WIDTH 3

#define ANIMATIONN_KEY_ROTATE       @"animationKeyRotate"
#define ANIMATIONN_KEY_ROTATE_GROUP @"animationKeyRotateGroup"
#define ANIMATIONN_KEY_LINE         @"animationKeyLine"
#define ANIMATIONN_KEY_SUCCEED      @"animationKeySucceed"

@interface PRHudIndicator () <CAAnimationDelegate>

@property (strong, nonatomic) UILabel           *hudTextLb;

@property (strong, nonatomic) CAShapeLayer      *progressLayer;         //圆圈
@property (strong, nonatomic) CABasicAnimation  *rotateAnimation;
@property (strong, nonatomic) CABasicAnimation  *strokeAnimatinStart;
@property (strong, nonatomic) CABasicAnimation  *strokeAnimatinEnd;
@property (strong, nonatomic) CAAnimationGroup  *animationGroup;

@property (strong, nonatomic) CAShapeLayer      *succeedLayer;          //对号
@property (strong, nonatomic) CABasicAnimation  *succeedAnim;          //对号

@end

@implementation PRHudIndicator

static PRHudIndicator *instance;

+ (instancetype)sharedPRHudIndicator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 100)/2, (SCREEN_HEIGHT - 100)/2, 100, 100)];
        }
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:effectView];
        
        _hudTextLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 75, 100, 15)];
        _hudTextLb.textColor = [UIColor whiteColor];
        _hudTextLb.font = [UIFont systemFontOfSize:12];
        _hudTextLb.textAlignment = YES;
        [self addSubview:_hudTextLb];
        
        [self.layer addSublayer:self.progressLayer];
    }
    return self;
}

//设置指示文字
- (void)setHudText:(NSString *)hudText {
    if (hudText.length > 0) {
        _hudText = hudText;
        _hudTextLb.text = hudText;
        self.progressLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 10);
    }else{
        _hudText = @"";
        _hudTextLb.text = @"";
        self.progressLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

//设置颜色
- (void)setHudColor:(UIColor *)hudColor {
    if (hudColor) {
        _hudColor = hudColor;
        self.progressLayer.strokeColor = hudColor.CGColor;
    }else{
        _hudColor = [UIColor redColor];
        self.progressLayer.strokeColor = [UIColor redColor].CGColor;
    }
}

#pragma mark --- 单线旋转样式

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.bounds = CGRectMake(0, 0, 50, 50);
        _progressLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _progressLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(50/2, 50/2) radius:50/2 startAngle:0 endAngle:M_PI*2 clockwise:YES].CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = LINE_WIDTH;
        _progressLayer.strokeColor = [UIColor redColor].CGColor;
        _progressLayer.strokeEnd = 0;
        _progressLayer.strokeStart = 0;
        _progressLayer.lineCap = kCALineCapRound;
    }
    return _progressLayer;
}

- (CABasicAnimation *)rotateAnimation {
    if (!_rotateAnimation) {
        _rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _rotateAnimation.fromValue = @0;
        _rotateAnimation.toValue = @(2*M_PI);
        _rotateAnimation.duration = 1;
        _rotateAnimation.repeatCount = HUGE;
        _rotateAnimation.removedOnCompletion = NO;
    }
    return _rotateAnimation;
}

- (CABasicAnimation *)strokeAnimatinStart {
    if (!_strokeAnimatinStart) {
        _strokeAnimatinStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        _strokeAnimatinStart.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _strokeAnimatinStart.duration = 1;
        _strokeAnimatinStart.fromValue = @0;
        _strokeAnimatinStart.toValue = @1;
        _strokeAnimatinStart.beginTime = 1;
        _strokeAnimatinStart.removedOnCompletion = NO;
        _strokeAnimatinStart.fillMode = kCAFillModeForwards;
        _strokeAnimatinStart.repeatCount = HUGE;
    }
    return _strokeAnimatinStart;
}

- (CABasicAnimation *)strokeAnimatinEnd {
    if (!_strokeAnimatinEnd) {
        _strokeAnimatinEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _strokeAnimatinEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _strokeAnimatinEnd.duration = 2;
        _strokeAnimatinEnd.fromValue = @0;
        _strokeAnimatinEnd.toValue = @1;
        _strokeAnimatinEnd.removedOnCompletion = NO;
        _strokeAnimatinEnd.fillMode = kCAFillModeForwards;
        _strokeAnimatinEnd.repeatCount = HUGE;
    }
    return _strokeAnimatinEnd;
}

- (CAAnimationGroup *)animationGroup {
    if (!_animationGroup) {
        _animationGroup = [CAAnimationGroup animation];
        _animationGroup.animations = @[self.strokeAnimatinStart, self.strokeAnimatinEnd];
        _animationGroup.repeatCount = HUGE;
        _animationGroup.duration = 2;
    }
    return _animationGroup;
}

#pragma mark --- 单线旋转样式，加载成功变对号指示
- (void)loadSucceedChangeAnimation {
    [self.progressLayer removeAllAnimations];
    self.strokeAnimatinEnd.duration = 0.5;
    self.strokeAnimatinEnd.repeatCount = 0;
    [self.progressLayer addAnimation:self.strokeAnimatinEnd forKey:ANIMATIONN_KEY_LINE];
    [self.progressLayer addSublayer:self.succeedLayer];
    [self.succeedLayer addAnimation:self.succeedAnim forKey:ANIMATIONN_KEY_SUCCEED];
}

//对号
- (CAShapeLayer *)succeedLayer {
    if (!_succeedLayer) {
        CGFloat a = self.progressLayer.bounds.size.width;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(a*2.7/10,a*5.4/10)];
        [path addLineToPoint:CGPointMake(a*4.5/10,a*7/10)];
        [path addLineToPoint:CGPointMake(a*7.8/10,a*3.8/10)];
        
        _succeedLayer = [CAShapeLayer layer];
        _succeedLayer.path = path.CGPath;
        _succeedLayer.fillColor = [UIColor clearColor].CGColor;
        _succeedLayer.strokeColor = _hudColor ? _hudColor.CGColor : [UIColor redColor].CGColor;;
        _succeedLayer.lineWidth = LINE_WIDTH;
        _succeedLayer.lineCap = kCALineCapRound;
        _succeedLayer.lineJoin = kCALineJoinRound;
    }
    return _succeedLayer;
}


- (CABasicAnimation *)succeedAnim {
    if (!_succeedAnim) {
        _succeedAnim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _succeedAnim.duration = 0.5;
        _succeedAnim.fromValue = @(0.0f);
        _succeedAnim.toValue = @(1.0f);
        _succeedAnim.delegate = self;
    }
    return _succeedAnim;
}


#pragma mark --- 加载完成回调
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && self.finishBlock) {
        self.finishBlock();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
    }
}

- (void)animationFinishReturnBlock:(animationFinishReturnBlock)block {
    self.finishBlock = block;
}




#pragma mark --- 显示隐藏
- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if (self.strokeAnimatinEnd.duration == 0.5) {
        [self.progressLayer removeAllAnimations];
        [self.succeedLayer removeFromSuperlayer];
        self.strokeAnimatinEnd.duration = 2;
        self.strokeAnimatinEnd.repeatCount = HUGE;
    }
    
    [self.progressLayer addAnimation:self.animationGroup forKey:ANIMATIONN_KEY_ROTATE_GROUP];
    [self.progressLayer addAnimation:self.rotateAnimation forKey:ANIMATIONN_KEY_ROTATE];
    
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateKeyframesWithDuration:0.6 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    } completion:nil];
}

- (void)hide {
    //隐藏指示器,同时移除动画
    [UIView animateKeyframesWithDuration:0.6 delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        }];
    } completion:^(BOOL finished){
        [self.progressLayer removeAllAnimations];
        [self removeFromSuperview];
    }];
    
}


@end
