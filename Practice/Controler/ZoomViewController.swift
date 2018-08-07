//
//  ZoomViewController.swift
//  Practice
//
//  Created by Виктор on 07.08.2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation
import UIKit

class ZoomViewController: UIViewController {
    
    var imageToZoom: UIImage?
    
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(image: imageToZoom)
        
        setUpScrollView()
        scrollView.delegate = self
        
        setZommScaleFor(scrollViewSize: scrollView.bounds.size)
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        recenterImage()
    }
    
    //MARK: - Set up scroll view
    
    private func setUpScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = UIColor.white
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setZommScaleFor(scrollViewSize: scrollView.bounds.size)
        
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        recenterImage()
    }
    
    private func setZommScaleFor(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minimumScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minimumScale
        scrollView.maximumZoomScale = 3.0
    }
    
    private func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        let horizontalSpace = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        let verticalSpace = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2.0 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
}

extension ZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.recenterImage()
    }
}
