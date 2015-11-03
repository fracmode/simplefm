/*
     File: MyViewController.h
 Abstract: 
  Version: 1.8
 
 Disclaimer: 
 
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Library/AudioQueueSynthLibrary.h"

@interface MyViewController : UIViewController <UITextFieldDelegate> {
	
	IBOutlet UITextField *textField;
	IBOutlet UILabel *label;

    IBOutlet UITextField *textBPM;
    IBOutlet UIStepper *stepperBPM;

	NSString *string;

    AudioQueueSynthLibrary *synth;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UITextField *textBPM;
@property (nonatomic, retain) UIStepper *stepperBPM;
@property (nonatomic, copy) NSString *string;

- (void)updateString;

-(IBAction)playAIFF:(id)sender;
-(IBAction)play:(id)sender;
-(IBAction)stop:(id)sender;

-(IBAction)stepperBPMAction:(id)sender;

@end

