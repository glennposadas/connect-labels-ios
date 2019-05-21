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

    @IBOutlet weak var label_WordNotFound: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var label_FoundWord: UILabel!
    @IBOutlet weak var coloringView: UIView!

    private var shapeLayer: CAShapeLayer!
    private var origin: CGPoint!
    private var originLabel: UILabel?

    var sampleWord = "LOVE"

    /// Contains all labels
    var shuffledSubviews = [UILabel]()
    /// Contains only the labels with texts
    var labels = [UILabel]()
    /// Contains the connected labels.
    var connectedLabels = Set<UILabel>()

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

    @objc func handlePan(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            shapeLayer = createShapeLayer(for: gesture.view!)
            origin = gesture.location(in: gesture.view)
            
//            let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
//            v.backgroundColor = .blue
//            self.coloringView.addSubview(v)
//            v.center = origin
            
            self.labels.forEach({ (label) in
                if label.frame.contains(origin) {
                    self.originLabel = label
                    self.label_FoundWord.text!.append(label.text!.first!)
                    self.connectedLabels.insert(label)
                    
                    self.animateSelectedLabel(label)
                }

            })
            
        } else if gesture.state == .changed {
            let path = UIBezierPath()
            path.move(to: origin)
            path.addLine(to: gesture.location(in: gesture.view))
            shapeLayer.path = path.cgPath

            let pt = gesture.location(in: gesture.view)
            
            print("CHANGED")
            
            self.labels.forEach { (label) in
                
                
                guard let originLabel = self.originLabel else { return }
                if label.frame.contains(pt) && !originLabel.bounds.contains(pt) {
                    print("TOUCHED!!! 🎉🎉🎉")
                    path.close()
                    
                    if !self.connectedLabels.contains(where: { (currentLabel) -> Bool in
                        return currentLabel.tag == label.tag
                    }) {
                        // create new path/line.
                        // set new origin
                        self.origin = pt
                        
                        self.shapeLayer = self.createShapeLayer(for: gesture.view!)
                        self.label_FoundWord.text!.append(label.text!.first!)
                        self.connectedLabels.insert(label)
                        
                        self.animateSelectedLabel(label)
                        
                    }

                }
                
            }


        } else if gesture.state == .failed || gesture.state == .cancelled {
            shapeLayer = nil
            print("CANCELED OR FAILED")
        } else if gesture.state == .ended {
            shapeLayer = nil
            // Do something.
            print("ENDED")
            
            if self.connectedLabels.count <= 1 {
                // Means no connection happened further.
                self.tryAgain()
                return
            }
            
            // Business logic / Game logic.
            // Check if found a word!
            if self.label_FoundWord.text == self.sampleWord {
                self.showToast(success: true)
            } else {
                self.showToast(success: false)
            }
            
            self.tryAgain()
        }
    }
    
    func animateSelectedLabel(_ label: UILabel) {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            label.backgroundColor = .random
            label.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            label.layer.cornerRadius = label.frame.width / 2
            label.clipsToBounds = true
            label.layoutIfNeeded()
        })

    }
    
    func tryAgain() {
        self.connectedLabels.removeAll()
        self.origin = .zero
        self.removeAllLines()
        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.labels.forEach({ (label) in
                label.backgroundColor = .clear
            })
        }, completion: nil)
        
        self.label_FoundWord.text = ""
    }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupData()

        let pan = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan.minimumPressDuration = 0
        self.coloringView.addGestureRecognizer(pan)
    }

    func setupData() {
        if self.sampleWord.count > 7 { return }

        self.label_FoundWord.text = ""
        self.labels.removeAll()
        self.connectedLabels.removeAll()

        self.removeAllLines()

        self.shuffledSubviews = self.coloringView.subviews.shuffled() as! [UILabel]
        
        self.clearAllLabelsAndTheirAttributes()

        for (index, letter) in self.sampleWord.enumerated() {
            let label = self.shuffledSubviews[index]
            label.text = "\(letter)"
            self.labels.append(label)
            //label.sizeToFit()
        }

    }
    
    func clearAllLabelsAndTheirAttributes() {
        _ = self.shuffledSubviews.map {
            $0.text = ""
            $0.backgroundColor = .clear
        }
    }
    
    func removeAllLines() {
        _ = self.coloringView.layer.sublayers?.map {
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        }
    }

    func showToast(success: Bool) {
        self.label_WordNotFound.backgroundColor = success ? UIColor(red:0.3, green:0.69, blue:0.31, alpha:1) : UIColor(red:0.82, green:0.01, blue:0.11, alpha:1)
        self.label_WordNotFound.text = success ? "WELL DONE! 🎉" : "WORD NOT FOUND! 🙄"
        
        UIView.animate(withDuration: 0.3) {
            self.topConstraint.constant = 30.0
            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            UIView.animate(withDuration: 0.3) {
                self.topConstraint.constant = -100
                self.view.layoutIfNeeded()
            }
        }
    }
}


extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
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
