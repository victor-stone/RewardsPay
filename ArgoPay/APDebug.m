//
//  APDebug.m
//  ArgoPay
//
//  Created by victor on 9/20/13.
//  Copyright (c) 2013 ArgoPay. All rights reserved.
//

#import "APDebug.h"
#import "APStrings.h"

#ifdef DEBUG

void APDebug(NSString *key,NSString *format,...)
{
    if( [key isEqualToString:kDebugFire] || APENABLED(key) )
    {
        va_list ap;
        va_start (ap, format);
        NSString * str = [[NSString alloc] initWithFormat:format arguments:ap];
        printf("APLog:%s %s\n",[key UTF8String],[str UTF8String]);
        va_end (ap);
    }
}

void APDebugDumpView(UIView *view)
{
    if( APENABLED(kDebugViews) )
    {
        static void (^dump)(UIView *,NSString *) = nil;
        
        dump = ^(UIView *view, NSString *indent)
        {
            APDebug(kDebugFire, @"%@%@", indent, view);
            if( ![view isKindOfClass:[UITableView class]] &&
                ![view isKindOfClass:[UINavigationBar class]] &&
                ![view isKindOfClass:[UISegmentedControl class]] && 
                ![view isKindOfClass:[UISearchBar class]])
            {
                for( UIView * child in view.subviews )
                    dump( child, [NSString stringWithFormat:@"%@    ",indent]);
            }
        };
        dump(view,@"");
        dump = nil;
    }
}
#endif