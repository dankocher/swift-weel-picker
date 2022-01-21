//
//  ViewController.swift
//  InfinityCouruselCounterTest
//
//  Created by Vlad on 17.01.22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var Wrapper: UIView!
    
    
    
    lazy var dataController: InfinityCouruselCounter = {

        let dataController = InfinityCouruselCounter(callbackCounter: saySomth, width: self.view.frame.width)

        return dataController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.Wrapper.addSubview(dataController.configureCollectionView())


    }

    func saySomth(text: Int) {
        print(text)
    }

}

