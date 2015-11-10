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
    var isPlaying : Bool = false
    
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
