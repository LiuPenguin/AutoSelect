//
//  PeoplesViewController.h
//  AutoSelect
//
//  Created by Apple on 2018/9/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeoplesViewController : UIViewController

@property(nonatomic,strong) NSMutableArray *namesArr;

@property(nonatomic,strong) NSString *titleStr;


@property (nonatomic,copy) void (^callBack)(void);



@end
