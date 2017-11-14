//
//  ViewController.swift
//  ARRealMeasure
//
//  Created by iMeraj-MacbookPro on 14/11/2017.
//  Copyright © 2017 Meraj. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var meterImageView: UIImageView!
    @IBOutlet weak var resetImageView: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    
    lazy var session = ARSession()
    lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    lazy var isMeasuring = false
    lazy var vectorZero = SCNVector3()
    lazy var startValue = SCNVector3()
    lazy var endValue = SCNVector3()
    lazy var lines: [Line] = []
    var currentLine: Line?
    lazy var unit: DistanceUnit = .inch
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupScene() {
        targetImageView.isHidden = true
        sceneView.delegate = self
        sceneView.session = session
        loadingView.startAnimating()
        meterImageView.isHidden = true
        messageLabel.text = "Detecting the world…"
        resetButton.isHidden = true
        resetImageView.isHidden = true
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
    }
    
    func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue = SCNVector3()
    }
    
    @IBAction func resetButtonTapped(button: UIButton) {
        resetButton.isHidden = true
        resetImageView.isHidden = true
        resetValues()
        
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = line
            resetButton.isHidden = false
            resetImageView.isHidden = false
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        messageLabel.text = "Error occurred"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        messageLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        messageLabel.text = "Interruption ended"
    }
    
    func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screeenPosition: view.center) else { return }
        targetImageView.isHidden = false
        meterImageView.isHidden = false
        if lines.isEmpty {
            messageLabel.text = "Tap & Hold screen and move your phone..."
        }
        
        loadingView.stopAnimating()
        
        if isMeasuring {
            if startValue == vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
            }
            
            endValue = worldPosition
            currentLine?.update(to: endValue)
            messageLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
        }
    }
}
