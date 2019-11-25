//
//  TrimViewController.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/25.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import UIKit

class TrimViewController: UIViewController {

    @IBOutlet weak var scrollViewFrame: UIView!
    @IBOutlet weak var cropAreaView: UIView!
    @IBOutlet weak var cropAreaHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var closeTopConstraintDefault: NSLayoutConstraint!
    @IBOutlet var closeTopConstraintPhoneX: NSLayoutConstraint!
    @IBOutlet var contentMaskHeightConstraintDefault: NSLayoutConstraint!
    @IBOutlet var contentMaskHeightConstraintPhoneX: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSave: UILabel!
    
    // Calculate the frame of crop area with respect to the actual image size
    var cropArea: CGRect {
        get {
            let scale = 1 / imageScrollView.zoomScale
            let imageFrame = imageScrollView.zoomView.frame
            let x = (imageScrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale
            let y = (imageScrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale
            let width = cropAreaView.frame.size.width * scale
            let height = cropAreaView.frame.size.height * scale
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }

    var imageScrollView: ImageScrollView!
    var imageID: Int = 0
    var isNewImageSet = false
    
    let kScrollViewFrameBaseHeightPhoneX: CGFloat = 682
    
    let dm = DataModel.shared
    
    // MARK: - View Lifecycle / Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default;
        notificationCenter.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // font sizes
        lblTitle.font = lblTitle.font.withSize(getScaledHeight(base: BASE_FONT_SIZE_M))
        lblSave.font = lblSave.font.withSize(getScaledHeight(base: BASE_FONT_SIZE_M))
        
        if IS_PHONE_X {
            lblSave.font = lblSave.font.withSize(lblSave.font.pointSize * 0.85)
        }

        // set Crop Area size (1st image: Square size; 2nd and 3rd images: Rectangle size)
        let cropAreaWidth: CGFloat = self.view.frame.width
        cropAreaHeightConstraint.constant = (0 == imageID) ? cropAreaWidth : (cropAreaWidth / 2)
        
        // setup frame for imageScrollView
        var targetFrame = self.view.bounds
        
        if IS_PHONE_X {
            let totalPadding = kSafeAreaTopPadding44 + kSafeAreaBottomPaddingDefault
            let currentSafeAreaHeight = ScreenSize.SCREEN_HEIGHT - totalPadding
            let baseSafeAreaHeight = IPHONE_X_LENGTH - totalPadding
            let targetHeight = floor(kScrollViewFrameBaseHeightPhoneX * (currentSafeAreaHeight / baseSafeAreaHeight))
            contentMaskHeightConstraintPhoneX.constant = targetHeight
            targetFrame.size.height = targetHeight
        } else {
            let targetHeight = floor(getScaledHeight(base: scrollViewFrame.bounds.height))
            targetFrame.size.height = targetHeight
        }
        
        imageScrollView = ImageScrollView(frame: targetFrame)
        imageScrollView.imageID = imageID
        scrollViewFrame.insertSubview(imageScrollView, at: 0)
        
        let imageNameList = self.dm.getImageNameList()
        let imagePath = imageNameList[imageID].isEmpty ? "" : self.dm.getImagePath(at: imageID)
        
        // set full image for selected image
        let image = (imagePath.isEmpty) ? nil : UIImage(contentsOfFile: imagePath)
        imageScrollView.display(image!)
        
        if self.dm.getImageHasTrimArea(at: imageID) {
            let verticalInset = self.dm.getImageScrollVerticalInset(at: imageID)
            let horizontalInset = self.dm.getImageScrollHorizontalInset(at: imageID)
            
            imageScrollView.zoomScale = self.dm.getImageScrollZoomScale(at: imageID)
            imageScrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
            imageScrollView.contentOffset = self.dm.getImageScrollContentOffset(at: imageID)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isNewImageSet {
            if let mainVC = MainViewController.sharedVC {
                mainVC.view.isUserInteractionEnabled = true
                mainVC.waitIndicator.stopAnimating()
            }
        }
        
        if !self.dm.getImageHasTrimArea(at: imageID) {
            setContentOffset()
        }
        
        imageScrollView.updateContentInsets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeTopConstraintDefault.isActive = !IS_PHONE_X ? true : false
        closeTopConstraintPhoneX.isActive = IS_PHONE_X ? true : false
        contentMaskHeightConstraintDefault.isActive = !IS_PHONE_X ? true : false
        contentMaskHeightConstraintPhoneX.isActive = IS_PHONE_X ? true : false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Custom Func
    
    func setContentOffset() {
        let cropAreaWidth: CGFloat = self.view.frame.width
        let contentSize = imageScrollView.contentSize
        
        // center scrollView offset
        var offset = CGPoint.zero
        offset.x = (contentSize.width / 2) - (cropAreaWidth / 2)
        offset.x = (0 > offset.x) ? 0 : offset.x
        offset.y = (contentSize.height / 2) - (imageScrollView.frame.height / 2)
        offset.y = (0 > offset.y) ? 0 : offset.y
        
        imageScrollView.contentOffset = offset
    }
    
    func crop() {
        self.dm.setImageHasTrimArea(at: imageID, inHasTrimArea: true)
        self.dm.setImageCropArea(at: imageID, inCropArea: cropArea)
        self.dm.setImageScrollZoomScale(at: imageID, inScrollZoomScale: imageScrollView.zoomScale)
        self.dm.setImageScrollContentOffset(at: imageID, inContentOffset: imageScrollView.contentOffset)
        self.dm.setImageScrollVerticalInset(at: imageID, inVerticalInset: imageScrollView.contentInset.top)
        self.dm.setImageScrollHorizontalInset(at: imageID, inHorizontalInset: imageScrollView.contentInset.left)
        self.dm.setDiscardImage(at: imageID, inDiscardImage: false)
        
        self.dm.saveAll()
    }
    
    func discardImage() {
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
            self.dm.saveAll()
        }
    }
    
    @objc func appDidEnterBackground() {
        self.dm.setDiscardImage(at: imageID, inDiscardImage: true)
        self.dm.saveAll()
    }
    
    // MARK: - IBAction
    
    @IBAction func saveTrimArea(_ sender: UIButton) {
        crop()
        
        let mainVC = MainViewController.sharedVC!
        mainVC.isNewImageSet = false
        
        self.dm.setTopImageID(inTopImageID: imageID)
        self.navigationController?.popToViewController(mainVC, animated: false)
    }
    
    @IBAction func goBackNoAnimate(_ sender: Any) {
        // cancel trimming and delete image
        if !self.dm.getImageHasTrimArea(at: imageID) {
            if 0 == imageID && !isNewImageSet {
                // Do nothing
            } else {
                discardImage()
            }
        }
        
        self.dm.setDiscardImage(at: imageID, inDiscardImage: false)
        self.dm.saveAll()
        self.navigationController?.popViewController(animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
     
    }
    */
    
}

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var zoomView: UIImageView!
    var imageID = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        self.bouncesZoom = false
        self.bounces = false
        self.isPagingEnabled = false
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.centerImage()
    }
    
    // MARK: - Configure scrollView to display new image
    
    func display(_ image: UIImage) {
        // 1. clear the previous image
        zoomView?.removeFromSuperview()
        zoomView = nil
        
        // 2. make a new UIImageView for the new image
        zoomView = UIImageView(image: image)
        self.addSubview(zoomView)
        self.configureFor(image.size)
    }
    
    func configureFor(_ imageSize: CGSize) {
        self.contentSize = imageSize
        self.setMaxMinZoomScaleForCurrentBounds()
        self.zoomScale = self.minimumZoomScale
    }
    
    func setMaxMinZoomScaleForCurrentBounds() {
        let boundsSize = self.bounds.size
        let imageSize = zoomView.bounds.size
        let cropAreaWidth = boundsSize.width
        let cropAreaHeight = (0 == imageID) ? cropAreaWidth : (cropAreaWidth / 2)
        
        // 1. calculate minimumZoomscale
        let xScale = cropAreaWidth / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = cropAreaHeight / imageSize.height  // the scale needed to perfectly fit the image height-wise
        //let minScale = min(xScale, yScale)            // use minimum of these to allow the image to become fully visible
        let minScale = max(xScale, yScale)              // use maximum of these for crop area to be filled
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = minScale * 5
    }
    
    func centerImage() {
        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize = self.bounds.size
        var frameToCenter = zoomView?.frame ?? CGRect.zero
        
        // center horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        zoomView?.frame = frameToCenter
    }
    
    func updateContentInsets() {
        let boundsSize = self.bounds.size
        let contentSize = self.contentSize
        let cropAreaWidth = boundsSize.width
        let cropAreaHeight = (0 == imageID) ? cropAreaWidth : (cropAreaWidth / 2)
        var verticalInset: CGFloat = 0
        var bottomInset: CGFloat = 0
        let horizontalInset: CGFloat = 0
        
        if boundsSize.height < contentSize.height {
            verticalInset = (self.frame.height / 2) - (cropAreaHeight / 2)
            bottomInset = verticalInset
        } else if boundsSize.height > contentSize.height {
            verticalInset = (contentSize.height - cropAreaHeight) / 2
            bottomInset = -verticalInset
            
            let newContentHeight = boundsSize.height + (verticalInset * 2)
            self.contentSize.height = newContentHeight
        } else {
            // Do nothing
        }

        self.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: bottomInset, right: horizontalInset)
    }
    
    // MARK: - UIScrollView Delegate Methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.updateContentInsets()
    }
    
}
