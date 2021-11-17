//
//  ViewController.swift
//  DunneSamplerCrash
//
//  Created by Maximilian Maksutovic on 11/17/21.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AudioManager.shared.start()
        AudioManager.shared.playPiano(note: MIDINoteNumber(60), velocity: MIDIVelocity(127), channel: MIDIChannel(0))
    }


}

