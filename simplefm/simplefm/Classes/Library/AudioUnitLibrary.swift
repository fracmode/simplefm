//
//  AudioUnitLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 22/11/2015.
//  Copyright © 2015 fracmode. All rights reserved.
//

import AudioUnit
import AudioToolbox
import AVFoundation

//
// class SoundPlayerData
//
class SoundPlayerData
{
    var phase : Float = 0.0
    var sampleRate : Float64 = 0.0
    var frequency : Float = 0.0
    var freqz : Float = 0.0
    var hertz : Float = 0.0
}

//
// class SoundPlayerData
//

class AudioUnitLibrary: NSObject {
    var acLib : AudioComponentLibrary = AudioComponentLibrary()
    var asLib : AudioSessionLibrary = AudioSessionLibrary()
    var auInstance : AudioUnit = AudioUnit()
    var audioComponent : AudioComponent = nil
    var soundPlayerData: SoundPlayerData = SoundPlayerData()
    var isPlaying : Bool = false

    // init
    override init() {
        super.init()
        prepareAudioUnit()
    }

    // deinit
    deinit {
        if ( isPlaying ) { AudioOutputUnitStop( auInstance ) }
        AudioUnitUninitialize( auInstance )
        acLib.disposeAudioComponentInstance( auInstance )
    }

    // prepareAudioUnit()
    func prepareAudioUnit() {
        // AudioUnitを初期化
        self.initAudioUnitRemoteIO()
        
        // // AudioUnitとコールバックメソッドの関連づけ
        // setAudioUnitPropertyCallbackStruct()
        
        // StreamFormat の設定
        soundPlayerData.sampleRate = 44100.0
        soundPlayerData.phase = 0.0
        soundPlayerData.hertz = 440.0
        soundPlayerData.frequency = soundPlayerData.hertz * 2.0 * Float(M_PI) / Float( soundPlayerData.sampleRate )
        soundPlayerData.freqz = soundPlayerData.freqz
        
        self._setAudioUnitPropertyAudioFormat()
        
        //フレームバッファサイズの変更
        self._setAudioSession()
        
    }
    
    // initAudioUnitRemoteIO()
    func initAudioUnitRemoteIO() {
        // RemoteIO AudioUnit を取得
        auInstance = self.getNewAUInstanceRemoteIO()
        
        //AudioUnitを初期化
        AudioUnitInitialize( auInstance )
    }
    
    // getNewAUInstanceRemoteIO
    func getNewAUInstanceRemoteIO() -> AudioUnit {
        let ac : AudioComponent = acLib.findNextACRemoteIO()
        return self.getNewAUInstanceByAudioComponent( ac )
    }
    
    // getNewAUInstanceByAudioComponent
    func getNewAUInstanceByAudioComponent( ac: AudioComponent ) -> AudioUnit {
        var status : OSStatus
        var au : AudioUnit = AudioUnit()

        // AudioComponentとAudioUnitのアドレスを渡してAudioUnitを取得
        status = AudioComponentInstanceNew( ac, &au )
        return au
    }
    
    // setAudioUnitPropertyCallbackStruct()
    func setAudioUnitPropertyCallbackStruct( auCallback: AURenderCallback? ) {
        var callbackStruct = AURenderCallbackStruct(inputProc: auCallback!, inputProcRefCon: &soundPlayerData )
        AudioUnitSetProperty( auInstance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
            0, &callbackStruct, UInt32( sizeofValue( callbackStruct ) ) )
    }
    
    // _setAudioUnitPropertyAudioFormat()
    func _setAudioUnitPropertyAudioFormat() {
        var audioFormat = self.getAUCanonicalASBD()
        
        AudioUnitSetProperty( auInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
            0, &audioFormat, UInt32( sizeofValue( audioFormat ) ) )
    }
    
    // _setAudioSession()
    func _setAudioSession() {
        asLib.setCategoryPlayback()
        asLib.setPreferredIOBufferDuration( 256 / Double( soundPlayerData.sampleRate ) )
        asLib.setPreferredOutputNumberOfChannels( 2 )
        asLib.setActive()
        
       // //フレームバッファサイズの変更
       // let audioSession = AVAudioSession.sharedInstance()
       // try! audioSession.setCategory( AVAudioSessionCategoryPlayback )
       // try! audioSession.setActive( true )
       
       // let currentDuration : Double = audioSession.IOBufferDuration
       // print("currentDuration = %f\n",currentDuration);
       // //フレームバッファサイズ
       // NSLog("frame size = %f", Double( soundPlayerData.sampleRate ) * currentDuration);
       
       // //フレーム数から秒を計算 256 = 希望するフレーム数
       // let duration : Double = 256 / Double( soundPlayerData.sampleRate );
       // print( "duration = %f\n", duration );
       
       // //IOBufferDurationを変更する
       // try! audioSession.setPreferredIOBufferDuration( NSTimeInterval( duration ) )
       
       // //変更後の値を確認してみる
       // let newDuration : Double = audioSession.IOBufferDuration
       // print("newDuration = %f\n",newDuration);
       // //フレームバッファサイズ
       // NSLog("frame size = %f", Double( soundPlayerData.sampleRate ) * newDuration);
    }

    // getAUCanonicalASBD
    func getAUCanonicalASBD( sampleRate: Float64 = 44100, channel: UInt32 = 2 ) -> AudioStreamBasicDescription {
        var audioFormat = AudioStreamBasicDescription()
        audioFormat.mSampleRate         = sampleRate
        audioFormat.mFormatID           = kAudioFormatLinearPCM
        audioFormat.mFormatFlags        = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved
        audioFormat.mChannelsPerFrame   = channel
        audioFormat.mBytesPerPacket     = UInt32( sizeof(Float32) )
        audioFormat.mBytesPerFrame      = UInt32( sizeof(Float32) )
        audioFormat.mFramesPerPacket    = 1
        audioFormat.mBitsPerChannel     = UInt32( 8 * sizeof(Float32) )
        audioFormat.mReserved           = 0
        
        return audioFormat
    }
    
    // play()
    func play() {
        if ( !isPlaying ) { AudioOutputUnitStart( auInstance ) }
        isPlaying = true
    }
    
    // stop()
    func stop() {
        if ( isPlaying ) { AudioOutputUnitStop( auInstance ) }
        isPlaying = false
    }
    
}