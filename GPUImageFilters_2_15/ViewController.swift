//
//  ViewController.swift
//  GPUImageFilters_2_15
//
//  Created by Лаура Есаян on 05.05.2020.
//  Copyright © 2020 LY. All rights reserved.
//

import UIKit
import GPUImage
import AVKit
import MobileCoreServices
import Bond

struct FilterFunctions {
    var demonstrationImages = MutableObservableArray<UIImage>()
    var imageFilters: [(UIImage) -> UIImage] = []
    var videoFilters: [(GPUImageMovie, GPUImageView) -> (GPUImageMovie, GPUImageView)] = []
}

class ViewController: UIViewController {
    @IBOutlet weak var demoImagesCollectionView: UICollectionView!
    @IBOutlet weak var mediaSwitcher: UISwitch!
    @IBOutlet weak var mediaView: UIView!
    private let filters = Filters()
    private var filterFunctions = FilterFunctions()
    private lazy var originalImage = UIImage()
    private var player: AVPlayer! = nil
    private var playerItem : AVPlayerItem! = nil
    private lazy var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDemonstrationImages()
        
        demoImagesCollectionView.reactive.selectedItemIndexPath
            .map{$0.row}
            .observeNext(with: { [weak self] row in
                if self!.mediaSwitcher.isOn && self!.playerItem != nil {
                    if self!.mediaView.layer.sublayers != nil {
                        self!.mediaView.layer.sublayers = []
                    }

                    self!.startVideoFilter(number: row)
                    
                } else if !self!.mediaSwitcher.isOn && self!.imageView.image != nil {
                    self!.startImageFilter(number: row)
                }
            }).dispose(in: bag)
        
        filterFunctions.demonstrationImages.bind(to: demoImagesCollectionView) { [weak self]
            (dataSource, indexPath, tableView) -> UICollectionViewCell in
            
            let cell = tableView.dequeueReusableCell(withReuseIdentifier: "FiltersCell", for: indexPath) as! FiltersCollectionViewCell
            cell.filterImageView.image = self!.filterFunctions.demonstrationImages[indexPath.row]
            
            return cell
        }.dispose(in: bag)
        
        mediaSwitcher.reactive.isOn.observeNext { [weak self] on in
            if !on {
                if self!.mediaView.layer.sublayers != nil {
                    self!.mediaView.layer.sublayers = []
                }
                self!.imageView = UIImageView()
                self!.playerItem = nil
                self!.player = nil
            } else {
                self!.imageView.removeFromSuperview()
            }
        }.dispose(in: bag)
    }
    
    private func setDemonstrationImages() {
        let image = UIImage(named: "1")!
        
        filterFunctions.demonstrationImages.append(filters.saturationFilter(image: image))
        filterFunctions.imageFilters.append(filters.saturationFilter(image:))
        filterFunctions.videoFilters.append(filters.saturationFilter(gpuMovie:filteredView:))
        
        filterFunctions.demonstrationImages.append(filters.anyCombination(image: image))
        filterFunctions.imageFilters.append(filters.anyCombination(image:))
        filterFunctions.videoFilters.append(filters.anyCombination(gpuMovie:filteredView:))
        
        filterFunctions.demonstrationImages.append(filters.pixellateEfffect(image: image))
        filterFunctions.imageFilters.append(filters.pixellateEfffect(image:))
        filterFunctions.videoFilters.append(filters.pixellateEfffect(gpuMovie:filteredView:))
        
        filterFunctions.demonstrationImages.append(filters.visualEffectsCombination(image: image))
        filterFunctions.imageFilters.append(filters.visualEffectsCombination(image:))
        filterFunctions.videoFilters.append(filters.visualEffectsCombination(gpuMovie:filteredView:))
        
        filterFunctions.demonstrationImages.append(filters.lutFilter(image: image))
        filterFunctions.imageFilters.append(filters.lutFilter(image:))
        filterFunctions.videoFilters.append(filters.lutFilter(gpuMovie:filteredView:))
    }
    
    @IBAction func addMedia(_ sender: Any) {
        let sourcePicker = UIAlertController()
        let chooseImage = UIAlertAction(title: "Choose image/video", style: .default) { [unowned self] _ in
            self.picker(sourceType: .photoLibrary)
        }
        
        sourcePicker.addAction(chooseImage)
        sourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sourcePicker, animated: true)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if player != nil {
            player.play()
        }
    }
    
    @IBAction func pauseVideo(_ sender: Any) {
        if player != nil {
            player.pause()
        }
    }
    
    func addVideoToMadiaView(url: URL) {
        if mediaView.layer.sublayers != nil {
            mediaView.layer.sublayers = []
        }
        
        player = AVPlayer()
        playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        startVideoFilter(number: 0)
    }
    
    func startVideoFilter(number row: Int) {
        var gpuMovie = GPUImageMovie(playerItem: playerItem)!
        gpuMovie.playAtActualSpeed = true
        
        var filteredView = GPUImageView()
        filteredView.frame = mediaView.frame
        
        (gpuMovie, filteredView) = filterFunctions.videoFilters[row](gpuMovie, filteredView)
        mediaView.layer.addSublayer(filteredView.layer)
        
        gpuMovie.startProcessing()
    }
    
    func startImageFilter(number row: Int) {
        imageView.image = filterFunctions.imageFilters[row](originalImage)
        mediaView.addSubview(imageView)
    }
    
    func addImageToMediaView(image: UIImage) {
        if playerItem != nil {
            mediaSwitcher.isOn = false
        }
        
        imageView.image = image
        originalImage = image
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = mediaView.frame
        
        startImageFilter(number: 0)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func picker(sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        if mediaSwitcher.isOn {
            pickerController.mediaTypes = [kUTTypeMovie as String]
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            addVideoToMadiaView(url: url)
        }
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addImageToMediaView(image: image)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
