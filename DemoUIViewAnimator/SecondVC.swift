//
//  SecondVC.swift
//  DemoUIViewAnimator
//
//  Created by Apple on 13/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class SecondVC: UIViewController {

    //MARK:- OUTLETS
    
    @IBOutlet weak var img: UIImageView!
    
    //MARK:- VARIABLES
    var runningAnimator = [UIViewPropertyAnimator]()
    var visualeffect : UIVisualEffectView!
    
    //MARK:- VIEW METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
    }
    
    //MARK: - VOID METHODS
    func initMethod(){
        visualeffect = UIVisualEffectView()
        visualeffect.frame = self.view.frame
        self.view.addSubview(visualeffect)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handletapGesture(recogniser:)))
        self.view.addGestureRecognizer(tapGesture)
        
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2.0, delay: 0, options: [.curveLinear], animations: {
//            self.view.backgroundColor = .green
//        }, completion: nil)
        
        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            self.view.backgroundColor = .green
        }
        animator.startAnimation()
    }

    
    func animateTransitionifNeeded(state : UIGestureRecognizer.State, duration : TimeInterval){
        
        if runningAnimator.isEmpty {
            let bluranimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state{
                case .possible:
                    self.visualeffect.effect = UIBlurEffect(style: .dark)
                case .ended:
                    self.visualeffect.effect = nil
                default :
                    break
                }
            }
            bluranimator.startAnimation()
            runningAnimator.append(bluranimator)
        }
        
        for animator in runningAnimator {
            animator.pauseAnimation()
        }
    }
    
    
    @objc func handletapGesture(recogniser: UITapGestureRecognizer) {
        animateTransitionifNeeded(state: recogniser.state, duration: 0.9)
    }
    
    //MARK:- CLICKED EVENTS
    
    

}


//MARK:- EXTENSIONS


