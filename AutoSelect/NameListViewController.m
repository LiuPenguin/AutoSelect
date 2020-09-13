//
//  NameListViewController.m
//  AutoSelect
//
//  Created by Apple on 2018/9/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "NameListViewController.h"

#import "PeoplesViewController.h"

@interface NameListViewController ()
@property (weak, nonatomic) IBOutlet UILabel *classNameLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property(nonatomic,strong) NSMutableArray *nameArr;
@property(nonatomic,strong) NSTimer *time;

@end

@implementation NameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.className;
    
    self.nameArr = [NSMutableArray array];
    NSArray * namesArr =  [StudentManager getStudentInfoWithClassName:self.className];
    if (namesArr != nil) {
        [self.nameArr addObjectsFromArray:namesArr];
    }
    self.nameLab.text = @"谁呢？";
    if (self.nameArr.count) {
        
    }else{
        self.nameLab.text = @"无可选！";
        return;
    }
    //第一次修改
    // Do any additional setup after loading the view from its nib.
}

- 
-(void)rightClick{
    NSLog(@"rightClick");
    PeoplesViewController *vc = [[PeoplesViewController alloc] initWithNibName:@"PeoplesViewController" bundle:nil];
    vc.titleStr = self.className;
    [self.navigationController pushViewController:vc animated:YES];
    vc.callBack = ^{
        [self.nameArr removeAllObjects];
        NSArray * namesArr =  [StudentManager getStudentInfoWithClassName:self.className];
        [self.nameArr addObjectsFromArray:namesArr];
    };
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)startNameBtn:(id)sender {
    NSLog(@"开始按钮点击 %d",self.startBtn.selected);
    if (self.nameArr.count) {
        
    }else{
        [XNHUD showErrorWithTitle:@"这个班您还没带学生，首页左滑编辑添加！"];
        return;
    }
    //开始选
    self.startBtn.selected = !self.startBtn.selected;
    [self.startBtn setTitle:self.startBtn.selected?@"选啦":@"开始" forState:UIControlStateNormal];
    if (self.startBtn.selected) {
        //选中
        if (self.time) {
            [self.time invalidate];
            self.time = nil;
        }
        self.time = [NSTimer scheduledTimerWithTimeInterval:0.16 target:self selector:@selector(click2) userInfo:nil repeats:YES];
        //将定时器放入线程池
        [[NSRunLoop currentRunLoop]addTimer:self.time forMode:NSDefaultRunLoopMode];
    }else{
        [self.time invalidate];
        //选取随机数
        int x = arc4random() % self.nameArr.count; //[0,self.nameArr.count)
        self.nameLab.text = [self.nameArr objectAtIndex:x];
    }
}
- (void)click2
{
    static int i = 0;
    if (i >= [self.nameArr count]) {
        i = 0;
    }
    self.nameLab.text = [self.nameArr objectAtIndex:i];
    i++;
}
-(void)dealloc{
    if (self.time) {
        [self.time invalidate];
        self.time = 0;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
