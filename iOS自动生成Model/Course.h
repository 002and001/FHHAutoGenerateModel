//
//  Course.h
//  uschool
//
//  Created by hefanghui on 2017/06/27.
//  Copyright © 2017年 topglobaledu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TeachingSubject;
@class Grade;

@interface Course : NSObject

@property (nonatomic, copy) NSString *courseID;
@property (nonatomic, copy) NSString *courseState;
@property (nonatomic, strong) NSArray *lessonArray;
@property (nonatomic, assign) BOOL hadChanged;
@property (nonatomic, strong) TeachingSubject *teachingSubject;
@property (nonatomic, strong) Grade *grade;
@property (nonatomic, copy) NSString *courseName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

