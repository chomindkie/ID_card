//
//  ViewController.swift
//  Harry Pokker
//
//  Created by Bilguun Batbold on 26/3/19.
//  Copyright © 2019 Bilguun. All rights reserved.
//
import UIKit
import SceneKit
import ARKit
import AVFoundation
//import ZXingObjC
import Vision
import SpriteKit
import RxSwift
import RxCocoa
import GoogleMobileVision


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  var barcode_value = "Can not detect"
  var labelNode = SKLabelNode(fontNamed: "HelveticaNeue-CondensedBlack")
  var barcodeRequest: VNDetectBarcodesRequest?
  var detector: GMVDetector?
  var ciImageRelay = PublishRelay<ARFrame>()
  let dispose = DisposeBag()
  //count for setting barcode_value
  var i = 0
  
  //    var processing = false
  //    let imgView: UIImageView = {
  //        let img = UIImageView()
  //        img.translatesAutoresizingMaskIntoConstraints = false
  //        return img
  //    }()
  let textView: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    //        label.center = CGPoint(x: 160, y: 285)
    //        label.textAlignment = .center
    //        label.text = barcode_value
    //        self.view.addSubview(label)
    
    // Set the view's delegate
    sceneView.delegate = self
    sceneView.showsStatistics = true
    self.initializeBarcodeRequest()
    self.initialGmvDetector()
    self.subscribeBarcodeDetector()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARImageTrackingConfiguration()
    
    // first see if there is a folder called "ARImages" Resource Group in our Assets Folder
    if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
      
      // if there is, set the images to track
      configuration.trackingImages = trackedImages
      // at any point in time, only 1 image will be tracked
      configuration.maximumNumberOfTrackedImages = 1
      configuration.isAutoFocusEnabled = true
    }
    
    // Run the view's session
    sceneView.session.run(configuration)
    sceneView.session.delegate = self
    
    //        self.view.addSubview(imgView)
    //        imgView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    //        imgView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    //        imgView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    //        imgView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    
    //        self.view.addSubview(textView)
    //        textView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    //        textView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    //        textView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    //        textView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  
  // MARK: - ARSCNViewDelegate
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    // if the anchor is not of type ARImageAnchor (which means image is not detected), just return
    guard let imageAnchor = anchor as? ARImageAnchor else { return }
    //find our video file
    
    //        let videoItem = AVPlayerItem(url: URL(fileURLWithPath: fileUrlString))
    //
    //        let player = AVPlayer(playerItem: videoItem)
    //        //initialize video node with avplayer
    //        let videoNode = SKVideoNode(avPlayer: player)
    //        player.play()
    //        // add observer when our player.currentItem finishes player, then start playing from the beginning
    //        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { (notification) in
    //            player.seek(to: CMTime.zero)
    //            player.play()
    //            print("------------------------------------------")
    //            print("Looping Video")
    //        }
    
    // set the size (just a rough one will do)
    //        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
    //        // center our video to the size of our video scene
    //        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
    //        // invert our video so it does not look upside down
    //        videoNode.yScale = -1.0
    //        // add the video to our scene
    //        videoScene.addChild(videoNode)
    //        // create a plan that has the same real world height and width as our detected image
    //        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
    //        // set the first materials content to be our video scene
    //        plane.firstMaterial?.diffuse.contents = videoScene
    //        // create a node out of the plane
    //        let planeNode = SCNNode(geometry: plane)
    //        // since the created node will be vertical, rotate it along the x axis to have it be horizontal or parallel to our detected image
    //        planeNode.eulerAngles.x = -Float.pi / 2
    //        // finally add the plane node (which contains the video node) to the added node
    //        node.addChildNode(planeNode)
    
    
    //text
    let skScene = SKScene(size: CGSize(width: 200, height: 200))
    skScene.backgroundColor = UIColor.clear
    
    let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 200), cornerRadius: 10)
    rectangle.fillColor = #colorLiteral(red: 0.807843148708344, green: 0.0274509806185961, blue: 0.333333343267441, alpha: 1.0)
    rectangle.strokeColor = #colorLiteral(red: 0.439215689897537, green: 0.0117647061124444, blue: 0.192156866192818, alpha: 1.0)
    rectangle.lineWidth = 5
    rectangle.alpha = 0.4
    
    labelNode.text = ""
    labelNode.fontSize = 20
    labelNode.horizontalAlignmentMode = .center
    labelNode.verticalAlignmentMode = .center
    labelNode.position = CGPoint(x:100,y:100)
    
    skScene.addChild(rectangle)
    skScene.addChild(labelNode)
    
    let plane2 = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
    let material = SCNMaterial()
    material.isDoubleSided = true
    material.diffuse.contents = skScene
    material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
    plane2.materials = [material]
    
    let plan2node = SCNNode(geometry: plane2)
    plan2node.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
    plan2node.eulerAngles.x = -Float.pi / 2
    node.addChildNode(plan2node)
    
  }
  
  
  func initializeBarcodeRequest() {
    self.barcodeRequest = VNDetectBarcodesRequest(completionHandler: { request, error in
      
      guard let results = request.results else {
        print("!!!!!!!!!!")
        return
        
      }
      
      
      for result in results {
        
        if let barcode = result as? VNBarcodeObservation {
          self.i = 0
          self.barcode_value = barcode.payloadStringValue!
          print("barcode= \(barcode.payloadStringValue)")
          print("Symbology: \(barcode.symbology.rawValue)")
          
          
          
          if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
            let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
            print("Payload: \(String(describing: content))")
            print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
            print("Symbol-Version: \(desc.symbolVersion)")
          }
        }
      }
    })
  }
  
  func initialGmvDetector() {
    self.detector = GMVDetector(ofType: GMVDetectorTypeBarcode,
                                options: [GMVDetectorBarcodeFormats : GMVDetectorBarcodeFormat.code128.rawValue])
  }
  
  func subscribeBarcodeDetector() {
    let framePerSeconds = RxTimeInterval.milliseconds(1)
    self.ciImageRelay.asObservable()
      .throttle(framePerSeconds, scheduler: MainScheduler.instance)
      .subscribe(onNext: { (frame) in
        print("frame coming")
        let pixelBuffer = frame.capturedImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let tempContext = CIContext(options: nil)
        guard let videoImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer) , height: CVPixelBufferGetHeight(pixelBuffer))) else {
          return
        }
        let image = UIImage(cgImage: videoImage)
        guard let detector = self.detector else {
          return
        }
        guard let barcode = detector.features(in: image, options: nil) else {
          return
        }

        barcode.forEach({ (feature) in
          if let barcodeFeature = feature as? GMVBarcodeFeature {
            print("bar code",barcodeFeature.displayValue)
          }
        })

    })
  }
  
    func cropimage(barcode: VNBarcodeObservation, image: CIImage) -> CIImage {
        let percentage: CGFloat = 0.6
        
        let width = barcode.boundingBox.width * CGFloat(image.extent.size.width)
        let height = barcode.boundingBox.height * CGFloat(image.extent.size.height)
        let x = barcode.boundingBox.origin.x * CGFloat(image.extent.size.width)
        let y = barcode.boundingBox.origin.y * CGFloat(image.extent.size.height)
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        let increasedRect = rect.insetBy(dx: width * -percentage, dy: height * -percentage)
        return image.cropped(to: increasedRect)
    }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    self.ciImageRelay.accept(frame)
  }
}
