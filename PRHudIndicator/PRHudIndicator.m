//
//  PRHudIndicator.m
//  PRHudIndicator
//
//  Created by 彭睿 on 2018/1/20.
//  Copyright © 2018年 彭睿. All rights reserved.
//

#import "PRHudIndicator.h"
#import "PRHudDownLoadView.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define LINE_WIDTH 3

#define ANIMATIONN_KEY_ROTATE       @"animationKeyRotate"
#define ANIMATIONN_KEY_ROTATE_GROUP @"animationKeyRotateGroup"
#define ANIMATIONN_KEY_LINE         @"animationKeyLine"
#define ANIMATIONN_KEY_SUCCEED      @"animationKeySucceed"

@interface PRHudIndicator () <CAAnimationDelegate>

@property (strong, nonatomic) UILabel           *hudTextLb;             //提示文字
@property (strong, nonatomic) PRHudDownLoadView *downLoadView;          //下载动画
@property (strong, nonatomic) CAShapeLayer      *progressLayer;         //圆圈
@property (strong, nonatomic) CABasicAnimation  *rotateAnimation;
@property (strong, nonatomic) CABasicAnimation  *strokeAnimatinStart;
@property (strong, nonatomic) CABasicAnimation  *strokeAnimatinEnd;
@property (strong, nonatomic) CAAnimationGroup  *animationGroup;
@property (strong, nonatomic) UIVisualEffectView *effectView;           //毛玻璃背景
@property (strong, nonatomic) CAShapeLayer      *succeedLayer;          //对号
@property (strong, nonatomic) UIImageView       *runImageView;          //动图
@property (strong, nonatomic) CABasicAnimation  *succeedAnim;           //对号动画
@property (assign, nonatomic) NSInteger         rotateNumber;           //旋转计数，每次show都+1，每次hide -1
@property (assign, nonatomic) NSInteger         progressNumber;         //进度计数

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
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:_effectView];
        
        _hudTextLb = [[UILabel alloc]initWithFrame:CGRectMake(5, 75, self.frame.size.width - 10, 15)];
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
//    if (_hudType != PRHudType_DownLoad) {
//        if (hudText.length > 0) {
//            _hudText = hudText;
//            _hudTextLb.text = hudText;
//
//
//            if ([self calculateRowWidth:hudText] + 10 >= SCREEN_WIDTH * 0.8) {
//                //设置最大宽度
//                [self setFrame:CGRectMake(SCREEN_WIDTH * 0.1, (SCREEN_HEIGHT - 100)/2, SCREEN_WIDTH * 0.8, 100)];
//            }else if ([self calculateRowWidth:hudText] + 10 <= 100) {
//
//            }else{
//                //设置自适应宽度
//                [self setFrame:CGRectMake((SCREEN_WIDTH - [self calculateRowWidth:hudText] + 10)/2, (SCREEN_HEIGHT - 100)/2, SCREEN_WIDTH - [self calculateRowWidth:hudText] + 10, 100)];
//            }
//            _hudTextLb.frame = CGRectMake(5, 75, self.frame.size.width - 10, 15);
//            _effectView.frame = self.bounds;
//
//            self.progressLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 10);
//            self.runImageView.frame = CGRectMake((self.frame.size.width-50)/2, (self.frame.size.height-50)/2, 50, 50);
//        }else{
//            _hudText = @"";
//            _hudTextLb.text = @"";
//            self.progressLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//            self.runImageView.frame = CGRectMake((self.frame.size.width-50)/2, 10, 50, 50);
//        }
//    }
    _hudText = hudText;
    _hudTextLb.text = hudText;
}

