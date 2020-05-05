//
//  ViewController.swift
//  GPUImageFilters_2_15
//
//  Created by Лаура Есаян on 05.05.2020.
//  Copyright © 2020 LY. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation
import AVKit
import MobileCoreServices

class ViewController: UIViewController {
    private var video: AVAsset! = nil
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addMedia(_ sender: Any) {
        let sourcePicker = UIAlertController()
        let chooseImage = UIAlertAction(title: "Choose Image/Video", style: .default) { [unowned self] _ in
            self.picker(sourceType: .photoLibrary)
        }
        
        sourcePicker.addAction(chooseImage)
        sourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(sourcePicker, animated: true)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if video != nil {
            let playerItem = AVPlayerItem(asset: video)
            
            let player = AVPlayer(playerItem: playerItem)
            
            let controller = AVPlayerViewController()
            controller.player = player
            
            present(controller, animated: true) {
                player.play()
            }
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
        } else if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = editedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
