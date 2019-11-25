//
//  LoadingViewController.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/21.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var lblAppName: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: self.lblAppName, duration: 1, options: .transitionCrossDissolve, animations: {
            self.lblAppName.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute: {
                self.performSegue(withIdentifier: "segueToMainView", sender: nil)
            })
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

