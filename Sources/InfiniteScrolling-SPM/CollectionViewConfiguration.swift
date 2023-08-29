//
//  CollectionViewConfiguration.swift
//  
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

public struct CollectionViewConfiguration {
    public let scrollingDirection: UICollectionView.ScrollDirection
    public var layoutType: LayoutType
    public static let shared = CollectionViewConfiguration(scrollingDirection: .horizontal, layoutType: .numebrOfCellOnScreen(5))
    
    public init(scrollingDirection: UICollectionView.ScrollDirection, layoutType: LayoutType) {
        self.scrollingDirection = scrollingDirection
        self.layoutType = layoutType
    }
}
