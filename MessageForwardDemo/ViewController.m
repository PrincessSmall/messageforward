//
//  ViewController.m
//  MessageForwardDemo
//
//  Created by 李敏 on 2021/9/5.
//  Copyright © 2021 李敏. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import "BackupClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}
/* 概念
 在OC中方法调用是一个消息发送的过程
 OC方法最终被生成C函数，并带有一些额外的参数。C函数 objc_msgSend就负责消息发送。
 */

/* 消息发送的主要步骤
 1. 检查这个selector是不是需要忽略
 2. 检查target是不是为nil
 3. 从本类的cache中查找，找到则执行相应的函数实现
 4. 没找到则从方法列表中查找，找到则缓存
 5. 没找到则从父类中查找，一直找到NSObject类为止
 6. 如果还是没有找到，就开始进入动态方法解析和消息转发
 */

/* 动态特性：方法解析和消息转发
 找不到实现方法，抛出异常前的三次处理
 * method resolution
 * fast forwarding
 * normal forwarding
 */

/* 1. method resolution 动态方法解析
 首先，Objective-C 运行时会调用 + (BOOL)resolveInstanceMethod:或者 + (BOOL)resolveClassMethod:，让你有机会提供一个函数实现。如果你添加了函数并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。
*/

void fooMethod(id obj, SEL _cmd)
{
    NSLog(@"Doing foo");
}

+ (BOOL) resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(foo:)) {
        class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

/* 2. Fast forwarding 快速转发
 只需要在指定API方法里面返回一个新对象即可，当然其它的逻辑判断还是要的（比如该SEL是否某个指定SEL？）。
 消息转发机制执行前，runtime系统允许我们替换消息的接收者为其他对象。通过- (id)forwardingTargetForSelector:(SEL)aSelector方法。如果此方法返回的是nil 或者self,则会进入消息转发机制（- (void)forwardInvocation:(NSInvocation *)invocation），否则将会向返回的对象重新发送消息。
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (aSelector == @selector(foo:)) {
        return [[BackupClass alloc]init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

/* 3. normal forwarding 完整消息转发
 与上面不同，可以理解成完整消息转发，是可以代替快速转发做更多的事。
 */

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;
    
    BackupClass *back = [[BackupClass alloc] init];
    if([back respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:back];
    } else {
        [self doesNotRecognizeSelector:sel];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }
    return methodSignature;
}

/* fast forwarding 和 normal forwarding 区别
 需要重载的API方法的用法不同

 * 前者只需要重载一个API即可，后者需要重载两个API。
 * 前者只需在API方法里面返回一个新对象即可，后者需要对被转发的消息进行重签并手动转发给新对象（利用 invokeWithTarget:）。

 转发给新对象的个数不同
 * 前者只能转发一个对象，后者可以连续转发给多个对象。例如下面是完整转发：
 */

/* Objective-C 中给一个对象发送消息会经过以下几个步骤：
 1. 在对象类的 dispatch table 中尝试找到该消息。如果找到了，跳到相应的函数IMP去执行实现代码；
 2. 如果没有找到，Runtime 会发送 +resolveInstanceMethod: 或者 +resolveClassMethod: 尝试去 resolve 这个消息；
 3. 如果 resolve 方法返回 NO，Runtime 就发送 -forwardingTargetForSelector: 允许你把这个消息转发给另一个对象；
 4. 如果没有新的目标对象返回， Runtime 就会发送-methodSignatureForSelector: 和 -forwardInvocation: 消息。你可以发送 -invokeWithTarget: 消息来手动转发消息或者发送 -doesNotRecognizeSelector: 抛出异常。
 */

@end
