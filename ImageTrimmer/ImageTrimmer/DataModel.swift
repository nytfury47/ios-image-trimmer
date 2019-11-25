//
//  DataModel.swift
//  ImageTrimmer
//
//  Created by Gerardo Carlos Roderico Tan on 2019/11/22.
//  Copyright © 2019 nytfury47. All rights reserved.
//

import Foundation
import UIKit

struct ImageInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case imageName
        case hasTrimArea
        case cropArea
        case imageRect
        case imageOriginalWidth
        case imageOriginalHeight
        case scrollZoomScale
        case scrollContentOffset
        case scrollVerticalInset
        case scrollHorizontalInset
        case discardImage
    }
    
    var imageName: String
    var hasTrimArea: Bool
    var cropArea: CGRect
    var imageRect: CGRect
    var imageOriginalWidth: CGFloat
    var imageOriginalHeight: CGFloat
    var scrollZoomScale: CGFloat
    var scrollContentOffset: CGPoint
    var scrollVerticalInset: CGFloat
    var scrollHorizontalInset: CGFloat
    var discardImage: Bool
    
    init() {
        imageName = ""
        hasTrimArea = false
        cropArea = CGRect(x: 0, y: 0, width: 0, height: 0)
        imageRect =  CGRect(x: 0, y: 0, width: 0, height: 0)
        imageOriginalWidth = 0
        imageOriginalHeight = 0
        scrollZoomScale = 0
        scrollContentOffset = CGPoint(x: 0, y: 0)
        scrollVerticalInset = 0
        scrollHorizontalInset = 0
        discardImage = false
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        imageName = try values.decode(String.self, forKey: .imageName)
        hasTrimArea = try values.decode(Bool.self, forKey: .hasTrimArea)
        cropArea = try values.decode(CGRect.self, forKey: .cropArea)
        imageRect = try values.decode(CGRect.self, forKey: .imageRect)
        imageOriginalWidth = try values.decode(CGFloat.self, forKey: .imageOriginalWidth)
        scrollZoomScale = try values.decode(CGFloat.self, forKey: .scrollZoomScale)
        scrollContentOffset = try values.decode(CGPoint.self, forKey: .scrollContentOffset)
        scrollVerticalInset = try values.decode(CGFloat.self, forKey: .scrollVerticalInset)
        scrollHorizontalInset = try values.decode(CGFloat.self, forKey: .scrollHorizontalInset)
        imageOriginalHeight = try values.decode(CGFloat.self, forKey: .imageOriginalHeight)
        discardImage = try values.decode(Bool.self, forKey: .discardImage)
    }
}

class DataModel {
    // MARK: - Properties
    static let shared = DataModel()
    
    // UserDefaults keys
    private let kDefaults = UserDefaults.standard
    private let kTopImageID = "TopImageID"
    private let kImageInfoList = "ImageInfoList"
    
    private var topImageID: Int!
    private var imageInfoList: [ImageInfo] = [
        ImageInfo(),
        ImageInfo(),
        ImageInfo()
    ]
    
    // Initialization
    private init() {
        loadAll()
    }
    
    private func loadAll() {
        topImageID = kDefaults.integer(forKey: kTopImageID)
        
        // Encode data
        
        // Decode data
        if let data = kDefaults.data(forKey: kImageInfoList),
            let iList = try? JSONDecoder().decode([ImageInfo].self, from: data) {
            imageInfoList = iList
        }
    }
    
    func saveAll() {
        kDefaults.set(topImageID, forKey: kTopImageID)
        if let encoded = try? JSONEncoder().encode(imageInfoList) {
            kDefaults.set(encoded, forKey: kImageInfoList)
        }
    }
    
    func resetAll() {
        kDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        kDefaults.synchronize()
        imageInfoList.removeAll()
        loadAll()
    }
    
    func setTopImageID(inTopImageID: Int) {
        topImageID = inTopImageID
        kDefaults.set(topImageID, forKey: kTopImageID)
    }
    
    func getTopImageID() -> Int {
        return topImageID
    }
    
