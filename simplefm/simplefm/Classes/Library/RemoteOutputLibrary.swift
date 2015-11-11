//
//  RemoteOutputLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/11/15.
//  Copyright © 2015 fracmode. All rights reserved.
//

import AudioUnit
import AudioToolbox

class RemoteOutputLibrary: NSObject {
    var audioUnit : AudioUnit = AudioUnit()
    var audioComDesc : AudioComponentDescription? = AudioComponentDescription()
    var isPlaying : Bool = false
    
    // deinit
    override init() {
        super.init()
        self.prepareAudioUnit()
    }
    
    // deinit
    deinit {
        if ( isPlaying ) { AudioOutputUnitStop( audioUnit ) }
        AudioUnitUninitialize( audioUnit )
        AudioComponentInstanceDispose( audioUnit )
    }
    
    // prepareAudioUnit()
    func prepareAudioUnit() {
        audioComDesc = AudioComponentDescription()
        audioComDesc?.componentType = kAudioUnitType_Output
        audioComDesc?.componentSubType = kAudioUnitSubType_RemoteIO
        audioComDesc?.componentManufacturer = kAudioUnitManufacturer_Apple
        audioComDesc?.componentFlags = 0
        audioComDesc?.componentFlagsMask = 0
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
