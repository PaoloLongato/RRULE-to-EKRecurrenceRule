//
//  EKRecurrenceRule+RRULE.m
//  RRULE
//
//  Created by Jochen Schöllig on 24.04.13.
//  Copyright (c) 2013 Jochen Schöllig. All rights reserved.
//

#import "EKRecurrenceRule+RRULE.h"

static NSDateFormatter *dateFormatter = nil;

@implementation EKRecurrenceRule (RRULE)

- (EKRecurrenceRule *)initWithString:(NSString *)rfc2445String{
    // If the date formatter isn't already set up, create it and cache it for reuse.
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    // Begin parsing
    NSArray *components = [rfc2445String.uppercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";="]];

    EKRecurrenceFrequency frequency = EKRecurrenceFrequencyDaily;
    NSInteger interval              = 1;
    NSMutableArray *daysOfTheWeek   = nil;
    NSMutableArray *daysOfTheMonth  = nil;
    NSMutableArray *monthsOfTheYear = nil;
    NSMutableArray *daysOfTheYear   = nil;
    NSMutableArray *weeksOfTheYear  = nil;
    NSMutableArray *setPositions    = nil;
    EKRecurrenceEnd *recurrenceEnd  = nil;
    
    for (int i = 0; i < components.count; i++)
    {
        NSString *component = [components objectAtIndex:i];
        
        // Frequency
        if ([component isEqualToString:@"FREQ"])
        {
            NSString *frequencyString = [components objectAtIndex:++i];
            
            if      ([frequencyString isEqualToString:@"DAILY"])   frequency = EKRecurrenceFrequencyDaily;
            else if ([frequencyString isEqualToString:@"WEEKLY"])  frequency = EKRecurrenceFrequencyWeekly;
            else if ([frequencyString isEqualToString:@"MONTHLY"]) frequency = EKRecurrenceFrequencyMonthly;
            else if ([frequencyString isEqualToString:@"YEARLY"])  frequency = EKRecurrenceFrequencyYearly;
        }
    
        // Interval
        if ([component isEqualToString:@"INTERVAL"])
        {
            interval = [[components objectAtIndex:++i] intValue];
        }
        
        // Days of the week
        if ([component isEqualToString:@"BYDAY"])
        {
            daysOfTheWeek = [NSMutableArray array];
            NSArray *dayStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *dayString in dayStrings)
            {
                int dayOfWeek = 0;
                int weekNumber = 0;
                
                // Parse the day of the week
                if ([dayString rangeOfString:@"SU"].location != NSNotFound)      dayOfWeek = EKSunday;
                else if ([dayString rangeOfString:@"MO"].location != NSNotFound) dayOfWeek = EKMonday;
                else if ([dayString rangeOfString:@"TU"].location != NSNotFound) dayOfWeek = EKTuesday;
                else if ([dayString rangeOfString:@"WE"].location != NSNotFound) dayOfWeek = EKWednesday;
                else if ([dayString rangeOfString:@"TH"].location != NSNotFound) dayOfWeek = EKThursday;
                else if ([dayString rangeOfString:@"FR"].location != NSNotFound) dayOfWeek = EKFriday;
                else if ([dayString rangeOfString:@"SA"].location != NSNotFound) dayOfWeek = EKSaturday;
                
                // Parse the week number
                weekNumber = [[dayString substringToIndex:dayString.length-2] intValue];
  
                [daysOfTheWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:dayOfWeek weekNumber:weekNumber]];
            }
        }
        
        // Days of the month
        if ([component isEqualToString:@"BYMONTHDAY"])
        {
            daysOfTheMonth = [NSMutableArray array];
            NSArray *dayStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *dayString in dayStrings)
            {
                [daysOfTheMonth addObject:[NSNumber numberWithInt:dayString.intValue]];
            }
        }
        
        // Months of the year
        if ([component isEqualToString:@"BYMONTH"])
        {
            monthsOfTheYear = [NSMutableArray array];
            NSArray *monthStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *monthString in monthStrings)
            {
                [monthsOfTheYear addObject:[NSNumber numberWithInt:monthString.intValue]];
            }
        }
        
        // Weeks of the year
        if ([component isEqualToString:@"BYWEEKNO"])
        {
            weeksOfTheYear = [NSMutableArray array];
            NSArray *weekStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *weekString in weekStrings)
            {
                [weeksOfTheYear addObject:[NSNumber numberWithInt:weekString.intValue]];
            }
        }
        
        // Days of the year
        if ([component isEqualToString:@"BYYEARDAY"])
        {
            daysOfTheYear = [NSMutableArray array];
            NSArray *dayStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *dayString in dayStrings)
            {
                [daysOfTheYear addObject:[NSNumber numberWithInt:dayString.intValue]];
            }
        }
        
        // Set positions
        if ([component isEqualToString:@"BYSETPOS"])
        {
            setPositions = [NSMutableArray array];
            NSArray *positionStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *potitionString in positionStrings)
            {
                [setPositions addObject:[NSNumber numberWithInt:potitionString.intValue]];
            }
        }
        
        // RecurrenceEnd
        if ([component isEqualToString:@"COUNT"])
        {
            NSUInteger occurenceCount = [[components objectAtIndex:++i] intValue];
            recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:occurenceCount];
            
        } else if ([component isEqualToString:@"UNTIL"])
        {
            NSDate *endDate =  [dateFormatter dateFromString:[components objectAtIndex:++i]];
            recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:endDate];
        }
    }
    
    return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency
                                                        interval:interval
                                                   daysOfTheWeek:daysOfTheWeek
                                                  daysOfTheMonth:daysOfTheMonth
                                                 monthsOfTheYear:monthsOfTheYear
                                                  weeksOfTheYear:weeksOfTheYear
                                                   daysOfTheYear:daysOfTheYear
                                                    setPositions:setPositions
                                                             end:recurrenceEnd];
}

