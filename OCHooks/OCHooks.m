//
//  OCHooks.m
//  OCHooksDemo
//
//  Created by Hanran on 2018/12/3.
//  Copyright © 2018 rannn. All rights reserved.
//

#import "OCHooks.h"
#import <objc/runtime.h>

#define HooksManager [OCHooksManager manager]

@interface OCHooksManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *hooksMap;

+ (instancetype)manager;

- (NSArray<OCHooks *> *)queryHooksInViewController:(UIViewController *)viewController;

- (void)enrollHooks:(NSArray<OCHooks *> *)hooks withViewController:(UIViewController *)viewController;
- (void)delistHooks:(UIViewController *)viewController;

@end


@interface OCHooks ()

@property (nonatomic, assign, readwrite) OCHooksType type;

@property (nonatomic, strong) NSMutableArray<OCHStateChangeHandler> *stateHandlers;

@property (nonatomic, copy) OCHEffectHandler loadedHandler;
@property (nonatomic, copy) OCHEffectHandler appearHandler;
@property (nonatomic, copy) OCHEffectHandler disappearHandler;
@property (nonatomic, copy) OCHEffectHandler cleanUpHandler;

@end

@implementation OCHooks

+ (OCHooks *)useState:startValue {
    OCHooks *hooks = [OCHooks new];
    hooks.type = OCHooksTypeState;
    hooks.value = startValue;
    return hooks;
}

- (void)setType:(OCHooksType)type {
    _type = type;
    if (type == OCHooksTypeState) {
        _stateHandlers = [NSMutableArray array];
    }
}

- (void)setValue:(id)value {
    id oldValue = _value;
    _value = value;
    for (OCHStateChangeHandler handler in self.stateHandlers) {
        handler(value, oldValue);
    }
}

- (void)addChangeHandler:(OCHStateChangeHandler)handler {
    if (self.value) {
        handler(self.value, nil);
    }
    [self.stateHandlers addObject:handler];
}

+ (OCHooks *)useEffect {
    OCHooks *hooks = [OCHooks new];
    hooks.type = OCHooksTypeEffect;
    return hooks;
}

- (OCHooks *)loaded:(OCHEffectHandler)loaded {
    self.loadedHandler = loaded;
    return self;
}

- (OCHooks *)appear:(OCHEffectHandler)appear {
    self.appearHandler = appear;
    return self;
}

- (OCHooks *)disappear:(OCHEffectHandler)disappear {
    self.disappearHandler = disappear;
    return self;
}

- (OCHooks *)cleanup:(OCHEffectHandler)cleanup {
    self.cleanUpHandler = cleanup;
    return self;
}

@end


static void * kOCHooksKey = &kOCHooksKey;

@implementation UIViewController (OCHooks)

+ (BOOL)OCH_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    return YES;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self OCH_swizzleInstanceMethod:@selector(viewDidLoad) with:@selector(OCH_viewDidLoad)];
        [self OCH_swizzleInstanceMethod:@selector(viewWillAppear:) with:@selector(OCH_viewWillAppear:)];
        [self OCH_swizzleInstanceMethod:@selector(viewDidDisappear:) with:@selector(OCH_viewDidDisappear:)];
    });
}

- (void)OCH_viewDidLoad {
    [self OCH_viewDidLoad];
    NSArray<OCHooks *> *hooksList = [HooksManager queryHooksInViewController:self];
    for (OCHooks *hooks in hooksList) {
        if (hooks.type == OCHooksTypeEffect && hooks.loadedHandler) {
            hooks.loadedHandler();
        }
    }
}

- (void)OCH_viewWillAppear:(BOOL)animated {
    [self OCH_viewWillAppear:animated];
    NSArray<OCHooks *> *hooksList = [HooksManager queryHooksInViewController:self];
    for (OCHooks *hooks in hooksList) {
        if (hooks.type == OCHooksTypeEffect && hooks.appearHandler) {
            hooks.appearHandler();
        }
    }
}

- (void)OCH_viewDidDisappear:(BOOL)animated {
    [self OCH_viewDidDisappear:animated];
    NSArray<OCHooks *> *hooksList = [HooksManager queryHooksInViewController:self];
    for (OCHooks *hooks in hooksList) {
        if (hooks.type == OCHooksTypeEffect && hooks.disappearHandler) {
            hooks.disappearHandler();
        }
    }
}

- (void)OCH_installHooks:(NSArray<OCHooks *> *)hooks {
    [HooksManager enrollHooks:hooks withViewController:self];
}

- (void)OCH_uninstallHooks {
    NSArray<OCHooks *> *hooksList = [HooksManager queryHooksInViewController:self];
    for (OCHooks *hooks in hooksList) {
        if (hooks.type == OCHooksTypeEffect && hooks.cleanUpHandler) {
            hooks.cleanUpHandler();
        }
    }
    [HooksManager delistHooks:self];
}

@end



@implementation OCHooksManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static OCHooksManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[OCHooksManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hooksMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<OCHooks *> *)queryHooksInViewController:(UIViewController *)viewController {
    NSString *key = [@((uintptr_t)viewController) stringValue];
    return self.hooksMap[key];
}

- (void)enrollHooks:(NSArray<OCHooks *> *)hooks withViewController:(UIViewController *)viewController {
    NSString *key = [@((uintptr_t)viewController) stringValue];
    self.hooksMap[key] = hooks;
}

- (void)delistHooks:(UIViewController *)viewController {
    NSString *key = [@((uintptr_t)viewController) stringValue];
    [self.hooksMap removeObjectForKey:key];
}

@end

