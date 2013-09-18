//
//  NSObject+VSBroadcasting.h
//  Ass Over Tea Kettle
//
//  Created by victor on 7/30/13.
//  Copyright (c) 2013 Victor Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VSBroadcastBlock)(id thisIsYou, id payload);
typedef void (^VSBroadcastsBlock)(NSString * message, id thisIsYou, id payload);

/**
 *  This category handles application wide broadcasting. 
 *
 * Use these category messages instead of NSNotificationCenter to broadcast and receive 
 * application wide events.
 *
 * This category exists to radically simplify the amount of code needed to proffer and listen for events. 
 * To broadcast event to the entire app from any object, simply:
 *
 * ```
 * [self broadcast:@"MyEventName" payload:@(49)];
 * ```
 *
 * To listen for any occurance of that event:
 *
 * ```
 * [self registerForEvent:@"MyEventName" block:^(MyClass *me, NSNumber* value) {
 *      // do something
 * }];
 * ```
 *
 * The code above is 100% of what is needed for broadcasting and listening. You do not need to instantiate or
 * reference global objects to broadcast and you do not need to unregister or clean-up anything when listening.
 *
 * See Notifications.h for which events are actually broadcast throughout the system.
 *
 * @warning Never use a `self` pointer in the callback. Use the first parameter as a reference to your object.
 *
 *
 */
@interface NSObject (VSBroadcasting)
/** 
    @name Broadcasting events
*/
/**
 *  Broadcast an event to all potential listeners (thread-synchronous)
 *
 *  @param message Name of event (see kNotification* strings)
 *  @param payload Some event-specific object
 */
-(void)broadcast:(NSString *)message payload:(id)payload;
/**
 *  Broadcast an event to all potential listeners (asynchronous)
 *
 *  @param message Name of event (see kNotification* strings)
 *  @param payload Some event-specific object
 *  @param when    A time interval in the future to do the actual broadcast
 */
-(void)broadcast:(NSString *)message payload:(id)payload when:(NSTimeInterval)when;

/**
    @name Listening to events
 */
/**
 *  Declare an interest and provide a callback to an event
 *
 *  The first paramter in the callback block will always be the object that invoked this message.
 *  This should be enough to prevent any need for declaring weak self pointers in order to use in 
 *  block.
 *
 *  @warning Do not use `self` pointers in the callback block, this is guaranteed to cause a circular reference
 *  @param message Name of the event ((see kNotification* strings)
 *  @param block   Block to call when the event is triggered.
 */
-(void)registerForBroadcast:(NSString *)message
                            block:(VSBroadcastBlock)block;

/**
 *  Declare an interest and provide a callback to any number of events
 *
 *  The second paramter in the callback block will always be the object that invoked this message.
 *  This should be enough to prevent any need for declaring weak self pointers in order to use in
 *  block.
 *
 *  @warning Do not use `self` pointers in the callback block, this is guaranteed to cause a circular reference
 *  @param message Name of the event (see kNotification* strings)
 *  @param block   Block to call when the event is triggered.
 */
-(void)registerForBroadcasts:(NSArray *)messages
                             block:(VSBroadcastsBlock)block;

@end
