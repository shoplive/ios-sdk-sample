//
//  CoverPickerResultPopUp.swift
//  ShopLiveSwiftSample
//
//  Created by sangmin han on 11/18/24.
//

import Foundation
import UIKit


class CoverPickerResultPopUp : UIView {
    private var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .init(white: 0, alpha: 0.5)
        setLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func backgroundTapped() {
        self.alpha = 0
    }
    
    func setResultImage(image : UIImage?) {
        self.imageView.image = image
    }
}
extension CoverPickerResultPopUp {
    private func setLayout() {
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}
