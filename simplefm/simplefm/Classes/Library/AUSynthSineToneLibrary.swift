//
//  AUSynthSineToneLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/22/15.
//  Copyright © 2015 fracmode. All rights reserved.
//

import Foundation

class AUSynthSineToneLibrary : NSObject {
    let auLib : AudioUnitLibrary = AudioUnitLibrary()
    
    override init() {
        super.init()
        auLib.prepareAudioUnit()
    }

    // play()
    func play() {
        auLib.play()
    }
    
    // stop()
    func stop() {
        auLib.stop()
    }
    
}