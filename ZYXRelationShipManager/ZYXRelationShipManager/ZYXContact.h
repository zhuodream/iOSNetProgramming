//
//  ZYXContact.h
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ZYXNote;
@interface ZYXContact : NSManagedObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSSet *notes;

@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *phoneNumber;

@end


@interface ZYXContact (CoreDataGeneratedAccessors)

- (void)addNotesObject:(ZYXNote *)value;
- (void)removeNotesObject:(ZYXNote *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end