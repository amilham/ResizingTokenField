//
//  ResizingTokenField.swift
//  ResizingTokenField
//
//  Created by Tadej Razborsek on 19/06/2019.
//  Copyright © 2019 Tadej Razborsek. All rights reserved.
//

import UIKit

class ResizingTokenField: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let viewModel: ResizingTokenFieldViewModel = ResizingTokenFieldViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = ResizingTokenFieldFlowLayout()
        layout.onContentHeightChanged = { [weak self] (oldHeight, newHeight) in
            self?.updateContentHeight(newHeight: newHeight, animated: false)
        }
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .lightGray
        
        return collectionView
    }()
    
    /// Height constraint of the collection view. This constraint's constant is updated as collection view resizes.
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpCollectionView()
        registerCells()
    }
    
    private func setUpCollectionView() {
        addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        heightConstraint = NSLayoutConstraint(item: collectionView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 100)
        heightConstraint!.priority = UILayoutPriority(rawValue: 999) // To avoid constraint issues when used in a UIStackView
        addConstraint(heightConstraint!)
    }
    
    private func registerCells() {
        collectionView.register(TextFieldCell.self, forCellWithReuseIdentifier: TextFieldCell.identifier)
        collectionView.register(UINib(nibName: DefaultTokenCell.nibName, bundle: Bundle(for: DefaultTokenCell.self)),
                                forCellWithReuseIdentifier: DefaultTokenCell.identifier)
    }
    
    // MARK: - Add/remove tokens
    
    func append(tokens: [ResizingTokenFieldToken], animated: Bool) {
        viewModel.tokens += tokens
        collectionView.reloadData()
    }
    
    // MARK: - Handling content height
    
    private func updateContentHeight(newHeight: CGFloat, animated: Bool) {
        heightConstraint?.constant = newHeight
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.identifierForCell(atIndexPath: indexPath),
                                                      for: indexPath)
        switch cell {
        case let tokenCell as DefaultTokenCell:
            populate(tokenCell: tokenCell, atIndexPath: indexPath)
        case let textFieldCell as TextFieldCell:
            populate(textFieldCell: textFieldCell, atIndexPath: indexPath)
        default:
            // Should never reach.
            break
        }
        
        return cell
    }
    
    private func populate(tokenCell: DefaultTokenCell, atIndexPath indexPath: IndexPath) {
        guard let token = viewModel.token(atIndexPath: indexPath) else { return }
        tokenCell.populate(withToken: token)
    }
    
    private func populate(textFieldCell: TextFieldCell, atIndexPath indexPath: IndexPath) {
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItemAt(indexPath: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate

}
