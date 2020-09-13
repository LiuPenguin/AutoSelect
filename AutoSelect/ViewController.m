//
//  ViewController.m
//  AutoSelect
//
//  Created by Apple on 2018/9/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "ViewController.h"

#import "NameListViewController.h"

#import "PeoplesViewController.h"

#import <objc/runtime.h> //包含对类、成员变量、属性、方法的操作
#import <objc/message.h> //包含消息机制

#import <UIImageView+WebCache.h>


typedef NS_ENUM(NSInteger, LYFTableViewType) {
    /// 顶部
    LYFTableViewTypeTop,
    /// 底部
    LYFTableViewTypeBottom
};

//成员变量 -- 实力变量  - 属性
//实例变量是一种特殊的成员变量
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    //成员变量
    NSString * string;
    id hell;// id 是一种特有的对象
    UIButton * btn;//实例变量
    int age;
}

//属性  m默认的setter getter 方法
//GCC --> LLVM 如果没有匹配到实例变量的属性的时候自动成成带下划线的实例变量
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSMutableArray *dataSourceArr;



/// 记录手指所在的位置
@property (nonatomic, assign) CGPoint longLocation;
/// 对被选中的cell的截图
@property (nonatomic, strong) UIView *snapshotView;
/// 被选中的cell的原始位置
@property (nonatomic, strong) NSIndexPath *oldIndexPath;
/// 被选中的cell的新位置
@property (nonatomic, strong) NSIndexPath *newestIndexPath;
/// 定时器
@property (nonatomic, strong) CADisplayLink *scrollTimer;

