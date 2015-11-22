//
//  MainViewController.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/8/15.
//  Copyright © 2015 TestOrg. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var remoteOutput = RemoteOutputLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playButtonAction(sender: AnyObject) {
        remoteOutput.play()
    }
    
    @IBAction func stopButtonAction(sender: AnyObject) {
        remoteOutput.stop()
    }

}

