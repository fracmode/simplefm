//
//  AudioSessionLibrary.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/23/15.
//  Copyright © 2015 fracmode. All rights reserved.
//

import AVFoundation

class AudioSessionLibrary : NSObject {
    var asInstance : AVAudioSession = AVAudioSession()
    
    // init()
    override init() {
        self.asInstance = AVAudioSession.sharedInstance()
    }
    
    // setActive()
    func setActive() {
        try! self.asInstance.setActive( true )
    }
    
    // setCategoryPlayback()
    func setCategoryPlayback() {
        try! self.asInstance.setCategory( AVAudioSessionCategoryPlayback )
    }
    
    // setPreferredIOBufferDuration()
    func setPreferredIOBufferDuration( duration: Double = 256 * 44100 ) {
        try! self.asInstance.setPreferredIOBufferDuration( NSTimeInterval( duration ) )
    }
    
    // setPreferredOutputNumberOfChannels()
    func setPreferredOutputNumberOfChannels( count: Int ) {
        try! self.asInstance.setPreferredOutputNumberOfChannels( count )
    }
}