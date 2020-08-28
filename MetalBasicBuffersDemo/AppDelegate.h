//
//  AppDelegate.h
//  MetalBasicBuffersDemo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

