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
                    self.label_FoundWord.text!.append($0.text!.first!)
                }
            }
            
        } else if gesture.state == .changed {
            let path = UIBezierPath()
            path.move(to: origin)
            path.addLine(to: gesture.location(in: gesture.view))
            shapeLayer.path = path.cgPath

            let pt = gesture.location(in: gesture.view)
            
            print("CHANGED")
            
            self.labels.forEach { (label) in
                
                
                guard let originLabel = self.originLabel else { return }
                if label.frame.contains(pt) && !originLabel.frame.contains(pt) {
                    print("TOUCHED!!! 🎉🎉🎉")
                    path.close()
                    
                    
                    DispatchQueue.once(token: "\(label.tag)", block: {
                        // create new path/line.
                        // set new origin
                        self.origin = pt
                        shapeLayer = createShapeLayer(for: gesture.view!)
                        self.label_FoundWord.text!.append(label.text!.first!)
                    })
                    
                    
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

        self.label_FoundWord.text = ""
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




import UIKit

extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    class func once(file: String = #file, function: String = #function, line: Int = #line, block: (()->Void)) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    
    class func once(token: String, block: (()->Void)) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
