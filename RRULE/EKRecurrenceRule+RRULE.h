//
//  EKRecurrenceRule+RRULE.h
//  RRULE
//
//  Created by Jochen Schöllig on 24.04.13.
//  Copyright (c) 2013 Jochen Schöllig. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface EKRecurrenceRule (RRULE)

// Important notes:
// - EKRecurrenceRule does add WKST=SU automatically
// - EKRecurrenceRule does only support DAILY, WEEKLY, MONTHLY, YEARLY frequencies

@property (strong, nonatomic) NSDate* endDate;
@property (strong, nonatomic) NSDate* startDate;

- (EKRecurrenceRule *)initWithString:(NSString *)rfc2445String;
- (NSString *)rfc2445String;

+ (NSString *)shortLabelFromEKRecurrenceRule:(EKRecurrenceRule *)recurrenceRule;
+ (NSString *)shortLabelFromRRule:(NSString *)rrule;

- (EKEvent*)eventWithRecurrenceRuleFromString:(NSString*)rfc2445String;

@end
