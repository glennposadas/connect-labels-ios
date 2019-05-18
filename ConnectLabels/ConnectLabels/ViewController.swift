//
//  ViewController.swift
//  ConnectLabels
//
//  Created by Glenn Von C. Posadas on 17/05/2019.
//  Copyright © 2019 Glenn Von C. Posadas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var label_FoundWord: UILabel!
    @IBOutlet weak var coloringView: UIView!

    private var shapeLayer: CAShapeLayer!
    private var origin: CGPoint!
    private var originLabel: UILabel?

    var sampleWord = "LOVE"

    var labels = [UILabel]()

    // MARK: - Functions

    @IBAction func refresh(_ sender: Any) {
        self.setupData()
    }

    private func createShapeLayer(for view: UIView) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 3.0
        view.layer.addSublayer(shapeLayer)

        return shapeLayer
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            shapeLayer = createShapeLayer(for: gesture.view!)
            origin = gesture.location(in: gesture.view)
            
            _ = self.labels.map {
                if $0.frame.contains(origin) {
                    self.originLabel = $0
                }
            }
            
        } else if gesture.state == .changed {
            let path = UIBezierPath()
            path.move(to: origin)
            path.addLine(to: gesture.location(in: gesture.view))
            shapeLayer.path = path.cgPath

            let pt = gesture.location(in: gesture.view)
            
            print("CHANGED")
            
            _ = self.labels.map {
                
                guard let originLabel = self.originLabel else { return }
                if $0.frame.contains(pt) && !originLabel.frame.contains(pt) {
                    print("TOUCHED!!! 🎉🎉🎉")
                    path.close()
                    
                    
                }
            }

        } else if gesture.state == .failed || gesture.state == .cancelled {
            shapeLayer = nil
        } else if gesture.state == .ended {
            shapeLayer = nil
            // Do something.
        }
    }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupData()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        self.coloringView.addGestureRecognizer(pan)
    }

    func setupData() {
        if self.sampleWord.count > 7 { return }

        self.labels.removeAll()

        _ = self.coloringView.layer.sublayers?.map {
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
            
        }

        let subviews = self.coloringView.subviews.shuffled() as! [UILabel]
        _ = subviews.map {
            $0.text = ""
        }

        for (index, letter) in self.sampleWord.enumerated() {
            let label = subviews[index]
            label.text = "\(letter)"
            self.labels.append(label)
        }
    }

}

