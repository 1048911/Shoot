//
//  ViewController.swift
//  Shoot

//
//  Created by CASE on 7/2/19.
//  Copyright © 2019 CASE. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //set the sceneView to show points when looking for the horizontal plane
        // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        
        sceneView.delegate = self
       
        sceneView.autoenablesDefaultLighting = true //adds default lighting to the scene to make object appear 3D
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
       /* run this code to check if the phone can handle the correct figuration and to offer a diff. configuration if it cannot.
        let configuration = ARWorldTrackingConfiguration.isSupported ? ARWorldTrackingConfiguration() : AROrientationTrackingConfiguration()
        */
       
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
      
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK:- AR METHODS
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height:  CGFloat(planeAnchor.extent.z)) //planes use x for width and z for height becaue it is a flat horizontal plane
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0) //SCNPlanes are vertical but we are defining a horizontal plane so we must rotate it around the x-axis
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            // alternative sceneView.scene.rootNode.addChildNode(planeNode)
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
    
    //MARK:- TOUCH METHODS
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types:.existingPlaneUsingExtent)
            
            if let hitResult = results.first {
             
                    let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                    if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                            diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: hitResult.worldTransform.columns.3.z) //adds half of the height of the dice to the height position so that the entire object sits on top of the plane
                       
                        diceArray.append(diceNode)
                        sceneView.scene.rootNode.addChildNode(diceNode)
                        
                        roll(dice: diceNode)
                        
                        }
            }
        }
    }
    
    
    //MARK:- DICE METHODS
    
    func rollAll(){
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    @IBAction func RollAgainButtonPressed(_ sender: UIBarButtonItem) {
    rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    
    
    
    

   
    
    
}
