//
//  AudioQueuePlayer.h
//  AudioQueue
//
//  Created by Norihisa Nagano
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioQueueSynthLibrary : NSObject {
    AudioQueueRef audioQueueObject;
    UInt32 numPacketsToRead;
    BOOL isPrepared;
    double phase;
    double frequency;
    double freqz;
}

@property UInt32 numPacketsToRead;
@property double phase;

@property double frequency;
@property double freqz;

-(void)prepareAudioQueue;

-(void)play;
-(void)stop:(BOOL)shouldStopImmediate;
@end