- (void)setHudType:(PRHudType)hudType {
    _hudType = hudType;
    NSTimer *timer;
    switch (hudType) {
        case PRHudType_Round:
            [self.runImageView removeFromSuperview];
            [self.downLoadView removeFromSuperview];
            [self addSubview:_hudTextLb];
            [self.layer addSublayer:self.progressLayer];
            break;
        case PRHudType_Gif:
            [self.downLoadView removeFromSuperview];
            [self.progressLayer removeFromSuperlayer];
            [self addSubview:_hudTextLb];
            [self addSubview:self.runImageView];
            break;
        case PRHudType_DownLoad:
            [self.runImageView removeFromSuperview];
            [self.progressLayer removeFromSuperlayer];
            [_hudTextLb removeFromSuperview];
            [self addSubview:self.downLoadView];

            _progressNumber = 0;
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            
            break;
        default:
            break;
    }
}

- (void)timerAction:(NSTimer *)timer {
    if (_progressNumber < 100) {
        ++ _progressNumber;
        [self.downLoadView setProgress:_progressNumber/100.00];
    }else{
        [timer invalidate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
        if (self.finishBlock) {
            self.finishBlock();
        }
    }
}

- (PRHudDownLoadView *)downLoadView {
    if (!_downLoadView) {
        _downLoadView = [[PRHudDownLoadView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _downLoadView;
}


//计算提示文字所占宽度
- (CGFloat)calculateRowWidth:(NSString *)string {
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};  //指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, 15)/*计算宽度时要确定高度*/ options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
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



- (UIImageView *)runImageView {
    if (!_runImageView) {
        _runImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width-50)/2, 15, 50, 50)];
        NSMutableArray *images = [[NSMutableArray alloc]initWithCapacity:7];
        for (int i=1; i<=5; i++)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"car%d.png",i]]];
        }
        _runImageView.animationImages = images;
        _runImageView.animationDuration = 0.4 ;
        _runImageView.animationRepeatCount = MAXFLOAT;
    }
    return _runImageView;
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

//画圆
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

//对号动画
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




#pragma mark --- 显示转圈
- (void)show {
   ++ _rotateNumber;
    if (!_isRotate) {
        _isRotate = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        if (!_hudType || _hudType == PRHudType_Round) {
            
            [self.layer addSublayer:self.progressLayer];
            [self.progressLayer removeAllAnimations];
            [self.succeedLayer removeFromSuperlayer];
            
            //如果是刚显示完对号
            if (self.strokeAnimatinEnd.duration == 0.5) {
                self.strokeAnimatinEnd.duration = 1.5;
                self.strokeAnimatinEnd.repeatCount = HUGE;
            }
            
            [self.progressLayer addAnimation:self.animationGroup forKey:ANIMATIONN_KEY_ROTATE_GROUP];
            [self.progressLayer addAnimation:self.rotateAnimation forKey:ANIMATIONN_KEY_ROTATE];
            
        }else if (_hudType == PRHudType_Gif){
            
            [self addSubview:self.runImageView];
            [self.runImageView startAnimating];
        }
        
        
        
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
}


#pragma mark --- 单线旋转样式，加载成功变对号指示
- (void)loadSucceedChangeAnimation {
    //当显示计数等于0则可以停止
    -- _rotateNumber;
    if (_isRotate && _rotateNumber == 0) {
        [self.progressLayer removeAllAnimations];
        [self.succeedLayer removeAllAnimations];
        self.strokeAnimatinEnd.duration = 0.5;
        self.strokeAnimatinEnd.repeatCount = 0;
        [self.progressLayer addAnimation:self.strokeAnimatinEnd forKey:ANIMATIONN_KEY_LINE];
        [self.progressLayer addSublayer:self.succeedLayer];
        [self.succeedLayer addAnimation:self.succeedAnim forKey:ANIMATIONN_KEY_SUCCEED];
    }
}


#pragma mark --- 隐藏
- (void)hide {
    if (_rotateNumber > 0) {
        -- _rotateNumber;
    }
    if (_isRotate && _rotateNumber == 0) {
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
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
        _isRotate = NO;
    }
}

//无论判断，全部移除
- (void)hideAllAnimation {
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
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
    _isRotate = NO;
}

@end
