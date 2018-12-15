//
//  TTPerson.m
//  TT_KVO
//
//  Created by yxt on 2018/12/13.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import "TTPerson.h"

@implementation TTPerson

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *set = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key  isEqualToString:@"fullName"]) {
        NSArray *affectArr = @[@"firstName",@"lastName"];
        set = [set setByAddingObjectsFromArray:affectArr];
    }
    return set;
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingFullName {
    return [NSSet setWithObjects:@"firstName",@"lastName", nil];
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@--%@",self.firstName,self.lastName];
}

@end
