//
//  Shoveler.m
//  ChasseTaNeige
//
//  Created by Van Du Tran on 2014-08-10.
//  Copyright (c) 2014 Groupe Independant. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.note;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

@end
