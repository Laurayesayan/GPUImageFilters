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
    
    func saturationFilter(gpuMovie: GPUImageMovie, filteredView: GPUImageView) -> (GPUImageMovie, GPUImageView) {
        let filter = GPUImageSaturationFilter()
        filter.saturation = 1.5
        
        gpuMovie.addTarget(filter)
        filter.addTarget(filteredView)
        
        return (gpuMovie, filteredView)
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
    
    func anyCombination(gpuMovie: GPUImageMovie, filteredView: GPUImageView) -> (GPUImageMovie, GPUImageView) {
        let filter1 = GPUImageContrastFilter()
        filter1.contrast = 2.0
        gpuMovie.addTarget(filter1, atTextureLocation: 0)
        filter1.addTarget(filteredView)
        
        let filter2 = GPUImageSharpenFilter()
        gpuMovie.addTarget(filter2, atTextureLocation: 1)
        filter2.addTarget(filter1)
        
        let filter3 = GPUImageBoxBlurFilter()
        gpuMovie.addTarget(filter3, atTextureLocation: 2)
        filter3.addTarget(filter2)
        
        return (gpuMovie, filteredView)
    }
    
    func pixellateEfffect(image: UIImage) -> UIImage {
        var imageCopy = image
        let filter = GPUImagePixellateFilter()
        filter.fractionalWidthOfAPixel = 0.07
        imageCopy = filter.image(byFilteringImage: image)
        
        return imageCopy
    }
    
    func pixellateEfffect(gpuMovie: GPUImageMovie, filteredView: GPUImageView) -> (GPUImageMovie, GPUImageView) {
        let filter = GPUImagePixellateFilter()
        filter.fractionalWidthOfAPixel = 0.07
        
        gpuMovie.addTarget(filter)
        filter.addTarget(filteredView)
        
        return (gpuMovie, filteredView)
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
    
    func visualEffectsCombination(gpuMovie: GPUImageMovie, filteredView: GPUImageView) -> (GPUImageMovie, GPUImageView) {
        let filter1 = GPUImageToonFilter()
        gpuMovie.addTarget(filter1, atTextureLocation: 0)
        filter1.addTarget(filteredView)
        
        let filter2 = GPUImageSketchFilter()
        gpuMovie.addTarget(filter2, atTextureLocation: 1)
        filter2.addTarget(filter1)
        
        return (gpuMovie, filteredView)
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
    
    func lutFilter(gpuMovie: GPUImageMovie, filteredView: GPUImageView) -> (GPUImageMovie, GPUImageView) {
        let lut = GPUImagePicture(image: UIImage(named: "lookup_amatorka"))
        
        let filter1 = GPUImageLookupFilter()
        let filter2 = GPUImageFilter()
        
        lut?.addTarget(filter1)
        filter1.useNextFrameForImageCapture()
        lut?.processImage()
        filter1.addTarget(filter2)
        
        gpuMovie.addTarget(filter2)
//        lut?.processImage()
        
        filter2.addTarget(filteredView)
        
        return (gpuMovie, filteredView)
    }
}
