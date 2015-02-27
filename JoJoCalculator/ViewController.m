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
    
    // 初始化输出结果，初始化分配内存，应该放到初始化的地方，这里暂时判断不为空则分配内存
    if (_resultString == nil)
    {
        _resultString = [[NSMutableString alloc] init];
    }
    
    // endRange是用来标记最后一个输入字符，用于del操作，删除最后一个
    NSRange endRange;
    NSUInteger stringLength;
    switch (buttonContent) {
        // 清除所有输入字符
        case 'C':
            _resultString = nil;
            break;
            
        //  删除最后一个字符
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
    
    // 目前思路需要对已经处理过的数字和操作符做删除更改处理，因此用可变数组好处理点
    NSMutableArray *mutableArrayNumber = [[NSMutableArray alloc] init];
    NSMutableArray *mutableArrayOperate = [[NSMutableArray alloc] init];
    mutableArrayNumber = [NSMutableArray arrayWithArray:calcArrayNumber];
    mutableArrayOperate = [NSMutableArray arrayWithArray:calcArrayOperate];
    
    // 删除分割后的空字符，拆分为操作符的那个可变数组会有很多空串
    [mutableArrayOperate removeObject:@""];
    
    // 校验参数合法性，用户可能输入有误，比如2＋－4等
    if (![self checkInput:mutableArrayNumber :mutableArrayOperate]) {
        return;
    }
    
    // 用于定义计算完成后调整数字数组mutableArrayNumber的block
    // 这里基本思路是每次运算完需要删除操作符和将运算结果存储到第一个数字位置，
    // 删除另一个数字
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
            
            // 第一个数字位置替换为结果
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
    
    // 再计算加减
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
