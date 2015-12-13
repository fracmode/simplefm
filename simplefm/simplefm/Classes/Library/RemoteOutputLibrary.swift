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

//
// func __RemoteOutputLibrary__GetWaveSaw()
//
func __RemoteOutputLibrary__GetWaveSaw( phase : Float ) -> Float {
    var wave = phase / 4
    if ( wave > 2 ) {
        wave = wave % 2
    }
    let ret = 1 - wave
    return ret
}

//
// class RemoteOutputLibrary
//
class RemoteOutputLibrary: AudioUnitLibrary {
    // init
    override init() {
        super.init()
        super.setAudioUnitPropertyCallbackStruct( callback )
    }

    // callback()
    //
    let callback: AURenderCallback = {
        (inRefCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> (OSStatus)
        in
        let roLib:RemoteOutputLibrary = unsafeBitCast(inRefCon, RemoteOutputLibrary.self)
        roLib.render( inRefCon, inNumberFrames:inNumberFrames, ioData:ioData)
        return noErr
    }
    
    // render()
    //
    func render( inRefCon: UnsafeMutablePointer<Void>,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList> )
    {
        // ioData のポインタを for で回して、入ってきた mData を取る（書き方が回りくどい）
        let ioDataMem: AudioBufferList = ioData.memory
        let ablP = UnsafeMutableAudioBufferListPointer(ioData)
        var outputs = [UnsafeMutablePointer<Float>]( count: Int( ioDataMem.mNumberBuffers ), repeatedValue: nil )
        var outputCount : Int = 0
        for buffer in ablP {
            outputs[ outputCount++ ] = UnsafeMutablePointer<Float>( buffer.mData )
        }
        
        let freq: Float = self.frequency
        // var freq : Float = data.hertz * 2.0 * Float(M_PI) / data.sampleRate
        let amp: Float = 0.33
        
        for ( var i: UInt32 = 0; i < inNumberFrames; i++ ) {
            // let wave: Float = sin(self.phase)
            let wave: Float = __RemoteOutputLibrary__GetWaveSaw( self.phase )
            var sample : Float = wave * amp
            // NSLog( "%f", sample )
            memcpy( outputs[0]++, &sample, sizeof(Float) )
            memcpy( outputs[1]++, &sample, sizeof(Float) )
            let phaseCycle : Float = self.hertz * 2.0 * Float(M_PI)
            // let freq: Float = phaseCycle / Float( data.sampleRate )
            self.phase += self.freqz
            if ( self.phase >= phaseCycle ) {
                self.phase -= phaseCycle
            }
            // freq = ( data.hertz * 2 ) * 2.0 * Float(M_PI) / data.sampleRate
            self.freqz = 0.005 * freq + 0.995 * self.freqz
        }
    }

}
