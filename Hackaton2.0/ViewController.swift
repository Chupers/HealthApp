//
//  ViewController.swift
//  Hackaton2.0
//
//  Created by Eugenie Chupris on 7/12/19.
//  Copyright © 2019 Eugenie Chupris. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var ChartData = [Indicator]()
    {
        didSet{
            DispatchQueue.main.async {
                self.ChartCollectionView.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChartData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let Cell = self.ChartCollectionView.dequeueReusableCell(withReuseIdentifier:"Cell" , for: indexPath) as! ChartCollectionViewCell
        let queue = DispatchQueue.main
        queue.async {
            
        
            self.AnimaitChart(View: Cell.ChartView, indicator: self.ChartData[indexPath.row])
        }
        Cell.InfoLabel.text = "\( 100*ChartData[indexPath.row].Value!/ChartData[indexPath.row].Norms)%"
        return Cell
        
    }
    func AnimaitChart (View : UIView , indicator : Indicator){
        let trackLayer = CAShapeLayer()
        
        let shapeLayer = CAShapeLayer()
        let center = View.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap  = CAShapeLayerLineCap.round
        View.layer.addSublayer(trackLayer)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = indicator.Color.cgColor
        shapeLayer.lineWidth = 10
       
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.fromValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        shapeLayer.add(animation, forKey: "AnimaitChart")
        animation.toValue = CGFloat((indicator.Value!/indicator.Norms)*0.8)
        shapeLayer.strokeEnd = CGFloat((indicator.Value!/indicator.Norms)*0.8)
        View.layer.addSublayer(shapeLayer)
        
    }
  
    
    @IBAction func AddWater(_ sender: Any) {
        control.writeWater()
        var index = 0
        for item in ChartData {
            if (item.NameOfIndicator == "Water")
            {
                ChartData[index] = self.control.readWater()
                
            }
            index += 1
        }
        index = 0
    }
    
    
   let control = HealthControl()
    @IBOutlet weak var ChartCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        DispatchQueue.main.async {
            self.ChartData.append(self.control.readEnergy())
            self.ChartData.append(self.control.readWater())
            self.ChartData.append(self.control.readStep())
        }
        
       }


}

