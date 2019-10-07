//
//  ViewController.swift
//  iOS13ContextMenu
//
//  Created by Anupam Chugh on 06/10/19.
//  Copyright © 2019 Anupam Chugh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var collectionView: UICollectionView!

    override func loadView() {
        super.loadView()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = .black
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
    }
}

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CollectionViewCell
        
        if indexPath.row % 2 == 0{
            cell.imageView.image = UIImage(named: "car")
        }
        else{
            cell.imageView.image = UIImage(named: "bike")
        }
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        
        
        let configuration = UIContextMenuConfiguration(identifier: "\(indexPath.row)" as NSCopying, previewProvider: {
            return SecondViewController(index: indexPath.row)
        }){ action in
            let viewMenu = UIAction(title: "View", image: UIImage(systemName: "eye.fill"), identifier: UIAction.Identifier(rawValue: "view")) {_ in
                print("button clicked..")
            }
            
            // Creating Rotate button
            let rotate = UIAction(title: "Rotate", image: UIImage(systemName: "arrow.counterclockwise"), identifier: nil, handler: {action in
                print("rotate clicked.")
            })

            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, handler: {action in
                
                print("delete clicked.")
            })
            // Creating Edit, which will open Submenu
            let editMenu = UIMenu(title: "Edit...", children: [rotate, delete])
            
            
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [viewMenu, editMenu])
        }
        
        return configuration
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        let id = configuration.identifier as! String
        
        animator.addCompletion {
            self.show(SecondViewController(index: Int(id)), sender: self)
        }
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
         let collectionViewWidth = collectionView.bounds.width/3.0
         let collectionViewHeight = collectionViewWidth

         return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
    }
}

