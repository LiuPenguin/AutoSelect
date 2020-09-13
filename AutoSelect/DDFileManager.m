//
//  DDFileManager.m
//  AutoSelect
//
//  Created by YDKJ on 2020/8/7.
//  Copyright © 2020 Apple. All rights reserved.
//


#import "DDFileManager.h"

static DDFileManager *_mySingle = nil;

@implementation DDFileManager

#pragma mark ——— wenjian 创建和操作相关
+(NSString *)getDocFilePath{
    // 获取Document目录
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    // 获取Library目录
//    NSString *LibraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
//    // 获取Caches目录
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    // 获取Preferences目录 通常情况下，Preferences有系统维护，所以我们很少去操作它。
//    NSString *preferPath = [LibraryPath stringByAppendingPathComponent:@"Preferences"];
//    // 获取tmp目录
//    NSString *tmpPath = NSTemporaryDirectory();
    
    return docPath;
}

//创建文件夹
+(BOOL)creatDir:(NSString *)path{
    if (path.length==0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSuccess = YES;
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (isExist==NO) {
        NSError *error;
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            isSuccess = NO;
            NSLog(@"creat Directory Failed:%@",[error localizedDescription]);
        }
    }
    return isSuccess;
}

//创建文件
+(BOOL)creatFile:(NSString*)filePath{
    if (filePath.length==0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    NSError *error;
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    BOOL isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat File Failed:%@",[error localizedDescription]);
    }
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return isSuccess;
}

//写入数据
+(BOOL)writeToFile:(NSString*)filePath contents:(NSData *)data{
    if (filePath.length==0) {
        return NO;
    }
    BOOL result = [self creatFile:filePath];
    if (result) {
        if ([data writeToFile:filePath atomically:YES]) {
            NSLog(@"write Success");
        }else{
            NSLog(@"write Failed");
        }
    }
    else{
        NSLog(@"write Failed");
    }
    return result;
}

//追加数据
+(BOOL)appendData:(NSData*)data withPath:(NSString *)filePath{
    if (filePath.length==0) {
        return NO;
    }
    BOOL result = [self creatFile:filePath];
    if (result) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle synchronizeFile];
        [handle closeFile];
    }
    else{
        NSLog(@"appendData Failed");
    }
    return result;
}
//读取数据
+(NSData*)readFileData:(NSString *)path{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *fileData = [handle readDataToEndOfFile];
    [handle closeFile];
    return fileData;
}

//获取文件夹下所有的文件列表
+(NSArray*)getFileList:(NSString*)path{
    if (path.length==0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"getFileList Failed:%@",[error localizedDescription]);
    }
    return fileList;
}


//获取文件夹下所有的文件列表 深度便利
+(NSArray*)getAllFileList:(NSString*)path{
    if (path.length==0) {
        return nil;
    }
    NSArray *fileArray = [self getFileList:path];
    NSMutableArray *fileArrayNew = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *aPath in fileArray) {
        NSString * fullPath = [path stringByAppendingPathComponent:aPath];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                [fileArrayNew addObjectsFromArray:[self getAllFileList:fullPath]];
            }else{
                [fileArrayNew addObject:fullPath];
            }
        }
    }
    return fileArrayNew;
}
//移除文件
+ (BOOL)removeFileWithFilePath:(NSString *)filePath {
    NSFileManager *FileManager = [NSFileManager defaultManager];
    if ([FileManager fileExistsAtPath:filePath]) {
        BOOL isRemove = [FileManager removeItemAtPath:filePath error:nil];
        if (!isRemove) {
            NSLog(@"移除失败");
            return NO;
        } else {
            NSLog(@"移除成功");
            return YES;
        }
    } else {
        NSLog(@"文件不存在");
        return NO;
    }
    return NO;
}

#pragma mark ——— nsdata 转化相关
//nsdata 转  nsarray
+(NSArray *)tureArrayWithData:(NSData *)myData{
    // 方法1：NSKeyedUnarchiver
    NSArray *array = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:myData];

//    // 方法2：NSJSONSerialization
//    NSError * error = nil;
//    NSArray *dictFromData = [NSJSONSerialization JSONObjectWithData:myData
//                                                               options:NSJSONReadingAllowFragments
//                                                                   error:&error];
    
    return array;
}
@end
