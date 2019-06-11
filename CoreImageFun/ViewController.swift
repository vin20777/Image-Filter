//
//  ViewController.swift
//  CoreImageFun
//
//  Created by Vincent Vangoh on 2017/9/14.
//  Copyright © 2017年 VTStudio. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var QRCode: UIImageView!
    @IBOutlet weak var BarCode: UIImageView!
    
    var context: CIContext!
    var filter: CIFilter!
    var beginImage: CIImage!
    var currentImage: CIImage?
    
    var orientation: UIImage.Orientation = .up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        beginImage = CIImage(image: UIImage(named: "Flower")!)
        currentImage = beginImage
        
        // 2
        filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        //CIImage filter value must be provided as there is no default.
        filter.setValue(0.5, forKey: kCIInputIntensityKey)
        
        
        // 3
        context = CIContext(options:nil)
        
        let cgimg = context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent)
        let newImage = UIImage(cgImage: cgimg!)
        self.imageView.image = newImage
        
        // Bonus: QRCode & BarCode
        self.BarCode.image = UIImage.barCodeImageWithInfo(info: "Vincent van Gogh")
        self.QRCode.image = UIImage.qrCodeImage(info: "https://github.com/vin20777/Image-Filter", length: self.QRCode.frame.size.width, color1: CIColor.blue, color2: CIColor.white)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func amountSliderValueChanged(_ sender: UISlider) {
        let sliderValue = sender.value

        let outputImage = self.oldPhoto(img: beginImage, withAmount: sliderValue)
        
        let cgimg = context.createCGImage(outputImage, from: filter.outputImage!.extent)
        
        let newImage = UIImage(cgImage: cgimg!, scale: 1.0, orientation: orientation)
        self.imageView.image = newImage
        currentImage = outputImage
    }
    
    @IBAction func loadPhoto(_ sender: Any) {
        
        //Apple Privacy Terms Since iOS 10, also set description in Info.plist
        if PHPhotoLibrary.authorizationStatus() == .denied {
            print("Allow access please!")
            return
        }
        
        let pickerC = UIImagePickerController()
        pickerC.delegate = self
        self.present(pickerC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        self.dismiss(animated: true, completion: nil)
        
        let gotImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        orientation = gotImage.imageOrientation
        
        beginImage = CIImage(image:gotImage)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        self.amountSliderValueChanged(amountSlider)
    }

    @IBAction func savePhoto(_ sender: Any) {
        
        if PHPhotoLibrary.authorizationStatus() == .denied {
            print("Allow access please!")
            return
        }
        // 1
//        let imageToSave = filter.outputImage
        let imageToSave = currentImage
        
        // 2
        let softwareContext = CIContext(options:convertToOptionalCIContextOptionDictionary([convertFromCIContextOption(CIContextOption.useSoftwareRenderer): true]))
        
        // 3
        let cgimg = softwareContext.createCGImage(imageToSave!, from: (imageToSave?.extent)!)
        
        // 4
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetChangeRequest.creationRequestForAsset(from: UIImage.init(cgImage: cgimg!))
            
        }, completionHandler: { success, error in
            if success {
                print("Save Photo Success")
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func logAllFilters() {
        let properties = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        print("\n--------------------Start--------------------\n")
        print("All Properties:\(properties)\n\n total:\(properties.count)")
        print("\n------------------Seperator--------------------\n")
        
        var count: Int = 1
        for filterName in properties {
            
            let fltr = CIFilter(name:filterName)!
            print("\n------------------Next--------------------\n")
            print("\(count). \(filterName)\n\(fltr.attributes)")
            count += 1
        }
    }
    
    func oldPhoto(img: CIImage, withAmount intensity: Float) -> CIImage {
        
        // 1 sepia
        let sepia = CIFilter(name:"CISepiaTone")!
        sepia.setValue(img, forKey:kCIInputImageKey)
        sepia.setValue(intensity, forKey:"inputIntensity")
        
        // 2 random
        let random = CIFilter(name:"CIRandomGenerator")!
        
        
        // 3 lighten
        let lighten = CIFilter(name:"CIColorControls")!
        lighten.setValue(random.outputImage, forKey:kCIInputImageKey)
        lighten.setValue(1 - intensity, forKey:"inputBrightness")
        lighten.setValue(0, forKey:"inputSaturation")
        
        // 4
        let croppedImage = lighten.outputImage?.cropped(to: beginImage.extent)
        
        // 5 composite
        let composite = CIFilter(name:"CIHardLightBlendMode")!
        composite.setValue(sepia.outputImage, forKey:kCIInputImageKey)
        composite.setValue(croppedImage, forKey:kCIInputBackgroundImageKey)
        
        // 6 vignette
        let vignette = CIFilter(name:"CIVignette")!
        vignette.setValue(composite.outputImage, forKey:kCIInputImageKey)
        vignette.setValue(intensity * 2, forKey:"inputIntensity")
        vignette.setValue(intensity * 30, forKey:"inputRadius")
        
        // 7
        return vignette.outputImage!
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
	return input.rawValue
}
