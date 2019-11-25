//
//  CameraHandler.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/25.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraHandler: NSObject {
    
    static let shared = CameraHandler()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    
    var picker: UIImagePickerController?
    var imagePickedBlock: ((UIImage) -> Void)?
    var useForTrimView: Bool = false
    var capturedPhoto: Bool = false
    var transitionToLandscape = false
    var transitionToPortrait = false
    var cameraOrientation: UIDeviceOrientation = .portrait
    var cameraPortraitOverlay: UIView?
    var cameraLandscapeOverlay: UIView?
    var photoCapturedObserver: NSObjectProtocol?
    var photoRejectedObserver: NSObjectProtocol?
    
    func showCamera(vc: UIViewController, forTrimView: Bool = false, isSquare: Bool = true) {
        // First we check if the device has a camera (otherwise will crash in Simulator - also, some iPod touch models do not have a camera).
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if !isCameraAccessEnabled() {
                let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "This app"
                let alertTitle = NSLocalizedString("\"\(appName)\" Would Like to Access the Camera", comment: "")
                let alertMsg = NSLocalizedString("Please grant permission to use the Camera so that you can register your instruments.", comment: "")
                let actionTitle = NSLocalizedString("Open Settings", comment: "")
                
                let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: actionTitle, style: .cancel) { alert in
                    if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettingsURL as URL, options: [:], completionHandler: nil)
                    }
                })
                    
                vc.present(alert, animated: true, completion: nil)
                return
            }
        } else {
            let msg = NSLocalizedString("Device has no camera.", comment: "")
            showErrorAlert(vc: vc, message: msg)
            return
        }
        
        currentVC = vc
        useForTrimView = forTrimView

        cameraPortraitOverlay = setupOverlayView(isSquare: isSquare)
        cameraLandscapeOverlay = setupOverlayView(isSquare: isSquare, isLandscape: true)
        
        // Setup UIImagePickerController
        picker = UIImagePickerController()
        picker!.delegate = self
        picker!.sourceType = .camera
        updateOverlayView()
        
        photoCapturedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"), object:nil, queue:nil, using: { note in
            self.capturedPhoto = true
            self.picker!.cameraOverlayView?.isHidden = true
            self.cameraOrientation = UIDevice.current.orientation
        })
        
        photoRejectedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem"), object:nil, queue:nil, using: { note in
            self.capturedPhoto = false
            self.picker!.cameraOverlayView?.isHidden = false
        })
        
        currentVC.present(picker!, animated: true, completion: nil)
    }
    
    func showPhotoLibrary(vc: UIViewController) {
        currentVC = vc
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker = UIImagePickerController()
            picker!.delegate = self
            picker!.sourceType = .photoLibrary
            
            currentVC.present(picker!, animated: true, completion: nil)
        }
    }
    
    func isCameraAccessEnabled() -> Bool {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        var result = false
        
        switch cameraAuthorizationStatus {
            case .authorized:
                print("Camera access is: authorized")
                result = true
            case .denied:
                print("Camera access is: denied")
            case .notDetermined:
                print("Camera access is: not determined")
                fallthrough
            default:
                let semaphore = DispatchSemaphore(value: 0)
                
                // Prompting user for the permission to use the camera.
                AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                    if granted {
                        print("Granted access to \(cameraMediaType)")
                        result = true
                    } else {
                        print("Denied access to \(cameraMediaType)")
                    }
                    
                    semaphore.signal()
                }
                
                semaphore.wait()
        }
        
        return result
    }
    
    func setupOverlayView(isSquare: Bool, isLandscape: Bool = false) -> UIView {
        let deviceWidth = currentVC.view.bounds.width
        let deviceHeight = currentVC.view.bounds.height
        let rectHeight = deviceWidth / 2
        
        let overlayView = UIView(frame: currentVC.view.frame)
        overlayView.backgroundColor = UIColor.clear
        overlayView.isUserInteractionEnabled = false
        
        var topX: CGFloat = 0
        var topY: CGFloat = 0
        var topW: CGFloat = 0
        var topH: CGFloat = 0
        var bottomX: CGFloat = 0
        var bottomY: CGFloat = 0
        var bottomW: CGFloat = 0
        var bottomH: CGFloat = 0
        
        if IS_PHONE {
            let previewBaseH: CGFloat = IS_PHONE_X ? 500 : 426.5
            let previewScaledH = IS_PHONE_X ? getScaledHeightForPhoneWithNotch(base: previewBaseH) : getScaledHeight(base: previewBaseH)
            let previewHeightMinusSquareCenter = previewScaledH - deviceWidth
            let previewHeightMinusRectCenter = previewScaledH - rectHeight
            var previewBaseTopH: CGFloat = (320 == deviceWidth) ? 18.75 : (IS_PHONE_X ? 4 : 22.75)
            
            // Trimming aspect ratio: 1:1 or 2:1
            previewBaseTopH = isSquare ? previewHeightMinusSquareCenter : previewHeightMinusRectCenter
            previewBaseTopH /= 2
            
            topX = 0
            topH = previewBaseTopH
            topY = (320 == deviceWidth) ? 40 : (IS_PHONE_X ? 121 : 44)
            topW = deviceWidth
            
            bottomX = 0
            bottomH = topH
            bottomY = (topY + previewScaledH) - bottomH
            bottomW = deviceWidth
        } else if IS_PAD {
            let padScale = (ScreenSize.SCREEN_HEIGHT / IPAD_LENGTH)
            let previewBaseH = CGFloat(1024)
            let bottomBarBaseHeight = CGFloat(72.5)
            var previewBaseTopH = CGFloat(92) * padScale
            let previewScaledH = previewBaseH * padScale
            let previewHeightMinusSquareCenter = previewScaledH - deviceWidth
            let previewHeightMinusRectCenter = previewScaledH - rectHeight
            
            // Trimming aspect ratio: 1:1 or 2:1
            previewBaseTopH = isSquare ? previewHeightMinusSquareCenter : previewHeightMinusRectCenter
            previewBaseTopH /= 2
            
            topX = 0
            topH = previewBaseTopH
            topY = 0
            topW = deviceWidth
            
            bottomX = 0
            bottomH = topH
            bottomY = deviceHeight - bottomH
            bottomW = deviceWidth
            
            if isLandscape {
                let overlayHMinusBottomBar = deviceWidth - bottomBarBaseHeight
                let overlayWMinusSquareCenter = previewScaledH - overlayHMinusBottomBar
                let overlayWMinusRectCenter = previewScaledH - (overlayHMinusBottomBar / 2)
                
                // topRect -> leftRect
                topX = 0
                topY = 0
                topW = isSquare ? (overlayWMinusSquareCenter / 2) : (overlayWMinusRectCenter / 2)
                topH = deviceWidth
                
                // bottomRect -> rightRect
                bottomX = deviceHeight - topW
                bottomY = 0
                bottomW = topW
                bottomH = deviceWidth
            }
        } else {
            // Do nothing
        }
        
        let topRect = CGRect(x: topX, y: topY, width: topW, height: topH)
        let maskView1 = UIView(frame: topRect)
        maskView1.backgroundColor = UIColor.black
        maskView1.alpha = 0.5
        overlayView.addSubview(maskView1)
        
        let bottomRect = CGRect(x: bottomX, y: bottomY, width: bottomW, height: bottomH)
        let maskView2 = UIView(frame: bottomRect)
        maskView2.backgroundColor = UIColor.black
        maskView2.alpha = 0.5
        overlayView.addSubview(maskView2)
        
        return overlayView
    }
    
    func updateOverlayView() {
        var overlayView = cameraPortraitOverlay

        if IS_PAD {
            let orientation = UIDevice.current.orientation
            let cameraRect = picker!.view.bounds
            
            if transitionToLandscape || (!useForTrimView && orientation.isLandscape && (cameraRect.height > cameraRect.width)) {
                overlayView = cameraLandscapeOverlay
            }
        }
        
        picker!.cameraOverlayView = overlayView
    }
    
    func clearCameraObservers() {
        cameraPortraitOverlay = nil
        cameraLandscapeOverlay = nil
        capturedPhoto = false
        transitionToLandscape = false
        transitionToPortrait = false
        
        NotificationCenter.default.removeObserver(photoCapturedObserver!)
        NotificationCenter.default.removeObserver(photoRejectedObserver!)
    }
    
}

extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if .camera == picker.sourceType {
            clearCameraObservers()
        }
        
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            var pickerImage = image
            
            if .camera == picker.sourceType {
                if cameraOrientation.isLandscape {
                    var newOrientation = UIImage.Orientation.right
                    
                    if transitionToLandscape {
                        if .right == image.imageOrientation {
                            newOrientation = (.landscapeLeft == cameraOrientation) ? .down : .up
                        } else if .left == image.imageOrientation {
                            newOrientation = (.landscapeLeft == cameraOrientation) ? .up : .down
                        }
                    }
                    
                    if let cgImage = image.cgImage {
                        pickerImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: newOrientation)
                    }
                } else if cameraOrientation.isPortrait {
                    if !transitionToPortrait {
                        let currentOrientation = image.imageOrientation
                        if (.up == currentOrientation) || (.down == currentOrientation) {
                            if let cgImage = image.cgImage {
                                pickerImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
                            }
                        }
                    }
                } else {
                    // Do nothing
                }
                
                print("Image size: " + pickerImage.size.debugDescription)
                
                if !useForTrimView {
                    let width = pickerImage.size.width
                    let height = pickerImage.size.height
                    let isPortrait = (height < width) ? false : true
                    
                    let length = isPortrait ? width : height
                    let centerX = isPortrait ? 0 : ((width - length) / 2)
                    let centerY = !isPortrait ? 0 : ((height - length) / 2)
                    
                    pickerImage = pickerImage.croppedImage(inRect: CGRect(x: centerX, y: centerY, width: length, height: length))!
                    print("Cropped size: " + pickerImage.size.debugDescription)
                }
                
                 clearCameraObservers()
            }

            self.imagePickedBlock?(pickerImage)

            if let vc = currentVC as? MainViewController {
                vc.dismiss(animated: true, completion: {
                    vc.segueToTrimView()
                })
            } else {
                currentVC.dismiss(animated: true, completion: nil)
            }
        } else {
            print("Something went wrong with the image.")
            
            currentVC.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension UIImagePickerController {
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let orientation = UIDevice.current.orientation
        let cameraHandler = CameraHandler.shared
        
        if orientation.isLandscape {
            print("Orientation change to Landscape")
        } else if orientation.isPortrait {
            print("Orientation change to Portrait")
        } else if orientation.isFlat {
            print("Orientation change to Flat")
        } else {
            print("Orientation change to -unknown-")
        }
        
        cameraHandler.transitionToLandscape = orientation.isLandscape ? true : false
        cameraHandler.transitionToPortrait = orientation.isPortrait ? true : false
        cameraHandler.cameraOrientation = orientation
        cameraHandler.updateOverlayView()
        cameraHandler.picker!.cameraOverlayView?.isHidden = cameraHandler.capturedPhoto
    }
    
}
