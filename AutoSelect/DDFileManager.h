//
//  DDFileManager.h
//  AutoSelect
//
//  Created by YDKJ on 2020/8/7.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDFileManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDFileManager : NSObject

+(NSString *)getDocFilePath;
//创建文件夹
+(BOOL)creatDir:(NSString *)path;
//创建文件
+(BOOL)creatFile:(NSString*)filePath;

//写入数据
+(BOOL)writeToFile:(NSString*)filePath contents:(NSData *)data;

//追加数据
+(BOOL)appendData:(NSData*)data withPath:(NSString *)filePath;
//读取数据
+(NSData*)readFileData:(NSString *)path;

//获取文件夹下所有的文件列表
+(NSArray*)getFileList:(NSString*)path;

//移除文件
+ (BOOL)removeFileWithFilePath:(NSString *)filePath;

//获取文件夹下所有的文件列表 深度便利
+(NSArray*)getAllFileList:(NSString*)path;

#pragma mark ——— nsdata 转化相关
//nsdata 转  nsarray
+(NSArray *)tureArrayWithData:(NSData *)myData;


@end

NS_ASSUME_NONNULL_END
