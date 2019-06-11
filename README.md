# Image-Filter
## Swift 5 Core Graphic Practice

### Best Thanks to [raywenderlich.com](https://www.raywenderlich.com/)

Google every detail & knowledge through all the best developers in the world.
<p align="middle" >
<img width="300" alt="2017-09-18 1 22 04" src="https://user-images.githubusercontent.com/31400661/30529850-65e031b0-9c07-11e7-8e39-1278c8e35320.png">
</p>

### Extra QRCode & Barcode Generator (Used in this demo)

```Swift 3
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
```

## Credits

This demo project is owned and maintained by the <a href="mailto:vin20777@gmail.com">vin20777</a>.

Demo Images were originally created by [raywenderlich.com](https://www.raywenderlich.com/).
