//
//  Shoveler.h
//  ChasseTaNeige
//
//  Created by Van Du Tran on 2014-08-10.
//  Copyright (c) 2014 Groupe Independant. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface Person : NSObject <MKAnnotation>
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *aide;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (assign, nonatomic) BOOL available;
@end
