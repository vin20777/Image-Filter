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
    
    class func qrCodeImage(info: String!, length: CGFloat, color1: CIColor, color2:CIColor) -> UIImage? {
        
        var qrImage: CIImage?
        
        let strData = info.data(using: .utf8, allowLossyConversion: false)
        let qrFilter = CIFilter(name:"CIQRCodeGenerator")!
        qrFilter.setValue(strData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        qrImage = qrFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10.0, y: 10.0))
        
        let colorFilter = CIFilter(name:"CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrImage, forKey: kCIInputImageKey)
        colorFilter.setValue(color1, forKey: "inputColor0")
        colorFilter.setValue(color2, forKey: "inputColor1")
        qrImage = colorFilter.outputImage
        
        return UIImage(ciImage: qrImage!)
    }
}
