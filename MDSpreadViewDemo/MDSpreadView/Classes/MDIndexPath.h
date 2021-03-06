
#import <Foundation/Foundation.h>

@interface MDIndexPath : NSObject {
    NSInteger section;
    NSInteger row;
}

+ (MDIndexPath *)indexPathForColumn:(NSInteger)column inSection:(NSInteger)section;
+ (MDIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@property (nonatomic,readonly) NSInteger section;
@property (nonatomic,readonly) NSInteger row;
@property (nonatomic,readonly) NSInteger column;

- (BOOL)isEqualToIndexPath:(MDIndexPath *)object;

@end

