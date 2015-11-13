//
//  RemoteOutputLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/11/15.
//  Copyright © 2015 fracmode. All rights reserved.
//

import AudioUnit
import AudioToolbox


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
    let buf: AudioBufferList = ioData.memory
    var datas: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>(buf.mBuffers.mData)

    let sineWaveFreq: Float = 440.0
    let samplingRate: Float = 44100.0
    let freq: Float = sineWaveFreq * 2.0 * Float(M_PI) / samplingRate
    
    for ( var i: UInt32 = 0; i < inNumberFrames; i++ ) {
        let wave: Float = sin(data.time)
        var sample : Float = wave * Float( 1 << kAudioUnitSampleFractionBits )
        memcpy(datas, &sample, sizeof(Float))
        datas++
        data.time += freq
    }
    
    return noErr
}

//
// class SoundPlayerData
//
class SoundPlayerData
{
    var time: Float = 0.0
    var phase : Double = 0.0
    var sampleRate : Float64 = 0.0
    var frequency : Double = 0.0
    var freqz : Double = 0.0
}

//
// class RemoteOutputLibrary
//
class RemoteOutputLibrary: NSObject {
    var audioUnit : AudioUnit = AudioUnit()
    var audioComponentDescription : AudioComponentDescription = AudioComponentDescription()
    var audioComponent : AudioComponent = nil
    var soundPlayerData: SoundPlayerData = SoundPlayerData()
    var isPlaying : Bool = false
    
    // deinit
    override init() {
        super.init()
        prepareAudioUnit()
    }
    
    // deinit
    deinit {
        if ( isPlaying ) { AudioOutputUnitStop( audioUnit ) }
        AudioUnitUninitialize( audioUnit )
        AudioComponentInstanceDispose( audioUnit )
    }
    
    // prepareAudioUnit()
    func prepareAudioUnit() {
        //RemoteIO Audio UnitのAudioComponentDescriptionを作成
        audioComponentDescription.componentType = kAudioUnitType_Output
        audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO
        audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        audioComponentDescription.componentFlags = 0
        audioComponentDescription.componentFlagsMask = 0
        
        //AudioComponentDescriptionからAudioComponentを取得
        audioComponent = AudioComponentFindNext( nil, &audioComponentDescription )
        
        //AudioComponentとAudioUnitのアドレスを渡してAudioUnitを取得
        AudioComponentInstanceNew( audioComponent, &audioUnit )

        //AudioUnitを初期化
        AudioUnitInitialize( audioUnit )
    
        var callbackStruct = AURenderCallbackStruct(inputProc: RenderCallback, inputProcRefCon: &soundPlayerData )

        // AudioUnitとコールバックメソッドの関連づけ
        AudioUnitSetProperty( audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
            0, &callbackStruct, UInt32( sizeofValue( callbackStruct ) ) );
    }
    
    // play()
    func play() {
        if ( !isPlaying ) { AudioOutputUnitStart( audioUnit ) }
        isPlaying = true
    }

    // stop()
    func stop() {
        if ( isPlaying ) { AudioOutputUnitStop( audioUnit ) }
        isPlaying = false
    }
    
}
