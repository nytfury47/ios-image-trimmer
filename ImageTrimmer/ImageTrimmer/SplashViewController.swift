//
//  SplashViewController.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/21.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var lblAppName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblAppName.font = lblAppName.font.withSize(getScaledHeight(base: BASE_FONT_SIZE_XXXXXL))
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: self.lblAppName, duration: 1, options: .transitionCrossDissolve, animations: {
            self.lblAppName.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline:.now() + 1, execute: {
                self.performSegue(withIdentifier: "segueToMainView", sender: nil)
            })
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

