//
//  MDIndexPath.m
//  company-ess-ios
//
//  Created by worksap on 10/12/16.
//  Copyright © 2016 worksap. All rights reserved.
//

#import "MDIndexPath.h"

@implementation MDIndexPath

@synthesize section, row;

+ (MDIndexPath *)indexPathForColumn:(NSInteger)b inSection:(NSInteger)a
{
    MDIndexPath *path = [[self alloc] init];
    
    path->section = a;
    path->row = b;
    
    return path;
}

+ (MDIndexPath *)indexPathForRow:(NSInteger)b inSection:(NSInteger)a
{
    MDIndexPath *path = [[self alloc] init];
    
    path->section = a;
    path->row = b;
    
    return path;
}

- (NSInteger)column
{
    return row;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%ld, %ld]", (long)section, (long)row];
}

- (BOOL)isEqual:(id)object
{
    return [self isEqualToIndexPath:object];
}

- (BOOL)isEqualToIndexPath:(MDIndexPath *)object
{
    if (object == nil) return NO;
    return (object->section == self->section && object->row == self->row);
}

- (NSUInteger)hash // https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
{
    return ((((NSUInteger)row) << (CHAR_BIT * sizeof(NSUInteger)) / 2) | (((NSUInteger)row) >> ((CHAR_BIT * sizeof(NSUInteger)) - (CHAR_BIT * sizeof(NSUInteger)) / 2))) ^ section;
}

@end
