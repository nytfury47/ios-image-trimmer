//
//  MainViewController.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/25.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var fullImage: UIImageView!
    @IBOutlet weak var noImageText: UILabel!
    
    @IBOutlet weak var thumbImage1: UIImageView!
    @IBOutlet weak var thumbImage1Add: UIImageView!
    @IBOutlet weak var thumbImage1Button: UIButton!
    @IBOutlet weak var thumbImage1Label: UILabel!
    
    @IBOutlet weak var thumbImage2: UIImageView!
    @IBOutlet weak var thumbImage2Button: UIButton!
    @IBOutlet weak var thumbView2: UIView!
    
    @IBOutlet weak var thumbImage3: UIImageView!
    @IBOutlet weak var thumbImage3Button: UIButton!
    @IBOutlet weak var thumbView3: UIView!
    
    @IBOutlet weak var trimButton: UIButton!
    @IBOutlet weak var trimButtonImage: UIImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonImage: UIImageView!
    
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet var closeTopConstraintDefault: NSLayoutConstraint!
    @IBOutlet var closeTopConstraintPhoneX: NSLayoutConstraint!
    @IBOutlet var headerImageWidthConstraintPhone: NSLayoutConstraint!
    @IBOutlet var headerImageWidthConstraintPad: NSLayoutConstraint!
    @IBOutlet var thumbBoxStackWidthConstraintPhone: NSLayoutConstraint!
    @IBOutlet var thumbBoxStackWidthConstraintPad: NSLayoutConstraint!
    @IBOutlet var thumbBoxWidthConstraintPhone: NSLayoutConstraint!
    @IBOutlet var thumbBoxWidthConstraintPad: NSLayoutConstraint!
    
    var thumbImageList = [UIImageView]()
    var thumbViewList = [UIView]()
    
    var pickerImage: UIImage?
    
    var isNewImageSet = false
    var isManualSegueToTrimView = false
    var hideStatusBar = false
    
    public static var sharedVC : MainViewController?
    
    let dm = DataModel.shared
    
    let kBorderWidth: CGFloat = 2
    let kSelectedColor = UIColor(red: 12/255, green: 162/255, blue:175/255, alpha: 1)
    
    // MARK: - View Lifecycle / Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        thumbImageList.append(contentsOf: [thumbImage1, thumbImage2, thumbImage3])
        thumbViewList.append(contentsOf: [thumbImage1, thumbView2, thumbView3])
        
        // font sizes
        lblTitle.font = lblTitle.font.withSize(getScaledHeight(base: BASE_FONT_SIZE_M))
        noImageText.font = noImageText.font.withSize(getScaledHeight(base: BASE_FONT_SIZE_XXXL))
        thumbImage1Label.font = thumbImage1Label.font.withSize(getScaledHeight(base: BASE_FONT_SIZE_S))
        
        MainViewController.sharedVC = self
        
        // check for image to discard
        if self.dm.getImageInfoList().count != 0 {
            let imageNameList = self.dm.getImageNameList()
            
            for index in 0..<imageNameList.count {
                if self.dm.getDiscardImage(at: index) {
                    // delete from app storage
                    if !imageNameList[index].isEmpty {
                        do {
                            try FileManager.default.removeItem(atPath: self.dm.getImagePath(at: index))
                        } catch {
                            print("Error in deleting image: \(error)")
                        }
                        
                        // reset image name
                        self.dm.setImageName(at: index, inImageName: "")
                        self.dm.setDiscardImage(at: index, inDiscardImage: false)
                        self.dm.saveAll()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideStatusBar = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        if !isNewImageSet {
            setThumbImage()
            setSelectedImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeTopConstraintDefault.isActive = !IS_PHONE_X ? true : false
        closeTopConstraintPhoneX.isActive = IS_PHONE_X ? true : false
        headerImageWidthConstraintPhone.isActive = IS_PHONE ? true : false
        headerImageWidthConstraintPad.isActive = IS_PAD ? true : false
        thumbBoxStackWidthConstraintPhone.isActive = IS_PHONE ? true : false
        thumbBoxStackWidthConstraintPad.isActive = IS_PAD ? true : false
        thumbBoxWidthConstraintPhone.isActive = IS_PHONE ? true : false
        thumbBoxWidthConstraintPad.isActive = IS_PAD ? true : false
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }

    // MARK: - Custom function
    
    func setThumbImage() {
        let imageNameList = self.dm.getImageNameList()
        
        for index in 0..<imageNameList.count {
            let imagePath = imageNameList[index].isEmpty ? "" : self.dm.getImagePath(at: index)
            
            thumbImageList[index].isHidden = (imagePath.isEmpty) ? true : false
            thumbImageList[index].image = (imagePath.isEmpty) ? nil : UIImage(contentsOfFile: imagePath)
            
            // if has trim area
            if !imagePath.isEmpty && self.dm.getImageHasTrimArea(at: index) {
                let cropArea = self.dm.getImageCropArea(at: index)
                let croppedImage = thumbImageList[index].image?.croppedImage(inRect: cropArea)
                thumbImageList[index].image = croppedImage
            }
            
            if 0 == index {
                thumbImageList[index].isHidden = false
                thumbImage1Add.isHidden = (imagePath.isEmpty) ? false : true
            }
        }
    }
    
    func setSelectedImage() {
        let imageID = self.dm.getTopImageID()
        let imageNameList = self.dm.getImageNameList()
        let imagePath = imageNameList[imageID].isEmpty ? "" : self.dm.getImagePath(at: imageID)
        let thumbV = (nil == thumbImageList[imageID].image) ? thumbViewList[imageID] : thumbImageList[imageID]
        
        // set full image for selected image
        noImageText.isHidden = (imagePath.isEmpty) ? false : true
        fullImage.image = (imagePath.isEmpty) ? nil : UIImage(contentsOfFile: imagePath)
        
        // if has trim area
        if !imagePath.isEmpty && self.dm.getImageHasTrimArea(at: imageID) {
            let cropArea = self.dm.getImageCropArea(at: imageID)
            let croppedImage = fullImage.image?.croppedImage(inRect: cropArea)
            fullImage.image = croppedImage
        }
        
        // set selected thumb view
        thumbImage1Label.textColor = (0 == imageID) ? kSelectedColor : UIColor.black
        thumbV.layer.borderWidth = kBorderWidth
        thumbV.layer.borderColor = kSelectedColor.cgColor
        
        // set trim button
        trimButtonImage.alpha = (imagePath.isEmpty) ? 0.4 : 1
        trimButton.isEnabled = (imagePath.isEmpty) ? false : true
        
        // set delete button
        deleteButtonImage.alpha = (imagePath.isEmpty) ? 0.4 : 1
        deleteButton.isEnabled = (imagePath.isEmpty) ? false : true
    }
    
    func usePhoto(sourceType: UIImagePickerController.SourceType) {
        if .camera == sourceType {
            let imageID = self.dm.getTopImageID()
            CameraHandler.shared.showCamera(vc: self, forTrimView: true, isSquare: (0 == imageID) ? true : false)
        } else {
            CameraHandler.shared.showPhotoLibrary(vc: self)
        }
        
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.waitIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.pickerImage = image
        }
    }
    
    func deleteImage() {
        let imageID = self.dm.getTopImageID()
        let imageNameList = self.dm.getImageNameList()
        
        // delete from app storage
        if !imageNameList[imageID].isEmpty {
            do {
                try FileManager.default.removeItem(atPath: self.dm.getImagePath(at: imageID))
            } catch {
                print("Error in deleting image: \(error)")
            }
            
            // reset image name
            self.dm.setImageName(at: imageID, inImageName: "")
            self.dm.setImageHasTrimArea(at: imageID, inHasTrimArea: false)
        }
        
        // update view
        setThumbImage()
        setSelectedImage()
    }
    
    func segueToTrimView() {
        var newImage = self.pickerImage!
        
        if kImageMaxLength < newImage.size.width || kImageMaxLength < newImage.size.height {
            newImage = imageWithMaxLength(sourceImage: newImage, useWidth: (newImage.size.height <= newImage.size.width))
        }
        
        let imageName = DataModel.createImageFileName()
        let url = DataModel.getFileBaseURL().appendingPathComponent(imageName)
        let _ = saveImage(image: newImage.fixOrientation()!, fileURL: url)
        
        let imageID = self.dm.getTopImageID()
        self.dm.setImageName(at: imageID, inImageName: imageName)
        self.isNewImageSet = true
        
        // clear temp dir
        FileManager.default.clearTmpDirectory()

        isManualSegueToTrimView = true
        self.performSegue(withIdentifier: "toTopHeaderTrimView", sender: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func handleThumbImageButton(_ sender: UIButton) {
        let imageID = sender.tag
        self.dm.setTopImageID(inTopImageID: imageID)
        
        setSelectedImage()
        
        for index in 0...2 {
            // clear borders
            if index != imageID {
                let thumbV = (nil == thumbImageList[index].image) ? thumbViewList[index] : thumbImageList[index]
                thumbV.layer.borderWidth = 0
                thumbV.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        if nil == thumbImageList[imageID].image {
            let alertStyle: UIAlertController.Style = IS_PHONE ? .actionSheet : .alert
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
            
            alert.addAction(UIAlertAction(title: "Select from album", style: .default, handler: { (action) in
                self.usePhoto(sourceType: .photoLibrary)
            }))
            alert.addAction(UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
                self.usePhoto(sourceType: .camera)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func deletePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.deleteImage()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? TrimViewController {
            let imageID = self.dm.getTopImageID()
            destination.imageID = imageID
            destination.isNewImageSet = isManualSegueToTrimView ? true : false
            isManualSegueToTrimView = false
        }
    }

}
