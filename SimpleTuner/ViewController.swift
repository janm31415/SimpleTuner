//
//  ViewController.swift
//  SimpleTuner
//
//  Created by Jan Maes on 08/10/2020.
//

import UIKit

class ViewController: UIViewController, TunerDelegate {

  fileprivate var tuner: Tuner?
  fileprivate var tunerView: TunerView?
  fileprivate var running = false
  
  @IBOutlet weak var actionButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tunerView = TunerView(frame: view.frame)
    view.addSubview(tunerView!)
    view.addSubview(actionButton!)
    tuner = Tuner()
    tuner?.delegate = self
  }

func startTuner() {
        if !running {
            running = true
            tuner?.start()
            actionButton.setTitle("Stop", for: .normal)
        }
    }
    
    func stopTuner() {
        if running {
            running = false
            tuner?.stop()
            tunerView?.gaugeView.value = 0.0
            tunerView?.pitchLabel.text = "--"
            actionButton.setTitle("Start", for: .normal)
        }
    }
    
  @IBAction func onActionButton(_ sender: Any)
  {
  if running {
    stopTuner()
    }
  else {
    startTuner()
    }
  }
  
  func tunerDidUpdate(_ tuner: Tuner, output: TunerOutput)
  {
        if output.amplitude < 0.01 {
            tunerView?.gaugeView.value = 0.0
            tunerView?.pitchLabel.text = "--"
        } else {
            tunerView?.pitchLabel.text = output.pitch + "\(output.octave)"
            tunerView?.gaugeView.value = Float(output.distance)
        }
  }
}

