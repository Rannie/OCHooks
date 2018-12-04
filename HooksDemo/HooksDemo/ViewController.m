//
//  ViewController.m
//  HooksDemo
//
//  Created by Hanran on 2018/12/3.
//  Copyright © 2018 rannn. All rights reserved.
//

#import "ViewController.h"
#import "OCHooks.h"

@interface ViewController ()

@property (nonatomic, strong) OCHooks *count;

@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadHooks];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadHooks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.count.value = @(1);
}

- (void)loadHooks {
    OCHooks *effectHooks = [OCHooks useEffect];
    [effectHooks appear:^{
        NSLog(@"appear");
    }];
    [effectHooks disappear:^{
        NSLog(@"disappear");
    }];
    
    OCHooks *count = [OCHooks useState:@(0)];
    [count addChangeHandler:^(id newValue, id oldValue) {
        NSLog(@"change count old: %@, new: %@", oldValue, newValue);
    }];
    self.count = count;
    
    [self OCH_installHooks:@[count, effectHooks]];
}

- (void)dealloc {
    [self OCH_uninstallHooks];
}

@end

