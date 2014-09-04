//
//  ViewController.m
//  InfoNeigeObjC
//
//  Created by Van Du Tran on 2014-07-29.
//  Copyright (c) 2014 Van Du Tran. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;
@import MapKit;

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.delegate = self;
    
    [self countriesOverlays];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)countriesOverlays {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"cote" ofType:@"json"];
    NSData *overlayData = [NSData dataWithContentsOfFile:fileName];
    
    NSArray *sides = [[NSJSONSerialization JSONObjectWithData:overlayData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"features"];
    
//    NSMutableArray *overlays = [NSMutableArray array];
    
    for (NSDictionary *side in sides) {
        
        NSDictionary *geometry = side[@"geometry"];
        if ([geometry isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        if ([geometry[@"type"] isEqualToString:@"LineString"]) {
            NSArray *coordinates = geometry[@"coordinates"];
            
            CLLocationCoordinate2D *pointArr = malloc(sizeof(CLLocationCoordinate2D) * [coordinates count]);
            
            int idx = 0;
            for (NSArray *coordinate in coordinates) {
            
                pointArr[idx] = CLLocationCoordinate2DMake([coordinate[0] doubleValue], [coordinate[1] doubleValue]);
                idx++;
            }
            
            MKPolyline *path = [MKPolyline polylineWithCoordinates:pointArr count:[coordinates count]];
            path.title = side[@"properties"][@"NOM_VOIE"];
            [self.mapView addOverlay:path level:MKOverlayLevelAboveRoads];
//            [overlays addObject:path];
            
            
            
            
//            MKPolygon *polygon = [HHLViewController overlaysFromPolygons:geometry[@"coordinates"] id:country[@"properties"][@"name"]];
//            if (polygon) {
//                [overlays addObject:polygon];
//            }
            
        }
//        } else if ([geometry[@"type"] isEqualToString:@"MultiPolygon"]){
//            for (NSArray *polygonData in geometry[@"coordinates"]) {
//                MKPolygon *polygon = [HHLViewController overlaysFromPolygons:polygonData id:country[@"properties"][@"name"]];
//                if (polygon) {
//                    [overlays addObject:polygon];
//                }
//            }
//        } else {
//            NSLog(@"Unsupported type: %@", geometry[@"type"]);
//        }
    }
    
//    [self.mapView addOverlay:overlays level:MKOverlayLevelAboveRoads];

    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor colorWithRed:74.0/255.0 green:144.0/255.0 blue:226.0/255.0 alpha:1.0f];
        renderer.lineWidth = 6.0f;
        return renderer;
    }
    
    return nil;
}

@end
