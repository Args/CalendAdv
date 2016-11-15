//
//  ViewController.m
//  CalendAdv
//
//  Created by tih on 16/11/15.
//  Copyright © 2016年 TOSHIBA. All rights reserved.
//

#import "ViewController.h"
#import <EventKit/EventKit.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self syncWithCalendar];
    [self getWithCalendar];

}
-(void)getWithCalendar{
    EKEventStore *store = [[EKEventStore alloc]init];
    NSPredicate *pre = [store predicateForEventsWithStartDate:[[NSDate date] dateByAddingTimeInterval:-800] endDate:[[NSDate date] dateByAddingTimeInterval:800] calendars:nil];
    NSArray *arr = [store eventsMatchingPredicate:pre];
    for (EKEvent *event in arr) {
        for (id item in event.attendees) {
            if ([item isCurrentUser]) {
                continue;
                NSLog(@"是自己");
            }
            NSLog(@"%@",item);
            NSNumber *num = [item valueForKey:@"participantStatus"];
            if ([num isEqualToNumber:@0]) {
                NSLog(@"未处理");
                //            }else if ([num isEqualToNumber:@1]){
                //                NSLog(@"拒绝");
                //            }else if ([num isEqualToNumber:@2]){
                //                NSLog(@"接受");
            }
            else {
                NSLog(@"可能");
                NSString *email = [item valueForKey:@"emailAddress"];
                NSLog(@"email--%@",email);
            }
        }
    }
    
    
}
-(void)syncWithCalendar {
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        EKParticipant *mine = event.organizer;
        [event.organizer setValue:@"xixixi" forKey:@"name"];
        //        [((id)event) setObject:mine forKey:@"organizer"];
        
        event.title = @"你以为这是个广告,其实他不是。"; //give event title you want
        event.notes = @"biubiubiu~";
        //        event.allDay = YES;
        event.startDate = [[NSDate date] dateByAddingTimeInterval:60];
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
        event.calendar = [store defaultCalendarForNewEvents];
        EKAlarm *alerm = [EKAlarm alarmWithRelativeOffset:30];
        [event addAlarm:alerm];
        
        //Do our super clever hack
        NSMutableArray *attendees = [NSMutableArray new];
        for (int i = 0; i < 5; i++) {
            
            //Initialize a EKAttendee object, which is not accessible and inherits from EKParticipant
            Class className = NSClassFromString(@"EKAttendee");
            id attendee = [className new];
            
            //Set the properties of this attendee using setValue:forKey:
            //            [attendee setValue:@"Invitee" forKey:@"firstName"];
            //            [attendee setValue:[NSString stringWithFormat:@"#%i", i + 1] forKey:@"lastName"];
            [attendee setValue:@"some@some.com" forKey:@"emailAddress"];
            
            //Add this attendee to a list so we can assign it to the event
            [attendees addObject:attendee];
        }
        [event setValue:attendees forKey:@"attendees"];
        
        
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
