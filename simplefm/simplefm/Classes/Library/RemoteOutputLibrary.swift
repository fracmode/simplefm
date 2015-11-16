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

    let freq: Float = data.frequency
    
    for ( var i: UInt32 = 0; i < inNumberFrames; i++ ) {
        let wave: Float = sin(data.phase)
        var sample : Float = wave * Float( 1 << kAudioUnitSampleFractionBits )
        memcpy(datas, &sample, sizeof(Float))
        datas++
        data.phase += data.freqz
        data.freqz = 0.001 * freq + 0.999 * data.freqz
    }
    
    return noErr
}

//
// class SoundPlayerData
//
class SoundPlayerData
{
    var phase : Float = 0.0
    var sampleRate : Float = 0.0
    var frequency : Float = 0.0
    var freqz : Float = 0.0
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
        // AudioUnitを初期化
        _initAudioUnit()
    
        // AudioUnitとコールバックメソッドの関連づけ
        _setAudioUnitPropertyCallbackStruct()
        
        // StreamFormat の設定
        soundPlayerData.sampleRate = 44100.0
        soundPlayerData.phase = 0.0
        soundPlayerData.frequency = 440 * 2.0 * Float(M_PI) / soundPlayerData.sampleRate
        soundPlayerData.freqz = soundPlayerData.freqz
        
        _setAudioUnitPropertyAudioFormat()
        
        //フレームバッファサイズの変更
        _setAudioSession()
        
    }

    // _initAudioUnit()
    func _initAudioUnit() {
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
    }
    
    // _setAudioUnitPropertyCallbackStruct()
    func _setAudioUnitPropertyCallbackStruct() {
        var callbackStruct = AURenderCallbackStruct(inputProc: RenderCallback, inputProcRefCon: &soundPlayerData )
        AudioUnitSetProperty( audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
            0, &callbackStruct, UInt32( sizeofValue( callbackStruct ) ) )
    }
    
    // _setAudioUnitPropertyAudioFormat()
    func _setAudioUnitPropertyAudioFormat() {
        var audioFormat = AudioStreamBasicDescription()
        audioFormat.mSampleRate         = Float64( soundPlayerData.sampleRate )
        audioFormat.mFormatID           = kAudioFormatLinearPCM
        audioFormat.mFormatFlags        = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved
        audioFormat.mChannelsPerFrame   = 2
        audioFormat.mBytesPerPacket     = UInt32( sizeof(Int32) )
        audioFormat.mBytesPerFrame      = UInt32( sizeof(Int32) )
        audioFormat.mFramesPerPacket    = 1
        audioFormat.mBitsPerChannel     = UInt32( 8 * sizeof(Int32) )
        audioFormat.mReserved           = 0
        
        AudioUnitSetProperty( audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
            0, &audioFormat, UInt32( sizeofValue( audioFormat ) ) )
    }
    
    // _setAudioSession()
    func _setAudioSession() {
        //フレームバッファサイズの変更
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory( AVAudioSessionCategoryPlayback )
        try! audioSession.setActive( true )
        
        let currentDuration : Double = audioSession.IOBufferDuration
        print("currentDuration = %f\n",currentDuration);
        //フレームバッファサイズ
        NSLog("frame size = %f", Double( soundPlayerData.sampleRate ) * currentDuration);
        
        //フレーム数から秒を計算 256 = 希望するフレーム数
        let duration : Double = 256 / Double( soundPlayerData.sampleRate );
        print( "duration = %f\n", duration );
        
        //IOBufferDurationを変更する
        try! audioSession.setPreferredIOBufferDuration( NSTimeInterval( duration ) )
        
        //変更後の値を確認してみる
        let newDuration : Double = audioSession.IOBufferDuration
        print("newDuration = %f\n",newDuration);
        //フレームバッファサイズ
        NSLog("frame size = %f", Double( soundPlayerData.sampleRate ) * newDuration);
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
