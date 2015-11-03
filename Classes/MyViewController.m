/*
     File: MyViewController.m
 Abstract: 
  Version: 1.8
 
 Disclaimer: 
 
 */

#import "MyViewController.h"


@implementation MyViewController

@synthesize textField;
@synthesize label;
@synthesize string;
@synthesize textBPM;
@synthesize stepperBPM;

void systemSoundCompletionProcFunction( SystemSoundID ssID, void* clientData ) {
    NSLog(@"play did end");
    //ssIDを解放する
    AudioServicesDisposeSystemSoundID(ssID);
}



- (void)viewDidLoad {
    // When the user starts typing, show the clear button in the text field.
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    // When the view first loads, display the placeholder text that's in the
    // text field in the label.
    label.text = textField.placeholder;

    synth = [ [AudioQueueSynthLibrary alloc] init ];
}


- (void)updateString {
	
	// Store the text of the text field in the 'string' instance variable.
	self.string = textField.text;
    // Set the text of the label to the value of the 'string' instance variable.
	label.text = self.string;
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
	if (theTextField == textField) {
		[textField resignFirstResponder];
        // Invoke the method that changes the greeting.
        [self updateString];
	}
	return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [textField resignFirstResponder];
    // Revert the text field to the previous value.
    textField.text = self.string; 
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)playAIFF:(id)sender{
    SystemSoundID systemSoundID;
    //[1] tap.aifのパスを取得
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tap" ofType:@"aif"];
    //[2] パスからNSURLを取得
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    OSStatus err;
    //[3] SystemSoundIDを作成する
    err = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &systemSoundID);
    
    //[4]エラーがあった場合はreturnで中止
    if ( err ) {
        NSLog(@"AudioServicesCreateSystemSoundID err = %d",err);
        return;
    }

    //コールバック関数の登録
    AudioServicesAddSystemSoundCompletion( systemSoundID, NULL, NULL,
        systemSoundCompletionProcFunction, NULL);
    
    //[5] 再生する
    AudioServicesPlaySystemSound(systemSoundID);
}

-(IBAction)play:(id)sender{
    [synth play];
}

-(IBAction)stop:(id)sender{
    [synth stop:YES];
}

-(IBAction)stepperBPMAction:(UIStepper*)sender {
    // simpleFM.carrierFreq = sender.value;
    textBPM.text = [NSString stringWithFormat:@"%.3f",sender.value];
}

- (void)dealloc {
	// To adhere to memory management rules, release the instance variables.
    // 'textField' and 'label' are objects in the nib file and are created when the nib
    // is loaded.
	[textField release];
	[label release];
	[super dealloc];
}


@end
