//
//  ViewController.h
//  JoJoCalculator
//
//  Created by zz on 15/2/25.
//  Copyright (c) 2015年 JoJo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// 输出结果的标签和记录内容
@property (nonatomic, weak) IBOutlet UILabel *resultLabel;
@property (nonatomic, strong) NSMutableString *resultString;

// 所有按钮的点击事件
- (IBAction)buttonClick:(id)sender;

// 计算结果
- (void)calcResult;

// 检测下用户输入合法性
- (bool)checkInput:(NSMutableArray *)arrayNumber :(NSMutableArray *)arrayOperate;

// 标记操作类型
enum OPREATE_FLAG {
    OPREATE_ADD,
    OPREATE_SUB,
    OPREATE_MULTI,
    OPREATE_DIV,
    
};

@end

