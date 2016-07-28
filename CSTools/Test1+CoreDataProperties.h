//
//  Test1+CoreDataProperties.h
//  CSTools
//
//  Created by feng jia on 16/1/30.
//  Copyright © 2016年 caishi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Test1.h"

NS_ASSUME_NONNULL_BEGIN

@interface Test1 (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *attr1;
@property (nullable, nonatomic, retain) NSNumber *attr2;

@end

NS_ASSUME_NONNULL_END
