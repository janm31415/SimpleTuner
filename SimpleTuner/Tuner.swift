//
//  Tuner.swift
//  SimpleTuner
//
//  Created by Jan Maes on 08/10/2020.
//
//  Shamelessly plugged from https://github.com/comyar/TuningFork
//  Adapted to AudioKit 5.0
//

import Foundation
import AudioKit


private let flats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
private let sharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
private let frequencies: [Float] = [
  16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87, // 0
  32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27, 61.74, // 1
  65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00, 103.8, 110.0, 116.5, 123.5, // 2
  130.8, 138.6, 146.8, 155.6, 164.8, 174.6, 185.0, 196.0, 207.7, 220.0, 233.1, 246.9, // 3
  261.6, 277.2, 293.7, 311.1, 329.6, 349.2, 370.0, 392.0, 415.3, 440.0, 466.2, 493.9, // 4
  523.3, 554.4, 587.3, 622.3, 659.3, 698.5, 740.0, 784.0, 830.6, 880.0, 932.3, 987.8, // 5
  1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976,             // 6
  2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951,             // 7
  4186, 4435, 4699, 4978, 5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902              // 8
]

/**
Types adopting the TunerDelegate protocol act as callbacks for Tuners and are
the mechanism by which you may receive and respond to new information decoded
by a Tuner.
*/
@objc public protocol TunerDelegate {
    
  /**
  Called by a Tuner on each update.
  
  - parameter tuner: Tuner that performed the update.
  - parameter output: Contains information decoded by the Tuner.
  */
  func tunerDidUpdate(_ tuner: Tuner, output: TunerOutput)
}

// MARK:- TunerOutput
/**
Contains information decoded by a Tuner, such as frequency, octave, pitch, etc.
*/
@objc public class TunerOutput: NSObject {
  
  /**
  The octave of the interpreted pitch.
  */
  public fileprivate(set) var octave: Int = 0
  
  /**
  The interpreted pitch of the microphone audio.
  */
  public fileprivate(set) var pitch: String = ""
  
  /**
  The difference between the frequency of the interpreted pitch and the actual
  frequency of the microphone audio.
  
  For example if the microphone audio has a frequency of 432Hz, the pitch will
  be interpreted as A4 (440Hz), thus making the distance -8Hz.
  */
  public fileprivate(set) var distance: Float = 0.0
  
  /**
  The amplitude of the microphone audio.
  */
  public fileprivate(set) var amplitude: Float = 0.0
  
  /**
  The frequency of the microphone audio.
  */
  public fileprivate(set) var frequency: Float = 0.0
  
  fileprivate override init() {}
}


/**
A Tuner uses the devices microphone and interprets the frequency, pitch, etc.
*/
@objc public class Tuner: NSObject {
  
  fileprivate let smoothingBufferCount = 30
    
  fileprivate let threshold: Float
  fileprivate let smoothing: Float
  fileprivate var engine: AudioEngine?
  fileprivate var microphone: AudioEngine.InputNode?
  fileprivate var pitchTap: PitchTap?
  fileprivate var silence: Fader?
  fileprivate var smoothingBuffer: [Float] = []
  
    /**
  Object adopting the TunerDelegate protocol that should receive callbacks
  from this tuner.
  */
  public var delegate: TunerDelegate?
  
  /**
  Initializes a new Tuner.
  
   - parameter threshold: The minimum amplitude to recognize, 0 < threshold < 1
   - parameter smoothing: Exponential smoothing factor, 0 < smoothing < 1
   
  */
  public init(threshold: Float = 0.0, smoothing: Float = 0.25) {
    self.threshold = Float(min(abs(threshold), 1.0))
    self.smoothing = Float(min(abs(smoothing), 1.0))
  }
  
  /**
  Starts the tuner.
  */
  public func start() {
    engine = AudioEngine()
    microphone = engine!.input
    silence = Fader(microphone!, gain: 0)
    pitchTap = PitchTap(microphone!, bufferSize: 4096, handler: tap_handler)
    microphone!.start()
    pitchTap!.start()
    engine!.output = silence
    try? engine!.start()
    
  }
  
  /**
  Stops the tuner.
  */
  public func stop() {
    microphone!.stop()
    pitchTap!.stop()
    engine!.stop()
  }
  
  func tap_handler(freq: [Float], amp: [Float]) -> Void {
    print("freq real: %f\n", freq[0])
    print("freq imag: %f\n", freq[1])
    print(" amp real: %f\n", amp[0])
    print(" amp imag: %f\n", amp[1])
    if let d = self.delegate {
      if amp[0] > self.threshold
      {
        let amplitude = amp[0]
        let frequency = freq[0]
        let output = Tuner.newOutput(frequency, amplitude)
        DispatchQueue.main.async {
          d.tunerDidUpdate(self, output: output)
        }
      }
    }
  }
  
  /**
   Exponential smoothing:
   https://en.wikipedia.org/wiki/Exponential_smoothing
  */
  fileprivate func smooth(_ value: Float) -> Float {
    var frequency = value
    if smoothingBuffer.count > 0 {
      let last = smoothingBuffer.last!
      frequency = (smoothing * value) + (1.0 - smoothing) * last
      if smoothingBuffer.count > smoothingBufferCount {
        smoothingBuffer.removeFirst()
      }
    }
    smoothingBuffer.append(frequency)
    return frequency
  }
  
  static func newOutput(_ frequency: Float, _ amplitude: Float) -> TunerOutput {
    let output = TunerOutput()
    
    var norm = frequency
    while norm > frequencies[frequencies.count - 1] {
      norm = norm / 2.0
    }
    while norm < frequencies[0] {
      norm = norm * 2.0
    }
    
    var i = -1
    var min = Float.infinity
    for n in 0...frequencies.count-1 {
      let diff = frequencies[n] - norm
      if abs(diff) < abs(min) {
        min = diff
        i = n
      }
    }
    
    output.octave = i / 12
    output.frequency = frequency
    output.amplitude = amplitude
    output.distance = frequency - frequencies[i]
    output.pitch = String(format: "%@", sharps[i % sharps.count], flats[i % flats.count])
    
    return output
  }
}
