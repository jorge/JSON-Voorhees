//
//  NSObject+Parser.h
//  Telemetry-iOS
//
//  Created by Jorge Chao on 9/26/13.
//  Copyright (c) 2013 University of New Orleans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <objc/runtime.h>

#define FT_SAVE_MOC(_ft_moc) \
do { \
  NSError* _ft_save_error; \
  if(![_ft_moc save:&_ft_save_error]) { \
    NSLog(@"Failed to save to data store: %@", [_ft_save_error localizedDescription]); \
    NSArray* _ft_detailedErrors = [[_ft_save_error userInfo] objectForKey:NSDetailedErrorsKey]; \
    if(_ft_detailedErrors != nil && [_ft_detailedErrors count] > 0) { \
      for(NSError* _ft_detailedError in _ft_detailedErrors) { \
        NSLog(@"DetailedError: %@", [_ft_detailedError userInfo]); \
      } \
    } \
    else { \
      NSLog(@"%@", [_ft_save_error userInfo]); \
    } \
  } \
} while(0);


@interface NSObject (Parser)


+ (NSArray *)parseArray:(NSArray *)arrayOfJSON
             keyMapping:(NSDictionary *)mapping
               forClass:(NSString *)klass
 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)parseArray:(NSArray *)arrayOfJSON
             keyMapping:(NSDictionary *)mapping
               forClass:(NSString *)klass
 inManagedObjectContext:(NSManagedObjectContext *)context
           forUniqueKeys:(NSDictionary *)uniqKeys;



+ (NSManagedObject *)parseDictionary:(NSDictionary *)JSON
                          keyMapping:(NSDictionary *)mapping
                         forInstance:(NSManagedObject *)managedObject;


@end
