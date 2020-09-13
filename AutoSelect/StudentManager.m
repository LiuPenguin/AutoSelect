//
//  StudentManager.m
//  AutoSelect
//
//  Created by YDKJ on 2020/8/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#define  ClassesPath  [NSString stringWithFormat:@"%@/Classes",[DDFileManager getDocFilePath]]

#import "StudentManager.h"

#import "DDFileManager.h"

@implementation StudentManager

//创建班级 作为一个文件
+(void)createClassWithClassName:(NSString *)className callBack:(void (^)(NSString *tips))callBack{
    
    NSString * classPath = [NSString stringWithFormat:@"%@/%@",ClassesPath,className];
    NSLog(@"----------%@---------",classPath);
    //创建文件
    if ([DDFileManager creatFile:classPath]) {
        if (callBack) {
            callBack(@"创建班级成功！");
        }
    }else{
        if (callBack) {
            callBack(@"创建班级失败！");
        }
    }
}
//获取班级文件下的学生名单
+(NSArray *)getStudentInfoWithClassName:(NSString *)className{
    NSArray *array = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ClassesPath,className]];
    return array;
}

//获取所有班级名字列表
+(NSArray *)getClassesList{
    return  [DDFileManager getFileList:ClassesPath];
}

//移除整个班级数据
+(void)removeClassWithName:(NSString *)className callBack:(void (^)(NSString *tips))callBack{
    if ([DDFileManager removeFileWithFilePath:[NSString stringWithFormat:@"%@/%@",ClassesPath,className]]) {
        if (callBack) {
                          callBack(@"成功的送走了这班学生你开心了吧！");
                      }
    }else{
        if (callBack) {
            callBack(@"移除失败了，不知道咋回事儿！");
        }
    }
    
}

//创建学生
+(void)createStudentWithName:(NSString *)studentName className:(NSString *)className callBack:(void (^)(NSString *tips))callBack{
    NSArray * studentsArr =  [StudentManager getStudentInfoWithClassName:className];
    NSMutableArray * resultArr =  [NSMutableArray array];
    if (studentsArr != nil) {
        resultArr =  [studentsArr mutableCopy];
        if ([studentsArr containsObject:studentName]) {
            if (callBack) {
                callBack(@"学生已经存在了！");
            }
            return;
        }
    }
    [resultArr addObject:studentName];
    if ([resultArr writeToFile:[NSString stringWithFormat:@"%@/%@",ClassesPath,className] atomically:YES]) {
        if (callBack) {
            callBack(@"学生信息创建成功！");
        }
    }else{
        if (callBack) {
            callBack(@"学生信息创建失败！");
        }
    }
}
//删除学生
+(void)deleteStudentWithName:(NSString *)studentName className:(NSString *)className callBack:(void (^)(NSString *tips))callBack{
    NSArray * studentsArr =  [StudentManager getStudentInfoWithClassName:className];
    NSMutableArray * resultArr =  [NSMutableArray arrayWithArray:studentsArr];
    [resultArr removeObject:studentName];
    if ([resultArr writeToFile:[NSString stringWithFormat:@"%@/%@",ClassesPath,className] atomically:YES]) {
        if (callBack) {
            callBack(@"学生信息删除成功！");
        }
    }else{
        if (callBack) {
            callBack(@"学生信息删除失败！");
        }
    }
}


@end
