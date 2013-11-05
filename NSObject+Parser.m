//
//  NSObject+Parser.m
//
//  Created by Jorge Chao on 9/26/13.
//

#import "NSObject+Parser.h"

@implementation NSObject (Parser)


// returns an array of NSManagedObjects
+ (NSArray *)parseArray:(NSArray *)arrayOfJSON
             keyMapping:(NSDictionary *)mapping
               forClass:(NSString *)klass
 inManagedObjectContext:(NSManagedObjectContext *)context {
  
//  NSError *error;
  NSArray *results = [[NSArray alloc] init];
  for (NSDictionary *dict in arrayOfJSON) {
    NSManagedObject *obj = [[NSClassFromString(klass) alloc] initWithEntity:[NSEntityDescription entityForName:klass inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    
    
    [NSObject parseDictionary:dict keyMapping:mapping forInstance:obj];
    results = [results arrayByAddingObject:obj];
  }
  
  return results;
}


//only works with core data objects right now
+ (NSManagedObject *)parseDictionary:(NSDictionary *)JSON
                          keyMapping:(NSDictionary *)mapping
                         forInstance:(NSManagedObject *)managedObject {
  
  for (NSString *key in mapping) {
    objc_property_t prop = class_getProperty([managedObject class], [mapping[key] UTF8String]);
    const char * propAttr = property_getAttributes(prop);
    NSString *propString = [NSString stringWithUTF8String:propAttr];
    NSArray *components = [propString componentsSeparatedByString:@","];
    NSString *attrClass = components[0];
    if (![JSON[key] isKindOfClass:[NSNull class]]) {
      
      if ([attrClass isEqualToString:@"T@\"NSDecimalNumber\""]) {
        [managedObject setValue:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[JSON[key] doubleValue]]
                         forKey:mapping[key]];
      }
      //boolean
      else if ([attrClass isEqualToString:@"Tc"]) {
        [managedObject setValue:[NSNumber numberWithInt:[JSON[key] intValue]] forKey:mapping[key]];
      }
      else if ([attrClass isEqualToString:@"T@\"NSDate\""]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        [managedObject setValue:[formatter dateFromString:JSON[key]] forKey:mapping[key]];
      }
      else {
        [managedObject setValue:JSON[key] forKey:mapping[key]];
      }
    }
    else { //value is null
      if ([attrClass isEqualToString:@"T@\"NSString\""]) { //it is a string
        [managedObject setValue:@"" forKey:mapping[key]];
      }
      
      else { //it is something else
        [managedObject setValue:@0 forKey:mapping[key]];
      }
    }
  }
  return managedObject;
}

//same as above, but with parameter for uniqueness properties.
+ (NSArray *)parseArray:(NSArray *)arrayOfJSON
             keyMapping:(NSDictionary *)mapping
               forClass:(NSString *)klass
 inManagedObjectContext:(NSManagedObjectContext *)context
          forUniqueKeys:(NSDictionary *)uniqKeys {
  
  NSArray *results = [[NSArray alloc] init];
  for (NSDictionary *dict in arrayOfJSON) {
    NSManagedObject *obj;
    NSError *error;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:klass inManagedObjectContext:context]];
    for (NSString *key in uniqKeys) {
      [fetch setPredicate:[NSPredicate predicateWithFormat:@"%K == %i", uniqKeys[key], [dict[[uniqKeys allKeysForObject:uniqKeys[key]][0]] intValue]]];
    }
    NSArray *objects = [context executeFetchRequest:fetch error:&error];
    if (objects.count > 0) {
      obj = objects[0];
    }
    else {
      obj = [[NSClassFromString(klass) alloc] initWithEntity:[NSEntityDescription entityForName:klass inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    }
    [NSObject parseDictionary:dict keyMapping:mapping forInstance:obj];
    results = [results arrayByAddingObject:obj];
    
  }
  
  return results;
}


@end
