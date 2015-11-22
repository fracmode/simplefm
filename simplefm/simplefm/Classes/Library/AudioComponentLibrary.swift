//
//  AudioComponentLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/22/15.
//  Copyright © 2015 fracmode. All rights reserved.
//

import AudioToolbox
import AVFoundation

//
// class AudioComponentLibrary
//
class AudioComponentLibrary : NSObject {
    
    func findNextAudioComponentByType( type: OSType, _ subType: OSType ) -> AudioComponent {
        //AudioComponentDescriptionを作成
        var acd : AudioComponentDescription = AudioComponentDescription()
        acd.componentType = type
        acd.componentSubType = subType
        acd.componentManufacturer = kAudioUnitManufacturer_Apple
        acd.componentFlags = 0
        acd.componentFlagsMask = 0
        
        //AudioComponentDescriptionからAudioComponentを取得
        return AudioComponentFindNext( nil, &acd )
        
    }
    
    // findNextACRemoteIO
    func findNextACRemoteIO() -> AudioComponent {
        // RemoteIO Audio UnitのAudioComponentDescriptionを作成
        return self.findNextAudioComponentByType( kAudioUnitType_Output, kAudioUnitSubType_RemoteIO )
    }
    
    // disposeAudioComponentInstance()
    func disposeAudioComponentInstance( instance: AudioComponentInstance ) -> OSStatus {
        return AudioComponentInstanceDispose( instance )
    }
}