    func setImageInfoList(inImageInfoList: [ImageInfo]) {
        imageInfoList = inImageInfoList
        if let encoded = try? JSONEncoder().encode(imageInfoList) {
            kDefaults.set(encoded, forKey: kImageInfoList)
        }
    }
    
    func getImageInfoList() -> [ImageInfo] {
        return imageInfoList
    }
    
    func setImageName(at index: Int, inImageName: String) {
        imageInfoList[index].imageName = inImageName
    }
    
    func getImageNameList() -> [String] {
        var list = [String]()

        for info in imageInfoList {
            list.append(info.imageName)
        }
        
        return list
    }
    
    func getImagePath(at index: Int) -> String {
        let absPath = DataModel.getFileBaseURL().appendingPathComponent(imageInfoList[index].imageName)
        return absPath.path
    }
    
    func setImageHasTrimArea(at index: Int, inHasTrimArea: Bool) {
        imageInfoList[index].hasTrimArea = inHasTrimArea
    }
    
    func getImageHasTrimArea(at index: Int) -> Bool {
        return imageInfoList[index].hasTrimArea
    }
    
    func setImageCropArea(at index: Int, inCropArea: CGRect) {
        imageInfoList[index].cropArea = inCropArea
    }
    
    func getImageCropArea(at index: Int) -> CGRect {
        return imageInfoList[index].cropArea
    }
    
    func setImageRect(at index: Int, inImageRect: CGRect) {
        imageInfoList[index].imageRect = inImageRect
    }
    
    func getImageRect(at index: Int) -> CGRect {
        return imageInfoList[index].imageRect
    }
    
    func setImageOriginalWidth(at index: Int, inImageOriginalWidth: CGFloat) {
        imageInfoList[index].imageOriginalWidth = inImageOriginalWidth
    }
    
    func getImageOriginalWidth(at index: Int) -> CGFloat {
        return imageInfoList[index].imageOriginalWidth
    }
    
    func setImageOriginalHeight(at index: Int, inImageOriginalHeight: CGFloat) {
        imageInfoList[index].imageOriginalHeight = inImageOriginalHeight
    }
    
    func getImageOriginalHeight(at index: Int) -> CGFloat {
        return imageInfoList[index].imageOriginalHeight
    }
    
    func setImageScrollZoomScale(at index: Int, inScrollZoomScale: CGFloat) {
        imageInfoList[index].scrollZoomScale = inScrollZoomScale
    }
    
    func getImageScrollZoomScale(at index: Int) -> CGFloat {
        return imageInfoList[index].scrollZoomScale
    }
    
    func setImageScrollContentOffset(at index: Int, inContentOffset: CGPoint) {
        imageInfoList[index].scrollContentOffset = inContentOffset
    }
    
    func getImageScrollContentOffset(at index: Int) -> CGPoint {
        return imageInfoList[index].scrollContentOffset
    }
    
    func setImageScrollVerticalInset(at index: Int, inVerticalInset: CGFloat) {
        imageInfoList[index].scrollVerticalInset = inVerticalInset
    }
    
    func getImageScrollVerticalInset(at index: Int) -> CGFloat {
        return imageInfoList[index].scrollVerticalInset
    }
    
    func setImageScrollHorizontalInset(at index: Int, inHorizontalInset: CGFloat) {
        imageInfoList[index].scrollHorizontalInset = inHorizontalInset
    }
    
    func getImageScrollHorizontalInset(at index: Int) -> CGFloat {
        return imageInfoList[index].scrollHorizontalInset
    }
    
    func setDiscardImage(at index: Int, inDiscardImage: Bool) {
        imageInfoList[index].discardImage = inDiscardImage
    }
    
    func getDiscardImage(at index: Int) -> Bool {
        return imageInfoList[index].discardImage
    }
    
    static func createImageFileName() -> String {
        var number = 0
        var imageName = ""
        let baseURL = DataModel.getFileBaseURL()
        
        while (true) {
            imageName = "Img_\(number)"
            let url = baseURL.appendingPathComponent(imageName)

            if (!FileManager.default.fileExists(atPath: url.path)) {
                break
            }
            
            number += 1
        }
        
        return imageName
    }
    
    static func getFileBaseURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

