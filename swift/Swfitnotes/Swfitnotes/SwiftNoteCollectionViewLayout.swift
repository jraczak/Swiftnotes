//
//  SwiftNoteCollectionViewLayout.swift
//  Swfitnotes
//
//  Created by John Lago on 1/21/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import UIKit

class SwiftNoteCollectionViewLayout: UICollectionViewLayout {
    
    //MARK: - Properties
    var delegate: SwiftNoteCollectionViewLayoutDelegate!
    var cellPadding: CGFloat = 8.0
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - insets.right - insets.left
    }
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: contentWidth, height: contentHeight)
        }
    }
    
    //MARK: - UICollectionViewLayout
    override func prepare() {
        if cache.isEmpty {
            var xOffset:CGFloat = 0.0
            var yOffset:CGFloat = 0.0
            for item in 0..<collectionView!.numberOfItems(inSection: 0){
                let indexPath = IndexPath(item: item, section: 0)
                //TODO: width should not be a constant 
                let width: CGFloat = 270
                let bodyHeight = delegate.collectionView(collectionView: collectionView!, heightForBodyAtIndexPath: indexPath, withWidth: width)
                let titleHeight = delegate.collectionView(collectionView: collectionView!, heightForTitleAtIndexPath: indexPath, withWidth: width)
                var height: CGFloat = 0.0
                height = bodyHeight + cellPadding * 4 + titleHeight
                let frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: height)
                let insetframe = frame.insetBy(dx: cellPadding*2, dy: cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetframe
                cache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset = yOffset + height
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache
    }
    
    override func invalidateLayout() {
        cache.removeAll()
        super.invalidateLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

//MARK: - SwiftNoteCollectionViewLayoutDelegate Protocol
protocol SwiftNoteCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForBodyAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat
    
    func collectionView(collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat
}
