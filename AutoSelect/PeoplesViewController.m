//
//  PeoplesViewController.m
//  AutoSelect
//
//  Created by Apple on 2018/9/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#define gap 10.f

#import "PeoplesViewController.h"

@interface PeoplesViewController ()
@property (weak, nonatomic) IBOutlet UIView *nameListBackView;

@end

@implementation PeoplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;
    
    //获取数据
    NSArray * namesArr =  [StudentManager getStudentInfoWithClassName:self.titleStr];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加学生" style:UIStatusBarStyleDefault target:self action:@selector(rightClick)];
    
    self.namesArr = [NSMutableArray array];
    if (namesArr) {
        [self.namesArr addObjectsFromArray:namesArr];
    }
    [self loadNamePart];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)loadNamePart{
    CGFloat btnHei = 30;
    CGFloat btnWid = (kScreenW - gap * 6)/5;
    for (int i = 0 ; i < self.namesArr.count; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.namesArr[i] forState:UIControlStateNormal];
        btn.tag = 10 + i;
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.frame = CGRectMake(gap + (gap + btnWid)*(i%5),88 +  gap + (gap + btnHei)*(i/5), btnWid, btnHei);
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(modifyName:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.callBack) {
        self.callBack();
    }
}
-(void)rightClick{
    //添加学生
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"添加学生" message:nil preferredStyle:
                                  UIAlertControllerStyleAlert];
    // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入学生名字";
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 通过数组拿到textTF的值
        [StudentManager createStudentWithName:[[alertVc textFields] objectAtIndex:0].text className:self.titleStr callBack:^(NSString * _Nonnull tips) {
            NSArray * namesArr =  [StudentManager getStudentInfoWithClassName:self.titleStr];
            [XNHUD showInfoWithTitle:tips maskType:XNProgressHUDMaskTypeCustom];
            [self.namesArr removeAllObjects];
            [self.namesArr addObjectsFromArray:namesArr];
            for (UIView * view in self.view.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    [view removeFromSuperview];
                }
            }
            [self loadNamePart];
        }];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
-(void)modifyName:(UIButton *)btn{
    NSLog(@"modifyName");
    [self presentAlertSheet:btn.titleLabel.text];
}
//表单警告框代码
-(void)presentAlertSheet:(NSString *)btnTitle{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"您老人家要编辑%@同学么？",btnTitle] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *centain = [UIAlertAction actionWithTitle:@"移除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //移除这个
        [StudentManager deleteStudentWithName:btnTitle className:self.titleStr callBack:^(NSString * _Nonnull tips) {
            NSArray * namesArr =  [StudentManager getStudentInfoWithClassName:self.titleStr];
            [XNHUD showInfoWithTitle:tips maskType:XNProgressHUDMaskTypeCustom];
            [self.namesArr removeAllObjects];
            [self.namesArr addObjectsFromArray:namesArr];
            for (UIView * view in self.view.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    [view removeFromSuperview];
                }
            }
            [self loadNamePart];
        }];
    }];
    [alert addAction:centain];
    UIAlertAction *centain2 = [UIAlertAction actionWithTitle:@"修改名字" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //修改名字
        [self modyfyName:btnTitle];
    }];
    [alert addAction:centain2];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)modyfyName:(NSString *)nameStr{
    [self presentAlert:nameStr];
}
//警告框代码
-(void)presentAlert:(NSString *)nameStr{
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:[NSString stringWithFormat:@"修改%@这位同学的名字",nameStr]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        //响应事件
        //得到文本信息
        for(UITextField *text in alert.textFields){
            NSLog(@"text = %@", text.text);
            //移除这个
            [StudentManager deleteStudentWithName:nameStr className:self.titleStr callBack:^(NSString * _Nonnull tips) {
                
            }];
            [StudentManager createStudentWithName:text.text className:self.titleStr callBack:^(NSString * _Nonnull tips) {
                NSArray * namesArr =  [StudentManager getStudentInfoWithClassName:self.titleStr];
                [XNHUD showInfoWithTitle:tips maskType:XNProgressHUDMaskTypeCustom];
                [self.namesArr removeAllObjects];
                [self.namesArr addObjectsFromArray:namesArr];
                for (UIView * view in self.view.subviews) {
                    if ([view isKindOfClass:[UIButton class]]) {
                        [view removeFromSuperview];
                    }
                }
                [self loadNamePart];
            }];
            
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", alert.textFields);
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"修改姓名";
        textField.text = nameStr;
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)modify:(id)sender {
    //添加学生
    //提示框添加文本输入框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"填写要同学的名字"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        //响应事件
        //得到文本信息
        for(UITextField *text in alert.textFields){
            NSLog(@"text = %@", text.text);
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
        //响应事件
        NSLog(@"action = %@", alert.textFields);
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"姓名";
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
