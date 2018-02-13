//
//  PRHudDownLoad.m
//  PRHudIndicator
//
//  Created by macMini on 2018/2/11.
//  Copyright © 2018年 彭睿. All rights reserved.
//

#import "PRHudDownLoadView.h"

@interface PRHudDownLoadView ()

@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UILabel        *progressLb;            //进度显示
@property (strong,nonatomic) CAShapeLayer   *progressLayer;         //画圆圈
@property (strong,nonatomic) CAShapeLayer   *bankguroudLayer;       //背景圆圈

@end

@implementation PRHudDownLoadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.bankguroudLayer];
        [self.layer addSublayer:self.progressLayer];
        [self addSubview:self.progressLb];
    }
    return self;
}


- (void)setProgress:(float)progress {
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(85/2, 85/2) radius:85/2 startAngle:- M_PI_2 endAngle:-M_PI_2 + M_PI * 2 * progress clockwise:YES].CGPath;
    self.progressLb.text = [NSString stringWithFormat:@"%@%.2f",@"%",progress*100];
}


- (UILabel *)progressLb {
    if (!_progressLb) {
        _progressLb = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 80, 40)];
        _progressLb.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        _progressLb.textAlignment = NSTextAlignmentCenter;
        _progressLb.textColor = [UIColor redColor];
        _progressLb.backgroundColor = [UIColor clearColor];
    }
    return _progressLb;
}


- (CAShapeLayer *)bankguroudLayer {
    if (!_bankguroudLayer) {
        _bankguroudLayer = [CAShapeLayer layer];
        _bankguroudLayer.bounds = CGRectMake(0, 0, 85, 85);
        _bankguroudLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _bankguroudLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(85/2, 85/2) radius:85/2 startAngle:- M_PI_2 endAngle:-M_PI_2 + M_PI * 2 clockwise:YES].CGPath;
        _bankguroudLayer.fillColor = [UIColor clearColor].CGColor;
        _bankguroudLayer.lineWidth = 3;
        _bankguroudLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _bankguroudLayer.lineCap = kCALineCapRound;
    }
    return _bankguroudLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.bounds = CGRectMake(0, 0, 85, 85);
        _progressLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//        _progressLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(80/2, 80/2) radius:80/2 startAngle:- M_PI_2 endAngle:M_PI*2 clockwise:YES].CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = 3;
        _progressLayer.cornerRadius = 1.5;
        _progressLayer.strokeColor = [UIColor redColor].CGColor;
        _progressLayer.lineCap = kCALineCapRound;
    }
    return _progressLayer;
}


@end
