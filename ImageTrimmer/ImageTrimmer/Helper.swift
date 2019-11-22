//
//  Helper.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/22.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import Foundation
import UIKit

let IPHONE_4_OR_LESS_LENGTH         = CGFloat(480.0)
let IPHONE_5_LENGTH                 = CGFloat(568.0)
let IPHONE_6_8_LENGTH               = CGFloat(667.0)
let IPHONE_6_8P_LENGTH              = CGFloat(736.0)
let IPHONE_X_LENGTH                 = CGFloat(812.0)
let IPHONE_XR_SMAX_LENGTH           = CGFloat(896.0)
let IPAD_LENGTH                     = CGFloat(1024.0)
let IPAD_PRO10_LENGTH               = CGFloat(1112.0)
let IPAD_PRO12_LENGTH               = CGFloat(1366.0)

let BASE_VIEW_SIZE_WIDTH            = CGFloat(320.0)
let BASE_VIEW_SIZE_HEIGHT           = IPHONE_5_LENGTH

let BASE_FONT_SIZE_XXXS             = CGFloat(7.0)
let BASE_FONT_SIZE_XXS              = CGFloat(10.0)
let BASE_FONT_SIZE_XS               = CGFloat(12.0)
let BASE_FONT_SIZE_S                = CGFloat(14.0)
let BASE_FONT_SIZE_M                = CGFloat(17.0)
let BASE_FONT_SIZE_L                = CGFloat(20.0)
let BASE_FONT_SIZE_XL               = CGFloat(22.0)
let BASE_FONT_SIZE_XXL              = CGFloat(24.0)
let BASE_FONT_SIZE_XXXL             = CGFloat(26.0)
let BASE_FONT_SIZE_XXXXL            = CGFloat(30.0)
let BASE_FONT_SIZE_XXXXXL           = CGFloat(34.0)
let BASE_FONT_SIZE_XXXXXXL          = CGFloat(50.0)

let kPhoneWithNotch                 = ["iPhone X", "iPhone XS", "iPhone XS Max", "iPhone XR", "iPhone 11", "iPhone 11 Pro", "iPhone 11 Pro Max"]
let kPadSafeAreaTopIs24             = ["iPad Pro (11-inch)", "iPad Pro (12.9-inch) (3rd generation)"]

let kSafeAreaTopPaddingDefault      = CGFloat(20)
let kSafeAreaTopPadding24           = CGFloat(24)
let kSafeAreaTopPadding44           = CGFloat(44)
let kSafeAreaBottomPaddingDefault   = CGFloat(34)

let kViewBaseCornerRadius           = CGFloat(8.0)
let kWebViewTopBaseCornerRadius     = CGFloat(10.0)
let kInnerViewBaseCornerRadius      = CGFloat(12.0)

let kImageMaxLength                 = CGFloat(8000.0)

let IS_PHONE                        = UIDevice().userInterfaceIdiom == .phone
let IS_PHONE_X                      = kPhoneWithNotch.contains(UIDevice.modelName)
let IS_PAD                          = UIDevice().userInterfaceIdiom == .pad
let IS_PAD_24                       = kPadSafeAreaTopIs24.contains(UIDevice.modelName)

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

func saveImage(image: UIImage, fileURL: URL) -> String {
    //pngで保存する場合
    let imageData = image.pngData()
    // jpgで保存する場合
    //let imageData = image.jpegData(compressionQuality: 1)
    //        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //        let fileURL = documentsURL.appendingPathComponent(fileName)
    do {
        try imageData!.write(to: fileURL)
    } catch {
        //エラー処理
        return ""
    }
    return fileURL.path
}

func getScaledWidth(base: CGFloat) -> CGFloat {
    return base * (ScreenSize.SCREEN_WIDTH / BASE_VIEW_SIZE_WIDTH)
}

func getScaledHeight(base: CGFloat) -> CGFloat {
    return base * (ScreenSize.SCREEN_HEIGHT / BASE_VIEW_SIZE_HEIGHT)
}

func getScaledHeightForPhoneWithNotch(base: CGFloat) -> CGFloat {
    return base * (ScreenSize.SCREEN_HEIGHT / IPHONE_X_LENGTH)
}

func imageWithMaxLength(sourceImage: UIImage, useWidth: Bool) -> UIImage {
    let oldLength = useWidth ? sourceImage.size.width : sourceImage.size.height
    let scaleFactor = kImageMaxLength / oldLength
    
    let newWidth = sourceImage.size.width * scaleFactor
    let newHeight = sourceImage.size.height * scaleFactor
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}
