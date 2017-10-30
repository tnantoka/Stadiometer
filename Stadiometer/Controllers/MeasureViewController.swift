//
//  MeasureViewController.swift
//  Stadiometer
//
//  Created by Tatsuya Tobioka on 2017/09/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import ARKit
import SceneKit

import PKHUD

class MeasureViewController: UIViewController {

    var startNode: SCNNode?
    var endNode: SCNNode?
    var lineNode: SCNNode?

    lazy private var sceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: .zero)
        view.addSubview(sceneView)

        #if DEBUG
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        #endif
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "sceneView": sceneView
        ]
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[sceneView]|",
            options: [],
            metrics: nil,
            views: views
        )
        let horizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[sceneView]|",
            options: [],
            metrics: nil,
            views: views
        )
        NSLayoutConstraint.activate(vertical + horizontal)

        return sceneView
    }()

    lazy private var cancelItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelItemDidTap))
    }()
    lazy private var resultItem: UIBarButtonItem = {
        UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }()
    lazy private var redoItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redoItemDidTap))
    }()
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    lazy private var saveItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemDidTap))
    }()

    var distance: Float {
        guard let startNode = startNode, let endNode = endNode else {
            return 0.0
        }

        let dx = endNode.position.x - startNode.position.x
        let dy = endNode.position.y - startNode.position.y
        let dz = endNode.position.z - startNode.position.z

        let distance = sqrt(dx * dx + dy * dy + dz * dz)
        return distance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setToolbarHidden(false, animated: true)

        // Do any additional setup after loading the view.
        title = NSLocalizedString("Measure", comment: "")

        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = saveItem
        toolbarItems = [resultItem, flexibleItem, redoItem]

        view.backgroundColor = Color.background

        _ = sceneView
        updateItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)

        HUD.show(.progress)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        HUD.hide()
    }

    // MARK: - Actions

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sceneView)

        let featureResults = sceneView.hitTest(location, types: .featurePoint)
        if let result = featureResults.first {
//        if let result = featureResults.last {
            if let startNode = startNode {
                if endNode == nil {
                    let endNode = addNode(result: result)
                    self.endNode = endNode

                    updateResult(distance: Photo.round(distance: distance))

                    lineNode = addLine(fromNode: startNode, toNode: endNode, length: distance)
                }
            } else {
                startNode = addNode(result: result)
            }
            updateItems()
        }
    }

    @objc private func cancelItemDidTap(sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func saveItemDidTap(sender: Any) {
        UIGraphicsBeginImageContextWithOptions(sceneView.frame.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            sceneView.drawHierarchy(in: sceneView.bounds, afterScreenUpdates: false)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                Photo.save(image: image, distance: distance)
                HUD.flash(.success, delay: 0.3)
            }
        }
        defer {
            UIGraphicsEndImageContext()
        }
    }

    @objc private func redoItemDidTap(sender: Any) {
        defer {
            updateItems()
        }
        if let endNode = endNode, let lineNode = lineNode {
            self.endNode = nil
            self.lineNode = nil
            endNode.removeFromParentNode()
            lineNode.removeFromParentNode()
            return
        }
        if let startNode = startNode {
            self.startNode = nil
            startNode.removeFromParentNode()
        }
    }

    // MARK: - Utilities

    private func addNode(result: ARHitTestResult) -> SCNNode {
        let matrix = result.worldTransform
        let column = matrix.columns.3
        let vector = SCNVector3(column.x, column.y, column.z)

        let box = SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0.002)
        let boxNode = SCNNode(geometry: box)
        boxNode.position = vector
        boxNode.geometry?.materials.first?.diffuse.contents = Color.bar
        sceneView.scene.rootNode.addChildNode(boxNode)

        return boxNode
    }

    private func addLine(fromNode: SCNNode, toNode: SCNNode, length: Float) -> SCNNode {
        let box = SCNBox(width: 0.01, height: 0.01, length: CGFloat(length), chamferRadius: 0.002)
        let lineNode = SCNNode(geometry: box)
        lineNode.geometry?.materials.first?.diffuse.contents = Color.bar

        fromNode.addChildNode(lineNode)
        lineNode.position = SCNVector3Make(0, 0, -length / 2.0)
        fromNode.look(at: toNode.position)
        toNode.look(at: fromNode.position)
        return lineNode
    }

    private func updateResult(distance: String) {
        resultItem.title = Photo.centimeter(distance: distance)
    }

    private func updateItems() {
        redoItem.isEnabled = startNode != nil || endNode != nil
        saveItem.isEnabled = startNode != nil && endNode != nil
        if lineNode == nil {
            updateResult(distance: "?")
        }
    }
}

extension MeasureViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        HUD.hide()
        switch camera.trackingState {
        case .notAvailable:
            HUD.show(.labeledProgress(title: nil, subtitle: "Not Available"))
        case .limited(let reason):
            switch reason {
            case .initializing:
                HUD.show(.labeledProgress(title: nil, subtitle: "Initializing"))
            case .excessiveMotion:
                HUD.show(.labeledProgress(title: nil, subtitle: "Excessive Motion"))
            case .insufficientFeatures:
                HUD.show(.labeledProgress(title: nil, subtitle: "Insufficient Features"))
            }
        case .normal:
            break;
        }
    }
}