- (NSString *)rfc2445String{
    // If the date formatter isn't already set up, create it and cache it for reuse.
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    

    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:200];
    
    EKRecurrenceFrequency frequency = EKRecurrenceFrequencyDaily;
    NSInteger interval              = self.interval;
    NSArray *daysOfTheWeek   = self.daysOfTheWeek;
    NSArray *daysOfTheMonth  = self.daysOfTheMonth;
    NSArray *monthsOfTheYear = self.monthsOfTheYear;
    NSArray *daysOfTheYear   = self.daysOfTheYear;
    NSArray *weeksOfTheYear  = self.weeksOfTheYear;
    NSArray *setPositions    = self.setPositions;
    
    EKRecurrenceEnd *recurrenceEnd  = self.recurrenceEnd;
    
    // Frequency:
    switch (frequency) {
        case EKRecurrenceFrequencyDaily:
        [string appendString:@"FREQ=DAILY;"];
        break;
        case EKRecurrenceFrequencyWeekly:
        [string appendString:@"FREQ=WEEKLY;"];
        break;
        case EKRecurrenceFrequencyMonthly:
        [string appendString:@"FREQ=MONTHLY;"];
        break;
        case EKRecurrenceFrequencyYearly:
        [string appendString:@"FREQ=YEARLY;"];
        break;
        default:
        break;
    }
    
    // Interval:
    if (interval > 0) {
        [string appendFormat:@"FREQ=%li;", (long)interval];
    }

    if (daysOfTheWeek && daysOfTheWeek.count) {
        
        [string appendString:@"BYDAY="];
        
        int i = 0;
        
        for (EKRecurrenceDayOfWeek *dayOfTheWeek in daysOfTheWeek) {
            
            NSInteger dayOfWeek = dayOfTheWeek.dayOfTheWeek;
            
            if (i > 0) {
                [string appendString:@","];
            }
            
            switch (dayOfWeek) {
                case EKSunday:
                [string appendString:@"SU"];
                break;
                case EKMonday:
                [string appendString:@"MO"];
                break;
                case EKTuesday:
                [string appendString:@"TU"];
                break;
                case EKWednesday:
                [string appendString:@"WE"];
                break;
                case EKThursday:
                [string appendString:@"TH"];
                break;
                case EKFriday:
                [string appendString:@"FR"];
                break;
                case EKSaturday:
                [string appendString:@"SA"];
                break;
            }
            
            // TODO: Add weekNumber support!
            NSInteger weekNumber = dayOfTheWeek.weekNumber;
            
            
            i++;
        }
        
        [string appendString:@";"];
    }
    
    
    // Days of the month
    if (daysOfTheMonth && daysOfTheMonth.count) {
        
        [string appendString:@"BYMONTHDAY="];
        
        int i = 0;
        
        for (NSNumber *dayNr in daysOfTheMonth) {
            
            
            if (i > 0) {
                [string appendString:@","];
            }
            
            [string appendString:[NSString stringWithFormat:@"%li", (long)[dayNr integerValue]]];
            
            i++;
        }
        
        [string appendString:@";"];
    }
    
    // Months of the year
    if (monthsOfTheYear && monthsOfTheYear.count) {
        
        [string appendString:@"BYMONTH="];
        
        int i = 0;
        
        for (NSNumber *monthNr in monthsOfTheYear) {
            
            
            if (i > 0) {
                [string appendString:@","];
            }
            
            [string appendString:[NSString stringWithFormat:@"%li", (long)[monthNr integerValue]]];
            
            i++;
        }
        
        [string appendString:@";"];
    }
    
    // Weeks of the year
    if (weeksOfTheYear && weeksOfTheYear.count) {
        
        [string appendString:@"BYWEEKNO="];
        
        int i = 0;
        
        for (NSNumber *weekNr in weeksOfTheYear) {
            
            
            if (i > 0) {
                [string appendString:@","];
            }
            
            [string appendString:[NSString stringWithFormat:@"%li", (long)[weekNr integerValue]]];
            
            i++;
        }
        
        [string appendString:@";"];
    }

        
    // Days of the year
    if (daysOfTheYear && daysOfTheYear.count) {
        
        [string appendString:@"BYYEARDAY="];
        
        int i = 0;
        
        for (NSNumber *dayNr in daysOfTheYear) {
            
            
            if (i > 0) {
                [string appendString:@","];
            }
            
            [string appendString:[NSString stringWithFormat:@"%li", (long)[dayNr integerValue]]];
            
            i++;
        }
        
        [string appendString:@";"];
    }
    
        // Set positions
    if (setPositions && setPositions.count) {
        
        [string appendString:@"BYYEARDAY="];
        
        int i = 0;
        
        for (NSNumber *positionNr in setPositions) {
            
            
            if (i > 0) {
                [string appendString:@","];
            }
            
            [string appendString:[NSString stringWithFormat:@"%li", (long)[positionNr integerValue]]];
            
            i++;
        }
        
        [string appendString:@";"];
    }
    
    
    if (recurrenceEnd) {
        
        if (recurrenceEnd.occurrenceCount) {
         
            [string appendFormat:@"COUNT=%lu", (unsigned long)recurrenceEnd.occurrenceCount];
        }else if (recurrenceEnd.endDate){
        
            [string appendFormat:@"UNTIL=%@", [dateFormatter stringFromDate:recurrenceEnd.endDate]];
        }
    }

    return string;


}

@end
