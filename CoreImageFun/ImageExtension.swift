//
//  ImageExtension.swift
//  CoreImageFun
//
//  Created by Vincent Vangoh on 2017/9/16.
//  Copyright © 2017年 VTStudio. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func barCodeImageWithInfo(info: String) -> UIImage? {
        
        let filter = CIFilter(name:"CICode128BarcodeGenerator")!
        filter.setDefaults()
        let data = info.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        let outputImage = filter.outputImage
        
        return UIImage(ciImage: outputImage!)
    }
    
    class func qrCodeImageWithInfo(info: String!, width: CGFloat) -> UIImage? {
    
        let strData = info.data(using: .utf8, allowLossyConversion: false)
        let qrFilter = CIFilter(name:"CIQRCodeGenerator")!
        qrFilter.setValue(strData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        let qrImage = qrFilter.outputImage
        
        let colorFilter = CIFilter(name:"CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrImage, forKey: kCIInputImageKey)
        colorFilter.setValue(CIColor.white(), forKey: "inputColor0")
        colorFilter.setValue(CIColor.black(), forKey: "inputColor1")
        let colorImage = colorFilter.outputImage
        
        let scale = CGFloat(0.3)
        let codeImage = UIImage(ciImage: colorImage!, scale: scale, orientation: .up)
        return codeImage
    }
}
