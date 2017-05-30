//
//  ViewController.swift
//  TinyPocketCar
//
//  Created by Nathan Birkholz on 5/11/17.
//  Copyright © 2017 natebirkholz. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {

    var timer: Timer!

    var label: UILabel?
    var crashLabel: UILabel?
    var screechLabel: UILabel?
    var brakeLabel: UILabel?
    var revLabel: UILabel?

    let evaluator = MovementEvaluator()

    var enginePlayer: AVAudioPlayer?
    var screechPlayer: AVAudioPlayer?
    var vroomPlayer: AVAudioPlayer?
    var crashPlayer1: AVAudioPlayer?
    var crashPlayer2: AVAudioPlayer?
    var squealPlayer: AVAudioPlayer?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeLabels()
        makePlayers()

        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        idle()

    }

    func makeLabels() {
        let labelOne = UILabel()
        labelOne.text = "0"
        labelOne.font = UIFont.systemFont(ofSize: 24)
        labelOne.textColor = UIColor.darkGray
        labelOne.numberOfLines = 1
        labelOne.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelOne.textAlignment = .center
        labelOne.sizeToFit()

        self.view.addSubview(labelOne)
        labelOne.center = self.view.center
        labelOne.frame.origin.y = labelOne.frame.origin.y - 70

        self.label = labelOne

        let labelTwo = UILabel()
        labelTwo.text = "Crash!"
        labelTwo.font = UIFont.systemFont(ofSize: 24)
        labelTwo.textColor = UIColor.darkGray
        labelTwo.numberOfLines = 1
        labelTwo.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelTwo.textAlignment = .center
        labelTwo.sizeToFit()
        labelTwo.alpha = 0

        self.view.addSubview(labelTwo)
        labelTwo.center = self.view.center
        labelTwo.frame.origin.y = labelOne.frame.origin.y - -35

        self.crashLabel = labelTwo

        let labelThree = UILabel()
        labelThree.text = "Screech!"
        labelThree.font = UIFont.systemFont(ofSize: 24)
        labelThree.textColor = UIColor.darkGray
        labelThree.numberOfLines = 1
        labelThree.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelThree.textAlignment = .center
        labelThree.sizeToFit()
        labelThree.alpha = 0

        self.view.addSubview(labelThree)
        labelThree.center = self.view.center

        self.screechLabel = labelThree

        let labelFour = UILabel()
        labelFour.text = "Brake!"
        labelFour.font = UIFont.systemFont(ofSize: 24)
        labelFour.textColor = UIColor.darkGray
        labelFour.numberOfLines = 1
        labelFour.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelFour.textAlignment = .center
        labelFour.sizeToFit()
        labelFour.alpha = 0

        self.view.addSubview(labelFour)
        labelFour.center = self.view.center
        labelFour.frame.origin.y = labelFour.frame.origin.y + 35

        self.brakeLabel = labelFour

        let labelFive = UILabel()
        labelFive.text = "Rev!"
        labelFive.font = UIFont.systemFont(ofSize: 24)
        labelFive.textColor = UIColor.darkGray
        labelFive.numberOfLines = 1
        labelFive.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelFive.textAlignment = .center
        labelFive.sizeToFit()
        labelFive.alpha = 0

        self.view.addSubview(labelFive)
        labelFive.center = self.view.center
        labelFive.frame.origin.y = labelFive.frame.origin.y + 70


        self.revLabel = labelFive
    }

    func makePlayers() {
        let turnUrl = Bundle.main.url(forResource: "TireScreech_01", withExtension: "mp3")!
        let revUrl = Bundle.main.url(forResource: "MotorRev_04", withExtension: "mp3")!
        let crash1Url = Bundle.main.url(forResource: "Crash_03", withExtension: "mp3")!
        let crash2Url = Bundle.main.url(forResource: "Crash_04", withExtension: "mp3")!
        let brakeUrl = Bundle.main.url(forResource: "BrakeSqueal_01", withExtension: "mp3")!
        let idleUrl = Bundle.main.url(forResource: "MotorIdle_lp_01", withExtension: "wav")!

        do {
            screechPlayer = try AVAudioPlayer(contentsOf: turnUrl)
            vroomPlayer = try AVAudioPlayer(contentsOf: revUrl)
            crashPlayer1 = try AVAudioPlayer(contentsOf: crash1Url)
            crashPlayer2 = try AVAudioPlayer(contentsOf: crash2Url)
            squealPlayer = try AVAudioPlayer(contentsOf: brakeUrl)
            enginePlayer = try AVAudioPlayer(contentsOf: idleUrl)
        } catch let error {
            print(error)
        }
    }

    func update() {
        let evaluation = evaluator.evaluateMovement()
        switch evaluation {
        case .crash:
            crash()
        // eventual animation/vfx
        case .turn:
            turn()
        // eventual animation/vfx
        case .brake:
            if let player = screechPlayer, player.isPlaying {
                // Don't brake on a curve, very dangerous, physics is against you.
            } else {
                brake()
            }
        // eventual animation/vfx
        case .forwardFast:
            vroom()
        // eventual animation/vfx
        case .backwardFast:
            vroom()
        // eventual animation/vfx
        case .forward:
            print("forward")
        // eventual animation/vfx
        case .backward:
            print("backward")
        // eventual animation/vfx
        case .none:
            let _ = 10
            // eventual animation/vfx
        }
    }

    func turn() {
        if let play = screechPlayer, play.isPlaying { return }

        screechLabel?.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { self.screechLabel?.alpha = 0 })

        screechPlayer?.prepareToPlay()
        screechPlayer?.play()
    }

    func vroom() {
        if let play = vroomPlayer, play.isPlaying { return }

        revLabel?.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { self.revLabel?.alpha = 0 })

        vroomPlayer?.prepareToPlay()
        vroomPlayer?.play()
    }

    func crash() {
        if let play1 = crashPlayer1, play1.isPlaying { return }
        if let play2 = crashPlayer2, play2.isPlaying { return }

        crashLabel?.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { self.crashLabel?.alpha = 0 })

        crashPlayer1?.prepareToPlay()
        crashPlayer2?.prepareToPlay()
        crashPlayer1?.play()
        crashPlayer2?.play()
    }

    func brake() {
        if let play = squealPlayer, play.isPlaying { return }

        brakeLabel?.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: { self.brakeLabel?.alpha = 0 })

        squealPlayer?.prepareToPlay()
        squealPlayer?.play()
    }

    func idle() {
        enginePlayer?.numberOfLoops = -1
        enginePlayer?.setVolume(0.3, fadeDuration: 0)
        enginePlayer?.prepareToPlay()
        enginePlayer?.play()
    }
}

extension ViewController: MovementEvaluatorDelegate {
    func updateLabel(_ value: Double) {
        if value >= 2.5 {
            label?.text = "2.5"
            label?.backgroundColor = UIColor.red
        } else if value >= 1.0 {
            label?.text = "1.0"
            label?.backgroundColor = UIColor.yellow
        } else if value >= 0.5 {
            label?.text = "0.5"
            label?.backgroundColor = UIColor.green
        } else {
            label?.text = "0.0"
            label?.backgroundColor = UIColor.clear
        }
    }
}

extension CMAcceleration {
    var sum: Double {
        let sumFor = abs(x) + abs(y) + abs(z)
        return sumFor
    }

    func deltaFrom(_ other: CMAcceleration) -> Double {
        let deltaFor = abs(sum - other.sum)
        return deltaFor
    }

    func deltaFromSigned(_ other: CMAcceleration) -> Double {
        let deltaFor = sum - other.sum
        return deltaFor
    }
}

extension CMRotationRate {
    var sum: Double {
        let sumFor = abs(x) + abs(y) + abs(z)
        return sumFor
    }
    
    func deltaFrom(_ other: CMRotationRate) -> Double {
        let deltaFor = abs(sum - other.sum)
        return deltaFor
    }
}

