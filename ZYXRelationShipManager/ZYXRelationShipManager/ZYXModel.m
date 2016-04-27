//
//  ZYXModel.m
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXModel.h"

@interface ZYXModel ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation ZYXModel

+ (ZYXModel *)sharedModel
{
    static ZYXModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self managedObjectContext];
    }
    
    return self;
}

- (NSArray *)notesForContact:(ZYXContact *)contact
{
    return nil;
}

- (NSArray *)contacts
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ZYXContact"];
    NSSortDescriptor *sortLast = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSSortDescriptor *sortFirst = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    request.sortDescriptors = [NSArray arrayWithObjects:sortLast, sortFirst, nil];
    
    NSError *error = nil;
    NSArray *contacts = [_managedObjectContext executeFetchRequest:request error:&error];
    
    return contacts;
}

- (ZYXContact *)contactWithEmailAddress:(NSString *)emailAddress
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ZYXContact"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailAddress = %@", emailAddress];
    request.predicate = predicate;
    
    NSSortDescriptor *sortEmail = [[NSSortDescriptor alloc] initWithKey:@"emailAddress" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    request.sortDescriptors = @[sortEmail];
    
    NSError *error = nil;
    NSArray *contacts = [_managedObjectContext executeFetchRequest:request error:&error];
    if (!contacts || [contacts count] > 1)
    {
        return nil;
    }
    
    return [contacts lastObject];
}

- (BOOL)addContactWithFirstName:(NSString *)firstName lastName:(NSString *)lastName company:(NSString *)company emailAddress:(NSString *)emailAddress phoneNumber:(NSString *)phoneNumber andNote:(NSString *)note
{
    ZYXContact *uniqueCheck = [self contactWithEmailAddress:emailAddress];
    if (uniqueCheck)
    {
        return NO;
    }
    
    ZYXContact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"ZYXContact" inManagedObjectContext:_managedObjectContext];
    
    contact.firstName = firstName;
    contact.lastName = lastName;
    contact.company = company;
    contact.emailAddress = emailAddress;
    contact.phoneNumber = phoneNumber;
    
    [self saveContext];
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RelationshipModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RelationshipManager.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedContext = _managedObjectContext;
    if (managedContext != nil)
    {
        if ([managedContext hasChanges] && ![managedContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)scheduleNotificationWithFireDate:(NSDate *)fireDate timeZone:(NSTimeZone *)timeZone repeatInterval:(NSCalendarUnit)repeatInterval alertBody:(NSString *)alertBody alertAction:(NSString *)alertAction launchImage:(NSString *)launchImage soundName:(NSString *)soundName badgeNumber:(NSInteger)badgeNumber andUserInfo:(NSDictionary *)userInfo
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = fireDate;
    notification.timeZone = timeZone;
    notification.repeatInterval = repeatInterval;
    notification.alertBody = alertBody;
    notification.alertLaunchImage = launchImage;
    notification.soundName = soundName;
    notification.applicationIconBadgeNumber = badgeNumber;
    notification.userInfo = userInfo;
    
    if (alertAction == nil)
    {
        notification.hasAction = NO;
    }
    else
    {
        notification.alertAction = alertAction;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    });
}

- (void)scheduleContactFollowUpForContact:(ZYXContact *)contact onDate:(NSDate *)date withBody:(NSString *)body andAction:(NSString *)action
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:contact.emailAddress, @"emailAddress", contact.phoneNumber, @"phoneNumber", @"contaceProfile", @"type", action, @"action", nil];
    
    [self scheduleNotificationWithFireDate:date timeZone:[NSTimeZone systemTimeZone] repeatInterval:0 alertBody:body alertAction:action launchImage:@"" soundName:nil badgeNumber:1 andUserInfo:userInfo];
}

- (NSArray *)notificationsForContact:(ZYXContact *)contact
{
    NSMutableArray *contactNotifications = [[NSMutableArray alloc] init];
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduledNotifications)
    {
        if ([notification.userInfo objectForKey:@"emailAddress"])
        {
            [contactNotifications addObject:notification];
        }
    }
    
    return contactNotifications;
}

- (void)cancelNotificationsForContact:(ZYXContact *)contact
{
    NSArray *notificatons = [self notificationsForContact:contact];
    for (UILocalNotification *notification in notificatons)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

@end
