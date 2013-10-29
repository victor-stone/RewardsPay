//
//  NSTimer+BlocksKit.m
//  BlocksKit
//

#import "NSTimer+BlocksKit.h"

@interface NSTimer (BlocksKitPrivate)
+ (void)bk_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (BlocksKit)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeats:(BOOL)inRepeats block:(BKTimerBlock)inBlock
{
    return [self scheduledTimerWithTimeInterval:inTimeInterval block:inBlock repeats:inRepeats];
}

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
	NSParameterAssert(block);
	return [self scheduledTimerWithTimeInterval: inTimeInterval target: self selector: @selector(bk_executeBlockFromTimer:) userInfo: [block copy] repeats: inRepeats];
}

+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
	NSParameterAssert(block);
	return [self timerWithTimeInterval: inTimeInterval target: self selector: @selector(bk_executeBlockFromTimer:) userInfo: [block copy] repeats: inRepeats];
}

+ (void)bk_executeBlockFromTimer:(NSTimer *)aTimer {
	NSTimeInterval time = [aTimer timeInterval];
	BKTimerBlock block = [aTimer userInfo];
	if (block) block(time);
}

@end