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

struct FilterFunctions {
    var demonstrationImages: [UIImage] = []
    var function: [(UIImage) -> UIImage] = []
}

class ViewController: UIViewController {
    private var video: AVAsset! = nil
    private lazy var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
    @IBOutlet weak var mediaSwitcher: UISwitch!
    private let filters = Filters()
    private var filterFunctions = FilterFunctions()
    private lazy var originalImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDemonstrationImages()
    }
    
    private func setDemonstrationImages() {
        let image = UIImage(named: "1")!
        
        filterFunctions.demonstrationImages.append(filters.saturationFilter(image: image))
        filterFunctions.function.append(filters.saturationFilter(image:))
        filterFunctions.demonstrationImages.append(filters.anyCombination(image: image))
        filterFunctions.function.append(filters.anyCombination(image:))
        filterFunctions.demonstrationImages.append(filters.pixellateEfffect(image: image))
        filterFunctions.function.append(filters.pixellateEfffect(image:))
        filterFunctions.demonstrationImages.append(filters.visualEffectsCombination(image: image))
        filterFunctions.function.append(filters.visualEffectsCombination(image:))
        filterFunctions.demonstrationImages.append(filters.lutFilter(image: image))
        filterFunctions.function.append(filters.lutFilter(image:))
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
        if mediaSwitcher.isOn {
            if video != nil {
                let playerItem = AVPlayerItem(asset: video)
                
                let player = AVPlayer(playerItem: playerItem)
                
                let controller = AVPlayerViewController()
                controller.player = player
                
                present(controller, animated: true) {
                    player.play()
                }
            }
        } else {
            let imageViewController = UIViewController()
            imageView.contentMode = .scaleAspectFit
            imageViewController.view.addSubview(imageView)
            
            self.present(imageViewController, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func picker(sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        pickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        present(pickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            video = AVAsset(url: url)
        }
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            originalImage = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterFunctions.demonstrationImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filtersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCell", for: indexPath) as! FiltersCollectionViewCell

        filtersCell.filterImageView.image = filterFunctions.demonstrationImages[indexPath.row]
        
        return filtersCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = imageView.image {
            imageView.image = originalImage
            imageView.image = filterFunctions.function[indexPath.row](imageView.image!)
        }
    }
}
