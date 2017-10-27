
#import "CellCache.h"

@implementation CellCache
-(id)init
{
    self = [super init];
    if (!self) return nil;
    
    dict = [[NSMutableDictionary alloc] init];
    
    return self;
    
}

-(void)putCell:(MDSpreadViewCell *)cell row:(int)row column:(int)column{
    NSMutableDictionary * dictSecond = [dict objectForKey:[NSNumber numberWithInt:row]];
    if(dictSecond){
        [dictSecond setObject:cell forKey:[NSNumber numberWithInt:column]];
    } else {
        NSMutableDictionary * dictSecond = [[NSMutableDictionary alloc] init];
        [dictSecond setObject:cell forKey:[NSNumber numberWithInt:column]];
        [dict setObject:dictSecond forKey:[NSNumber numberWithInt:row]];
        
    }
    
    
    
}


-(MDSpreadViewCell *)getCell:(int)row column:(int)column{
    NSMutableDictionary * dictSecond = [dict objectForKey:[NSNumber numberWithInt:row]];
    if(!dictSecond){
        return NULL;
    }
    return [dictSecond objectForKey:[NSNumber numberWithInt:column]];
}

-(void)clearAll{
    [dict removeAllObjects];
}

@end

