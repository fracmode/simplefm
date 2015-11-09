//
//  MainViewController.swift
//  simplefm
//
//  Created by Sho Terunuma on 11/8/15.
//  Copyright © 2015 TestOrg. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.loadTemplate()
    }

    func loadTemplate() {
        let view:UIView = UINib(nibName: "MainView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
        self.view.addSubview(view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

