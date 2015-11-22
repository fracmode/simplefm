//
//  RemoteOutputLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/11/15.
//  Copyright © 2015 fracmode. All rights reserved.
//

import AudioUnit
import AudioToolbox
import AVFoundation

func GetWaveSaw( phase : Float ) -> Float {
    var wave : Float = 0.0
    for i in 1...16 {
        wave += sin( phase * Float( i ) ) / Float( i )
    }
    return wave
}

//
// func RenderCallback()
//
func RenderCallback (
    inRefCon: UnsafeMutablePointer <Void>,
    ioActionFlags: UnsafeMutablePointer <AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer <AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer <AudioBufferList> ) -> (OSStatus)
{
    let tmp: UnsafeMutablePointer<SoundPlayerData> = UnsafeMutablePointer<SoundPlayerData>(inRefCon)
    let data: SoundPlayerData = tmp.memory

    // ioData のポインタを for で回して、入ってきた mData を取る（書き方が回りくどい）
    let ioDataMem: AudioBufferList = ioData.memory
    let ablP = UnsafeMutableAudioBufferListPointer(ioData)
    var outputs = [UnsafeMutablePointer<Float>]( count: Int( ioDataMem.mNumberBuffers ), repeatedValue: nil )
    var outputCount : Int = 0
    for buffer in ablP {
        outputs[ outputCount++ ] = UnsafeMutablePointer<Float>( buffer.mData )
    }
    
    let freq: Float = data.frequency
    // var freq : Float = data.hertz * 2.0 * Float(M_PI) / data.sampleRate
    let volume: Float = 0.25
    
    for ( var i: UInt32 = 0; i < inNumberFrames; i++ ) {
        let wave: Float = sin(data.phase)
        // let wave: Float = GetWaveSaw( data.phase )
        var sample : Float = wave * volume * Float( 1 << kAudioUnitSampleFractionBits )
        memcpy( outputs[0], &sample, sizeof(Float) )
        outputs[0]++
        memcpy( outputs[1], &sample, sizeof(Float) )
        outputs[1]++
        data.phase += data.freqz
        // freq = ( data.hertz * 2 ) * 2.0 * Float(M_PI) / data.sampleRate
        data.freqz = 0.001 * freq + 0.999 * data.freqz
    }
    
    return noErr
}

//
// class RemoteOutputLibrary
//
class RemoteOutputLibrary: AudioUnitLibrary {
    
    // init
    override init() {
        super.init()
        setAudioUnitPropertyCallbackStruct( RenderCallback )
    }
   
}
