//  ************************************************************************
//
//  Course.m
//  uschool
//
//  Created by hefanghui on 2017/06/21.
//  Copyright © 2017年 topglobaledu. All rights reserved.
//
//  Main function:
//
//  Other specifications:
//
//  ************************************************************************

#import "Course.h"
#import "TeachingSubject.h"

@implementation Course

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;	
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {	
	if ([key isEqualToString:@"course_id"]) {
		_courseID = value;
	}
	if ([key isEqualToString:@"state"]) {
		_courseState = value;
	}
}

@end

