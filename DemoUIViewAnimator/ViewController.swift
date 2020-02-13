//
//  ViewController.swift
//  DemoUIViewAnimator
//
//  Created by Apple on 12/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    enum CardState {
        case expanded
        case collapsed
    }
    
    //MARK:- OUTLETS
    
    
    
    //MARK:- VARIABLES
    
    var cardView : CardVC!
    var visualEffectView : UIVisualEffectView!
    let cardHeight : CGFloat = 600
    let cardHandleAreaHeight : CGFloat = 65
    
    var cardVisible = false
    var nextState : CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimation = [UIViewPropertyAnimator]()
    var animationProgressWhenInterupted : CGFloat = 0
    
    //MARK:- VIEW METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCard()
    }
    
    //MARK: - VOID METHODS
    func setUpCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        cardView = CardVC(nibName: "CardVC", bundle: nil)
        self.addChild(cardView)
        self.view.addSubview(cardView.view)
        
        cardView.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        cardView.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        
        cardView.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardView.handleArea.addGestureRecognizer(panGestureRecognizer)
    }

    
    @objc func handleCardTap(recognizer : UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            animateTransitionifNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc func handleCardPan( recognizer : UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            //Start
            startIneractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            //Update
            let translation = recognizer.translation(in: self.cardView.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            //Continue
            continueInteractiveTransition()
        default:
            break
        }
        
    }
    
    
    func animateTransitionifNeeded( state: CardState, duration: TimeInterval) {
        
        if runningAnimation.isEmpty {
            //Expand View from bottom to Top
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded :
                    self.cardView.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed :
                    self.cardView.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimation.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimation.append(frameAnimator)
            
            //Corner Radius Animation
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded :
                    self.cardView.view.layer.cornerRadius = 12
                case .collapsed :
                    self.cardView.view.layer.cornerRadius = 0
                }
            }
            cornerRadiusAnimator.startAnimation()
            runningAnimation.append(cornerRadiusAnimator)
            
            // Blur Animation
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded :
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimation.append(blurAnimator)
        }
    }
    
    
    func startIneractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimation.isEmpty {
           //Run animations
            animateTransitionifNeeded(state: state, duration: duration)
        }
        for animator in runningAnimation {
            animator.pauseAnimation()
            animationProgressWhenInterupted = animator.fractionComplete
        }
        
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimation {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterupted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimation {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    
    //MARK:- CLICKED EVENTS
    

}

//MARK:- EXTENSIONS