/// 滚动方向
@property (nonatomic, assign) LYFTableViewType scrollType;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSourceArr = [NSMutableArray arrayWithArray:[StudentManager getClassesList]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    //
//    dispatch_queue_t  q = dispatch_get_global_queue(0, 0);
//    __block int a = 0;
//    while (a < 5) {
//        dispatch_async(q, ^{
//            a ++;
//            NSLog(@"--dispatch_async--%d-- %@",a,[NSThread currentThread]);
//        });
//        NSLog(@"###dispatch####%@",[NSThread currentThread]);
//    }
//    NSLog(@"----%d----%@",a,[NSThread currentThread]);
    
//    NSTimer * timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"%@\n",[NSRunLoop currentRunLoop]);
//        NSLog(@"%@",[[NSRunLoop currentRunLoop] currentMode]);
//    }];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    UIImageView * imgv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 400, 100, 100)];
    imgv.backgroundColor = [UIColor redColor];
    [self.view addSubview:imgv];
    
    [imgv sd_setImageWithURL:[NSURL URLWithString:@"http://pic1.sc.chinaz.com/Files/pic/pic9/202008/apic27063_s.jpg"] placeholderImage:[UIImage imageNamed:@""]];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma tableView--delegate
#pragma tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"cellIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    cell.textLabel.text = self.dataSourceArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = colorArr[indexPath.row%colorArr.count];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [cell.contentView addGestureRecognizer:longPress];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中");
    NameListViewController *vc = [[NameListViewController alloc] initWithNibName:@"NameListViewController" bundle:[NSBundle mainBundle]];
    vc.className = self.dataSourceArr[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ——— 左滑删除 和编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 
{
    return YES;
}
 
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击了删除");
        
        [StudentManager removeClassWithName:self.dataSourceArr[indexPath.row] callBack:^(NSString * _Nonnull tips) {
            [XNHUD showInfoWithTitle:tips maskType:XNProgressHUDMaskTypeCustom];
            NSArray *classArr  =  [StudentManager getClassesList];
            NSLog(@"%@----%@",tips,classArr);
            if (self.dataSourceArr.count) {
                [self.dataSourceArr removeAllObjects];
                [self.dataSourceArr addObjectsFromArray:classArr];
                [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击了编辑");
        PeoplesViewController *vc = [[PeoplesViewController alloc] initWithNibName:@"PeoplesViewController" bundle:nil];
        vc.titleStr = self.dataSourceArr[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    editAction.backgroundColor = [UIColor grayColor];
    
    return @[deleteAction, editAction];
}
 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
}
#pragma mark ——— tableView cell移动相关


 

//创建班级相关
- (IBAction)createNewClass:(id)sender {
    NSLog(@"创建班级");
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"创建班级" message:nil preferredStyle:
                                  UIAlertControllerStyleAlert];
    // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入班级名称";
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 通过数组拿到textTF的值
        NSString * inputText = [[alertVc textFields] objectAtIndex:0].text;
        NSArray *classArr  =  [StudentManager getClassesList];
        if ([classArr containsObject:inputText]) {
            [XNHUD showErrorWithTitle:@"班级已经存在了亲，莫要重复创建"];
            return;
        }
        [StudentManager createClassWithClassName:[[alertVc textFields] objectAtIndex:0].text callBack:^(NSString * _Nonnull tips) {
            NSArray *classArr  =  [StudentManager getClassesList];
            [XNHUD showSuccessWithTitle:tips];
            NSLog(@"%@----%@",tips,classArr);
            if (self.dataSourceArr.count) {
                [self.dataSourceArr removeAllObjects];
                [self.dataSourceArr addObjectsFromArray:classArr];
                [self.tableView reloadData];
            }else{
                [self.dataSourceArr addObjectsFromArray:classArr];
                [self.tableView reloadData];
            }
        }];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ——— 移动相关

#pragma mark - 对cell进行截图，并且隐藏
-(void)snapshotCellAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    /// 截图
    UIView *snapshot = [self snapshotView:cell];
    /// 添加在UITableView上
    [self.tableView addSubview:snapshot];
    self.snapshotView = snapshot;
    /// 隐藏cell
    cell.hidden = YES;
    CGPoint center = self.snapshotView.center;
    center.y = self.longLocation.y;
    /// 移动截图
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshotView.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.snapshotView.alpha = 0.98;
        self.snapshotView.center = center;
    }];
}

#pragma mark - 截图对应的cell
- (UIView *)snapshotView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - 长按手势
-(void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {
    UIGestureRecognizerState longPressState = longPress.state;
    //长按的cell在tableView中的位置
    self.longLocation = [longPress locationInView:self.tableView];
    //手指按住位置对应的indexPath，可能为nil
    self.newestIndexPath = [self.tableView indexPathForRowAtPoint:self.longLocation];
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{
            //手势开始，对被选中cell截图，隐藏原cell
            self.oldIndexPath = [self.tableView indexPathForRowAtPoint:self.longLocation];
            if (self.oldIndexPath) {
                [self snapshotCellAtIndexPath:self.oldIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//点击位置移动，判断手指按住位置是否进入其它indexPath范围，若进入则更新数据源并移动cell
            //截图跟随手指移动
            CGPoint center = _snapshotView.center;
            center.y = self.longLocation.y;
            self.snapshotView.center = center;
            if ([self checkIfSnapshotMeetsEdge]) {
                [self startAutoScrollTimer];
            }else{
                [self stopAutoScrollTimer];
            }
            //手指按住位置对应的indexPath，可能为nil
            self.newestIndexPath = [self.tableView indexPathForRowAtPoint:self.longLocation];
            if (self.newestIndexPath && ![self.newestIndexPath isEqual:self.oldIndexPath]) {
                [self cellRelocatedToNewIndexPath:self.newestIndexPath];
            }
            break;
        }
        default: {
            //长按手势结束或被取消，移除截图，显示cell
            [self stopAutoScrollTimer];
            [self didEndDraging];
            break;
        }
    }
}

#pragma mark - 检查截图是否到达边缘，并作出响应
- (BOOL)checkIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(self.snapshotView.frame);
    CGFloat maxY = CGRectGetMaxY(self.snapshotView.frame);
    if (minY < self.tableView.contentOffset.y) {
        self.scrollType = LYFTableViewTypeTop;
        return YES;
    }
    if (maxY > self.tableView.bounds.size.height + self.tableView.contentOffset.y) {
        self.scrollType = LYFTableViewTypeBottom;
        return YES;
    }
    return NO;
}

#pragma mark - 当截图到了新的位置，先改变数据源，然后将cell移动过去
- (void)cellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源并返回给外部
    [self updateData];
    //交换移动cell位置
    [self.tableView moveRowAtIndexPath:self.oldIndexPath toIndexPath:indexPath];
    //更新cell的原始indexPath为当前indexPath
    self.oldIndexPath = indexPath;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_oldIndexPath];
    cell.hidden = YES;
}

#pragma mark - 更新数据源
-(void)updateData {
    //通过DataSource代理获得原始数据源数组
    NSMutableArray *tempArray = self.dataSourceArr;
    
    //判断原始数据源是否为多重数组
    if ([self arrayCheck:tempArray]) {//是嵌套数组
        if (self.oldIndexPath.section == self.newestIndexPath.section) {//在同一个section内
            [self moveObjectInMutableArray:tempArray[self.oldIndexPath.section] fromIndex:self.oldIndexPath.row toIndex:self.newestIndexPath.row];
        }else{                                                          //不在同一个section内
            id originalObj = tempArray[self.oldIndexPath.section][self.oldIndexPath.item];
            [tempArray[self.newestIndexPath.section] insertObject:originalObj atIndex:self.newestIndexPath.item];
            [tempArray[self.oldIndexPath.section] removeObjectAtIndex:self.oldIndexPath.item];
        }
    }else{                                  //不是嵌套数组
        [self moveObjectInMutableArray:tempArray fromIndex:self.oldIndexPath.row toIndex:self.newestIndexPath.row];
    }
}

#pragma mark - 检测是否是多重数组
- (BOOL)arrayCheck:(NSArray *)array{
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 将可变数组中的一个对象移动到该数组中的另外一个位置
- (void)moveObjectInMutableArray:(NSMutableArray *)array fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (fromIndex < toIndex) {
        for (NSInteger i = fromIndex; i < toIndex; i ++) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSInteger i = fromIndex; i > toIndex; i --) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
}

#pragma mark - 开始自动滚动
- (void)startAutoScroll {
    CGFloat pixelSpeed = 4;
    if (self.scrollType == LYFTableViewTypeTop) {//向下滚动
        if (self.tableView.contentOffset.y > 0) {//向下滚动最大范围限制
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - pixelSpeed)];
            self.snapshotView.center = CGPointMake(self.snapshotView.center.x, self.snapshotView.center.y - pixelSpeed);
        }
    }else{                                               //向上滚动
        if (self.tableView.contentOffset.y + self.tableView.bounds.size.height < self.tableView.contentSize.height) {//向下滚动最大范围限制
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + pixelSpeed)];
            self.snapshotView.center = CGPointMake(self.snapshotView.center.x, self.snapshotView.center.y + pixelSpeed);
        }
    }
    
    ///  当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
    self.newestIndexPath = [self.tableView indexPathForRowAtPoint:self.snapshotView.center];
    if (self.newestIndexPath && ![self.newestIndexPath isEqual:self.oldIndexPath]) {
        [self cellRelocatedToNewIndexPath:self.newestIndexPath];
    }
}

#pragma mark - 拖拽结束，显示cell，并移除截图
- (void)didEndDraging{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.oldIndexPath];
    cell.hidden = NO;
    cell.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshotView.center = cell.center;
        self.snapshotView.alpha = 0;
        self.snapshotView.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        self.oldIndexPath = nil;
        self.newestIndexPath = nil;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - 创建定时器
- (void)startAutoScrollTimer {
    if (!self.scrollTimer) {
        self.scrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [self.scrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - 销毁定时器
- (void)stopAutoScrollTimer {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}


@end
