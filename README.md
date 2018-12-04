# OCHooks
An Objective-C Hooks Like React Hooks

## Usage

#### State 

* Create

```Objective-C
OCHooks *count = [OCHooks useState:@(0)];
[count addChangeHandler:^(id newValue, id oldValue) {
    NSLog(@"change count old: %@, new: %@", oldValue, newValue);
}];
self.count = count;
```

* Change Value

```Objective-C
self.count.value = @(1);
```

#### Effect

* Create

```Objective-C
OCHooks *effectHooks = [OCHooks useEffect];
[effectHooks appear:^{
    NSLog(@"appear");
}];
[effectHooks disappear:^{
    NSLog(@"disappear");
}];
```

#### Install and Uninstall

```
// after create Hooks
[self OCH_installHooks:@[count, effectHooks]];
// clean up like -dealloc
[self OCH_uninstallHooks];
```

## Lisence
**MIT**


