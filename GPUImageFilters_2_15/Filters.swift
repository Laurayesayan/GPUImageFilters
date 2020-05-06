//
//  Filters.swift
//  GPUImageFilters_2_15
//
//  Created by Лаура Есаян on 05.05.2020.
//  Copyright © 2020 LY. All rights reserved.
//

import Foundation
import GPUImage

class Filters {
    func saturationFilter(image: UIImage) -> UIImage {
        var imageCopy = image
        let filter = GPUImageSaturationFilter()
        filter.saturation = 1.5
        imageCopy = filter.image(byFilteringImage: image)
        
        return imageCopy
    }
    
    func anyCombination(image: UIImage) -> UIImage {
        var imageCopy = image
        let picture = GPUImagePicture(image: image)
        let filter1 = GPUImageContrastFilter()
        filter1.contrast = 2.0
        let filter2 = GPUImageSharpenFilter()
        let filter3 = GPUImageBoxBlurFilter()
        filter3.blurRadiusInPixels = 10
        
        picture?.addTarget(filter1)
        filter1.addTarget(filter2)
        filter2.addTarget(filter3)
        
        filter3.useNextFrameForImageCapture()
        picture?.processImage()
        
        imageCopy = filter3.imageFromCurrentFramebuffer(with: image.imageOrientation)
        
        return imageCopy
    }
    
    func pixellateEfffect(image: UIImage) -> UIImage {
        var imageCopy = image
        let filter = GPUImagePixellateFilter()
        filter.fractionalWidthOfAPixel = 0.07
        imageCopy = filter.image(byFilteringImage: image)
        
        return imageCopy
    }
    
    func visualEffectsCombination(image: UIImage) -> UIImage {
        var imageCopy = image
        let picture = GPUImagePicture(image: image)
        let filter1 = GPUImageToonFilter()
        let filter2 = GPUImageSketchFilter()
        
        picture?.addTarget(filter1)
        filter1.addTarget(filter2)
        filter2.useNextFrameForImageCapture()
        picture?.processImage()
        
        imageCopy = filter2.imageFromCurrentFramebuffer(with: image.imageOrientation)
        
        return imageCopy
    }
    
    func lutFilter(image: UIImage) -> UIImage {
        var imageCopy = image
        let picture = GPUImagePicture(image: image)
        let lut = GPUImagePicture(image: UIImage(named: "lookup_amatorka"))
        let filter = GPUImageLookupFilter()
        lut?.addTarget(filter, atTextureLocation: 1)
        picture?.addTarget(filter, atTextureLocation: 0)
        
        filter.useNextFrameForImageCapture()
        
        lut?.processImage()
        picture?.processImage()
        
        imageCopy = filter.imageFromCurrentFramebuffer(with: image.imageOrientation)
        
        return imageCopy
    }
}
