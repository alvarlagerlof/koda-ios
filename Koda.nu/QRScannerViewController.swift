//
//  ScannerViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 02/09/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Firebase

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var objCaptureSession: AVCaptureSession?
    var objCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var vwQRCode: UIView?
    
   
    @IBOutlet weak var lblQRCodeResult: UILabel!
    
    
    var jsonString: String = ""
    
    var hasFoundCode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("qr_scan_open", parameters: [:])

        
        self.title = "Skanna QR kod"
        
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
        
    }
    
    
    func configureVideoCapture() {
        let objCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error: NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        if (error != nil) {
            let alertView: UIAlertView = UIAlertView(title: "Device Error", message:"Device not Supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done")
            alertView.show()
            return
        }
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    
    func initializeQRView() {
        vwQRCode = UIView()
        vwQRCode?.layer.borderColor = UIColor.red.cgColor
        vwQRCode?.layer.borderWidth = 5
        self.view.addSubview(vwQRCode!)
        self.view.bringSubview(toFront: vwQRCode!)
        
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            vwQRCode?.frame = CGRect.zero
            lblQRCodeResult.text = "No QR-code detected"
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObject(for: objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            vwQRCode?.frame = objBarCode.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                lblQRCodeResult.text = "Hittade QR-kod"
                jsonString = objMetadataMachineReadableCodeObject.stringValue
                
                
                
                if (hasFoundCode == false) {
                    hasFoundCode = true
                    
                    
                    // String to json objec
                    var json = JSON(data: jsonString.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                                        
                    
                    // Get Storyboard and ViewController
                    let storyboard = UIStoryboard(name: "Play", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "play") as! PlayViewController
                    
                    
                    
                    
                    // Check data
                    if let title = json["title"].string { vc.recivedTitle = title.base64decode }
                    if let url = json["url"].string { vc.recivedUrl = url.base64decode }
                    if let author = json["author"].string { vc.recivedAuthor = author.base64decode }
                    
                    
                    
                    // Push
                    if vc.recivedUrl != "" {
                        Analytics.logEvent("qr_scan_successful", parameters: [:])
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    
                                        
                }
                
            }
        }
    }
    
    

    

    override func viewDidAppear(_ animated: Bool) {
        hasFoundCode = false
    }
    
    
    
    func addVideoPreviewLayer() {
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        self.view.bringSubview(toFront: lblQRCodeResult)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
