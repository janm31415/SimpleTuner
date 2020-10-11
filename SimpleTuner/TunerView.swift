//
//  TunerView.swift
//  SimpleTuner
//
//  Created by Jan Maes on 10/10/2020.
//

import UIKit

class TunerView: UIView {
  
  let pitchLabel: UILabel
  let gaugeView: WMGaugeView
  
  fileprivate let titleLabel: UILabel
  fileprivate let pitchTitleLabel: UILabel
  
  override init(frame: CGRect)
  {
    titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
    titleLabel.adjustsFontSizeToFitWidth = true
    titleLabel.textAlignment = .center
    titleLabel.text = "Tuner"
    
    gaugeView = WMGaugeView()
    gaugeView.style = WMGaugeViewStyleFlatThin()
    gaugeView.maxValue = 50.0
    gaugeView.minValue = -50.0
    gaugeView.scaleDivisions = 10
    gaugeView.scaleEndAngle = 270
    gaugeView.scaleStartAngle = 90
    gaugeView.scaleSubdivisions = 5
    gaugeView.showScaleShadow = false
    gaugeView.scaleDivisionsLength = 0.05
    gaugeView.scaleDivisionsWidth = 0.007
    gaugeView.scaleSubdivisionsLength = 0.02
    gaugeView.scaleSubdivisionsWidth = 0.002
    gaugeView.backgroundColor = UIColor.clear
    gaugeView.scaleFont = UIFont.systemFont(ofSize: 0.05, weight: UIFont.Weight.ultraLight)
    
    pitchTitleLabel = UILabel()
    pitchTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.light)
    pitchTitleLabel.adjustsFontSizeToFitWidth = true
    pitchTitleLabel.textAlignment = .center
    pitchTitleLabel.text = "Pitch"
    
    pitchLabel = UILabel()
    pitchLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
    pitchLabel.adjustsFontSizeToFitWidth = true
    pitchLabel.textAlignment = .center
    pitchLabel.text = "--"
  
        
    super.init(frame: frame)
    
    addSubview(titleLabel)
    addSubview(gaugeView)
    addSubview(pitchTitleLabel)
    addSubview(pitchLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.frame = CGRect(x: 0.0, y: 30, width: bounds.width, height: bounds.height / 18.52)
    gaugeView.frame = CGRect(x: 0, y: ((bounds).height - (bounds).width) / 2.0, width: (bounds).width, height: (bounds).width)
    pitchTitleLabel.frame = CGRect(x: 0, y: gaugeView.frame.origin.y + 0.85 * (gaugeView.bounds).height, width: (bounds).width, height: (bounds).height / 23.82)
    pitchLabel.frame = CGRect(x: 0, y: pitchTitleLabel.frame.origin.y + pitchTitleLabel.frame.height, width: bounds.width, height: bounds.height / 18.52)   
  }
  
}
