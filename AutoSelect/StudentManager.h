//
//  StudentManager.h
//  AutoSelect
//
//  Created by YDKJ on 2020/8/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StudentManager : NSObject
//创建班级 作为一个文件
+(void)createClassWithClassName:(NSString *)className callBack:(void (^)(NSString *tips))callBack;
//获取班级文件下的学生名单
+(NSArray *)getStudentInfoWithClassName:(NSString *)className;
//移除整个班级数据
+(void)removeClassWithName:(NSString *)className callBack:(void (^)(NSString *tips))callBack;
//创建学生
+(void)createStudentWithName:(NSString *)studentName className:(NSString *)className callBack:(void (^)(NSString *tips))callBack;
//删除学生
+(void)deleteStudentWithName:(NSString *)studentName className:(NSString *)className callBack:(void (^)(NSString *tips))callBack;
//获取所有班级名字列表
+(NSArray *)getClassesList;

@end

NS_ASSUME_NONNULL_END
