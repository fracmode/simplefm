//
//  AudioQueuePlayer.m
//  AudioQueue
//
//  Created by Norihisa Nagano
//  Copyright 2009 . All rights reserved.
//

#import "AudioQueueSynthLibrary.h"


@implementation AudioQueueSynthLibrary

@synthesize numPacketsToRead;
@synthesize phase;
@synthesize frequency;
@synthesize freqz;


static void outputCallback(void *                  inUserData,
                           AudioQueueRef           inAQ,
                           AudioQueueBufferRef     inBuffer){
    
    AudioQueueSynthLibrary *player =(AudioQueueSynthLibrary*)inUserData;
    UInt32 numPackets = player.numPacketsToRead;
    UInt32 numBytes = numPackets * sizeof(SInt16);
    
    double freqz = player.freqz;
    double freq = player.frequency * 2.0 * M_PI / 44100.0;
    
    //SInt16 == 2byte 16bit
    SInt16 *output = inBuffer->mAudioData;
    double phase = player.phase;
    for(int i = 0; i < numPackets; i++){
        float wave = sin(phase);
        SInt16 sample = wave * 32767;
        *output++ = sample;
        phase = phase + freqz;
        freqz = 0.001 * freq + 0.999 * freqz;
    }
    player.phase = phase;
    player.freqz = freqz;
    
    //AudioQueueBufferRefにパケットデータサイズを渡す
    inBuffer->mAudioDataByteSize = numBytes;
    //inBufferをEnqueueする
    AudioQueueEnqueueBuffer(inAQ,inBuffer, 0, NULL);
}

-(id)init{
    self = [super init];
    if(self != nil) {
        [self prepareAudioQueue];
    }
    return self;
}


-(void)prepareAudioQueue{
    //16bit 44.1kHz モノラル
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= 44100.0;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    //Big Endianではないので注意
    audioFormat.mFormatFlags		= kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= audioFormat.mBitsPerChannel / 8;
    audioFormat.mBytesPerFrame		= audioFormat.mBitsPerChannel / 8;
    audioFormat.mReserved			= 0;
    
    AudioQueueNewOutput(&audioFormat,
                        outputCallback,
                        self,
                        NULL,NULL,0,
                        &audioQueueObject);
    
    AudioQueueBufferRef  buffers[3];
    //何パケットずつ読み込むか
    numPacketsToRead = 1024;
    UInt32 bufferByteSize = numPacketsToRead * audioFormat.mBytesPerPacket;
    
    int bufferIndex;
    for(bufferIndex = 0; bufferIndex < 3; bufferIndex++){
        AudioQueueAllocateBuffer(audioQueueObject,
                                 bufferByteSize,
                                 &buffers[bufferIndex]);
        
        outputCallback(self,audioQueueObject,buffers[bufferIndex]);
    }
    isPrepared = YES;
    frequency = 440.0;
    freqz = frequency * 2.0 * M_PI / audioFormat.mSampleRate;
}

-(void)play{
    if(!isPrepared)[self prepareAudioQueue];
    AudioQueueStart(audioQueueObject, NULL);////再生を開始する
}

-(void)stop:(BOOL)shouldStopImmediate{
    AudioQueueStop(audioQueueObject, shouldStopImmediate);
    isPrepared = NO;
}


-(void)dealloc {
    AudioQueueDispose(audioQueueObject, YES);
    [super dealloc];
}
@end