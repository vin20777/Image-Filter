//
//  ViewController.swift
//  CoreImageFun
//
//  Created by VTStudio on 2017/9/14.
//  Copyright © 2017年 VTStudio. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var amountSlider: UISlider!
    
    var context: CIContext!
    var filter: CIFilter!
    var beginImage: CIImage!
    
    var orientation: UIImageOrientation = .up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        beginImage = CIImage(image: UIImage(named: "Flower")!)
        
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
        
        self.logAllFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func amountSliderValueChanged(_ sender: UISlider) {
        let sliderValue = sender.value
        
//        filter.setValue(sliderValue, forKey: kCIInputIntensityKey)
//        let outputImage = filter.outputImage

        let outputImage = self.oldPhoto(img: beginImage, withAmount: sliderValue)
        
        let cgimg = context.createCGImage(outputImage, from: filter.outputImage!.extent)
        
        let newImage = UIImage(cgImage: cgimg!, scale: 1.0, orientation: orientation)
        self.imageView.image = newImage
    }
    
    @IBAction func loadPhoto(_ sender: Any) {
        
        let pickerC = UIImagePickerController()
        pickerC.delegate = self
        self.present(pickerC, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        let gotImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        orientation = gotImage.imageOrientation
        
        beginImage = CIImage(image:gotImage)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        self.amountSliderValueChanged(amountSlider)
    }

    @IBAction func savePhoto(_ sender: Any) {
        // 1
        let imageToSave = filter.outputImage
        
        // 2
        let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
        
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
        let croppedImage = lighten.outputImage?.cropping(to: beginImage.extent)
        
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

