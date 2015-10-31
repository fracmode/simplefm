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
}


@property UInt32 numPacketsToRead;
@property double phase;

-(void)play;
-(void)prepareAudioQueue;
-(void)stop:(BOOL)shouldStopImmediate;
@end