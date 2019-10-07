//
//  CollectionViewCell.swift
//  iOS13ContextMenu
//
//  Created by Anupam Chugh on 06/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    //weak var textLabel: UILabel!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
        //self.textLabel = textLabel
        imageView.image = UIImage(named: "myImage")
        
        imageView.contentMode = .scaleToFill
        
        self.imageView = imageView
        
        self.contentView.backgroundColor = .lightGray
        //self.textLabel.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("Interface Builder is not supported!")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        fatalError("Interface Builder is not supported!")
    }
    
}
