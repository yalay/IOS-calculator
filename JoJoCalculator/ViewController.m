//
//  ViewController.m
//  JoJoCalculator
//
//  Created by zz on 15/2/25.
//  Copyright (c) 2015年 JoJo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClick:(id)sender {
    // 强制转型为btn类型
    UIButton *button =(UIButton *)sender;
    
    
    // button标题追加到标签栏,clear和del需要特殊处理
    unichar buttonContent = [button.titleLabel.text characterAtIndex:0];
    
    // 初始化输出结果
    if (_resultString == nil)
    {
        _resultString = [[NSMutableString alloc] init];
    }
    
    NSRange endRange;
    NSUInteger stringLength;
    switch (buttonContent) {
        case 'C':
            _resultString = nil;
            break;
            
        case 'D':
            stringLength = [_resultString length];
            if (stringLength <= 0)
            {
                break;
            }
            
            endRange = NSMakeRange(stringLength - 1, 1);
            [_resultString deleteCharactersInRange:(endRange)];
            break;
            
        case '=':
            [self calcResult];
            break;
            
        default:
            [_resultString appendString:([NSString stringWithFormat:@"%c", buttonContent])];
            break;
    }
    
    // 标签内容刷新为结果，刷新为空默认显示为0
    if ((_resultString == nil) ||  [_resultString isEqualToString:@""]) {
        [_resultLabel setText:@"0"];
    }
    else {
        [_resultLabel setText:[NSString stringWithString:_resultString]];
    }
}

// 将输入的字符串序列拆分成计算单元，计算出来结果
- (void)calcResult {
    NSArray *calcArrayNumber = [_resultString componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"+-×÷"]];
    
    NSArray *calcArrayOperate = [_resultString componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
    
    NSMutableArray *mutableArrayNumber = [[NSMutableArray alloc] init];
    NSMutableArray *mutableArrayOperate = [[NSMutableArray alloc] init];
    mutableArrayNumber = [NSMutableArray arrayWithArray:calcArrayNumber];
    mutableArrayOperate = [NSMutableArray arrayWithArray:calcArrayOperate];
    
    // 删除分割后的空字符
    [mutableArrayOperate removeObject:@""];
    
    // 校验参数合法性
    if (![self checkInput:mutableArrayNumber :mutableArrayOperate]) {
        return;
    }
    
    // 用于定义计算完成后调整数字数组mutableArrayNumber的block
    void (^adjustArray)(NSMutableArray *, NSUInteger, enum OPREATE_FLAG)
        = ^(NSMutableArray *mutableArrayNumber, NSUInteger index, enum OPREATE_FLAG operateFlag) {
            NSUInteger result;
            switch (operateFlag) {
                case OPREATE_ADD:
                    result = [mutableArrayNumber[index] integerValue] + [mutableArrayNumber[index + 1] integerValue];
                    break;
                case OPREATE_SUB:
                    result = [mutableArrayNumber[index] integerValue] - [mutableArrayNumber[index + 1] integerValue];
                    break;
                case OPREATE_MULTI:
                    result = [mutableArrayNumber[index] integerValue] * [mutableArrayNumber[index + 1] integerValue];
                    break;
                case OPREATE_DIV:
                    result = [mutableArrayNumber[index] integerValue] / [mutableArrayNumber[index + 1] integerValue];
                    break;
            }
            
            mutableArrayNumber[index] = @(result);
            [mutableArrayNumber removeObjectAtIndex:(index + 1)];
        };
    
    // 按优先级先计算乘除法.再计算加减
    BOOL continueCalc = true;
    while (continueCalc) {
        NSUInteger index;
        for (index = 0; index < mutableArrayOperate.count; index++) {
            if ([mutableArrayOperate[index] isEqualToString:@"×"]) {
                // 先计算乘积
                adjustArray(mutableArrayNumber, index, OPREATE_MULTI);
                [mutableArrayOperate removeObjectAtIndex:index];
                break;
            }
            
            if ([mutableArrayOperate[index] isEqualToString:@"÷"]) {
                // 先计算除法
                adjustArray(mutableArrayNumber, index, OPREATE_DIV);
                [mutableArrayOperate removeObjectAtIndex:index];
                break;
            }
        }
        
        if ((mutableArrayOperate.count == 0) ||
            (index >= (mutableArrayOperate.count))) {
            continueCalc = false;
        }
    }
    
    continueCalc = true;
    while (continueCalc) {
        NSUInteger index;
        for (index = 0; index < mutableArrayOperate.count; index++) {
            if ([mutableArrayOperate[index] isEqualToString:@"+"]){
                // 计算加法
                adjustArray(mutableArrayNumber, index, OPREATE_ADD);
                [mutableArrayOperate removeObjectAtIndex:index];
                break;
            }
            
            if ([mutableArrayOperate[index] isEqualToString:@"-"]) {
                // 计算减法
                adjustArray(mutableArrayNumber, index, OPREATE_SUB);
                [mutableArrayOperate removeObjectAtIndex:index];
                break;
            }
        }
        
        if (mutableArrayOperate.count == 0) {
            continueCalc = false;
        }
    }
    
    [_resultString setString:[NSString stringWithFormat:@"%d", [mutableArrayNumber[0] intValue]]];
};

- (bool)checkInput:(NSMutableArray *)arrayNumber :(NSMutableArray *)arrayOperate {
    if (arrayNumber.count < 2 || arrayOperate.count < 1) {
        return false;
    }
    
    if (arrayNumber.count - arrayOperate.count != 1) {
        return false;
    }
    
    return true;
}

@end
