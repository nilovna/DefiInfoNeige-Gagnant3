//
//  HomeViewController.m
//  ChasseTaNeige
//
//  Created by Van Du Tran on 2014-08-07.
//  Copyright (c) 2014 Groupe Independant. All rights reserved.
//

#import "HomeViewController.h"
#import "Person.h"
@import MapKit;
@import MessageUI;

@interface HomeViewController () <MKMapViewDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *needHelpButton;
@property (strong, nonatomic) NSMutableArray *peopleThatNeedHelp;
@property (strong, nonatomic) Person *me;
@end

@implementation HomeViewController {
    BOOL centerOnUser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    centerOnUser = YES;
    
    self.title = @"Chasse ta neige";
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.peopleThatNeedHelp = [[NSMutableArray alloc] init];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Map View Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    else if ([annotation isKindOfClass:[Person class]]) {
        MKAnnotationView *annView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Shoveler"];
        
        if (!annView) {
            annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Shoveler"];
        }
        
        Person *person = (Person *)annotation;
        
        if ([person.name isEqualToString:@"Van Du Tran"]) {
            annView.image = [UIImage imageNamed:@"pin-me"];
        }
        else {
            annView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pin-%@", person.aide]];
        }
        
        UIButton *advertButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [advertButton setBackgroundImage:[UIImage imageNamed:@"button-provide-help"] forState:UIControlStateNormal];
        
        annView.rightCalloutAccessoryView = advertButton;
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:person.name]];
        iv.frame = CGRectMake(0, 0, 44, 44);
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        annView.leftCalloutAccessoryView = iv;
        
        annView.canShowCallout = YES;
         
        return annView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Votre appareil ne supporte pas les SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    
    Person *shoveler = (Person *)view.annotation;
    NSArray *recipents = @[shoveler.phone];
    NSString *message = [NSString stringWithFormat:@"Je m'en viens avec ma pelle!"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (centerOnUser) {
        CLLocationCoordinate2D cityCoord = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        [self.mapView setCenterCoordinate:cityCoord animated:YES];
        MKMapCamera *newCamera = [[self.mapView camera] copy];
        [newCamera setAltitude:5000.0];
        [newCamera setPitch:45.0];
        [self.mapView setCamera:newCamera animated:NO];
        centerOnUser = NO;
        [self performSelector:@selector(stopTrackingUser) withObject:nil afterDelay:5.0f];
        self.me = [[Person alloc] init];
        self.me.name = @"Van Du Tran";
        self.me.email = @"vandutran@gmail.com";
        self.me.phone = @"514-963-2212";
        self.me.aide = @"shovel";
        self.me.note = @"J'ai besoin d'aide pour déneiger";
        self.me.latitude = [NSNumber numberWithDouble:[self.mapView userLocation].coordinate.latitude];
        self.me.longitude = [NSNumber numberWithDouble:[self.mapView userLocation].coordinate.longitude];
    }
}

- (void)stopTrackingUser
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

#pragma mark - Message Composer Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Ne peux envoyer le SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            NSLog(@"0");
        }
        else {
            NSLog(@"1");
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Aide lancée" message:@"Vos voisins à proximité ont été notifié afin de vous venir en aide.\n\nCroisez les doigts, ils viendront vous aider s'ils sont disponibles." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            av.tag = 2;
            [self.mapView addAnnotation:self.me];
            self.needHelpButton.selected = YES;
            [av show];
        }
    }
    else if (alertView.tag == 2) {
        
    }
    else if (alertView.tag == 3) {
        if (buttonIndex == 0) {
            NSLog(@"0");
        }
        else {
            [self.mapView removeAnnotation:self.me];
            self.needHelpButton.selected = NO;
        }
    }
}

- (void)refresh
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://mobicloo.com/ChasseTaNeige/shovelers.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [self.peopleThatNeedHelp removeAllObjects];
        
        NSArray *shovelers = json[@"shovelers"];
        for (NSDictionary *shoveler in shovelers) {
            Person *s = [[Person alloc] init];
            s.email = shoveler[@"email"];
            s.name = shoveler[@"name"];
            s.phone = shoveler[@"phone"];
            s.latitude = shoveler[@"latitude"];
            s.longitude = shoveler[@"longitude"];
            s.aide = shoveler[@"help"];
            s.note = shoveler[@"note"];
            [self.peopleThatNeedHelp addObject:s];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self.mapView addAnnotations:self.peopleThatNeedHelp];
        });
    }];
    
    [dataTask resume];
}

- (IBAction)needHelpShovelingButtonTapped:(id)sender
{
    UIButton *b = (UIButton *)sender;
    if (!b.selected) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"J'ai besoin d'aide" message:@"Vous avez besoin d'aide pour deneiger?" delegate:self cancelButtonTitle:@"ANNULER" otherButtonTitles:@"OUI", nil];
        av.tag = 1;
        [av show];
    }
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Je n'ai plus besoin d'aide" message:@"Annuler votre demande d'aide?" delegate:self cancelButtonTitle:@"NON" otherButtonTitles:@"OUI", nil];
        av.tag = 3;
        [av show];
    }
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [self refresh];
}

- (IBAction)centerOnUserButtonTapped:(id)sender
{
    CLLocationCoordinate2D cityCoord = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:cityCoord animated:YES];
}

@end
