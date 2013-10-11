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
        if( !view )
        {
            APLOG(kDebugViews, @"------------------------------------- DUMPING WINDOWS ----------------------------", 0);
            NSArray *windows = [UIApplication sharedApplication].windows;
            for( UIWindow *window in windows )
            {
                APDebugDumpView(window);
            }
        }
        
        static void (^dump)(UIView *,NSString *) = nil;
        
        dump = ^(UIView *view, NSString *indent)
        {
            APDebug(kDebugFire, @"%@%@", indent, view);
            if( ![view isKindOfClass:[UITableView class]] &&
                ![view isKindOfClass:[UINavigationBar class]] &&
                ![view isKindOfClass:[UISegmentedControl class]] &&
                ![view isKindOfClass:[UICollectionView class]] && 
                ![view isKindOfClass:[UISearchBar class]])
            {
                for( UIView * child in view.subviews )
                    dump( child, [NSString stringWithFormat:@"%@    ",indent]);
            }
        };
        if( view )
            dump(view,@"");
        dump = nil;
    }
}

void APDebugDumpControllers(UIViewController *vc)
{
    if( !APENABLED(kDebugViews) )
        return;
    
    printf(" ------------ DUMPING VIEW CONTROLLERS -------------------- \n");
    
    if( !vc )
        vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    static void (^ dumper)(UIViewController *,NSString *);
    
    dumper = ^(UIViewController * vc,NSString *indent)
    {
        NSString * str = [NSString stringWithFormat:@"%@%@ \n%@ {\n%@   presenting: %@\n%@   presented: %@\n%@   navigation: %@\n%@ }",
                          indent, vc,
                          indent,
                          indent, vc.presentingViewController,
                          indent, vc.presentedViewController,
                          indent, vc.navigationController,
                          indent
                          ];
        printf("%s\n",[str UTF8String]);
        
        if( vc.presentedViewController && (vc.presentedViewController.presentingViewController == vc) )
        {
            dumper(vc.presentedViewController,[indent stringByAppendingString:@"   "]);
        }
        
        if( [vc isKindOfClass:[UINavigationController class ]] )
        {
            UINavigationController * nav = (UINavigationController *)vc;
            NSString * str = [NSString stringWithFormat:@"%@Nav[%d controllers]: {\n%@   topVC: %@\n%@   presented: %@\n%@ }",
                              indent, [nav.viewControllers count],
                              indent, nav.topViewController,
                              indent, nav.presentedViewController,
                              indent
                              ];
            printf("%s\n",[str UTF8String]);
        }
        
        // Get the subviews of the view
        NSArray *subVCs = [vc childViewControllers];
        
        // Return if there are no subviews
        if ([subVCs count] == 0) return;
        
        for (UIViewController *vc in subVCs)
        {
            dumper(vc,[indent stringByAppendingString:@"   "]);
        }
    };
    
    dumper(vc,@"   ");
    
    dumper = nil;
}
#endif