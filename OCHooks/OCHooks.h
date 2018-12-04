//
//  OCHooks.h
//  OCHooksDemo
//
//  Created by Hanran on 2018/12/3.
//  Copyright © 2018 rannn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^OCHStateChangeHandler)(id newValue, id oldValue);
typedef dispatch_block_t OCHEffectHandler;

typedef NS_ENUM(NSInteger, OCHooksType) {
    OCHooksTypeState = 0,
    OCHooksTypeEffect
};

@interface OCHooks : NSObject

@property (nonatomic, assign, readonly) OCHooksType type;
@property (nonatomic, strong) id value;

+ (OCHooks *)useState:(id)startValue;
- (void)setValue:(id)value;
- (void)addChangeHandler:(OCHStateChangeHandler)handler;

+ (OCHooks *)useEffect;
- (OCHooks *)loaded:(OCHEffectHandler)loaded;
- (OCHooks *)appear:(OCHEffectHandler)appear;
- (OCHooks *)disappear:(OCHEffectHandler)disappear;
- (OCHooks *)cleanup:(OCHEffectHandler)cleanup;

@end

@interface UIViewController (OCHooks)

- (void)OCH_installHooks:(NSArray<OCHooks *> *)hooks;
- (void)OCH_uninstallHooks;

@end
