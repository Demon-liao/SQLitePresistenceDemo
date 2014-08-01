//
//  Bridge.m
//  SQLitePresistenceDemo
//
//  Created by demon on 14-8-1.
//  Copyright (c) 2014年 demon. All rights reserved.
//

#import "Bridge.h"
#import "sqlite3.h"
@implementation Bridge

+(NSString *)esc:(NSString *)str {
    if (!str || [str length] == 0) {
        return @"''";
    }
    NSString *buf = @(sqlite3_mprintf("%q", [str cStringUsingEncoding:NSUTF8StringEncoding]));
    return buf;
}

@end
