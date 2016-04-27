//
//  ZYXNote.h
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/27.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <CoreData/CoreData.h>

@class ZYXContact;

@interface ZYXNote : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) ZYXContact *noteFor;

@end
