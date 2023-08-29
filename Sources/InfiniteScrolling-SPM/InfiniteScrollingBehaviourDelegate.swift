//
//  InfiniteScrollingBehaviourDelegate.swift
//
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

public protocol InfiniteScrollingBehaviourDelegate: AnyObject {
    func configuredCell(forItemAt indexPath: IndexPath, originallyAt index: Int, and data: InfiniteScollingData, for behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell
    func didSelectItem(at indexPath: IndexPath, originallyAt index: Int, and data: InfiniteScollingData, for behaviour: InfiniteScrollingBehaviour)
    func didEndScrolling(in behaviour: InfiniteScrollingBehaviour)
    func verticalPaddingForHorizontal(behaviour: InfiniteScrollingBehaviour) -> CGFloat
    func horizontalPaggingForHorizontal(behaviour: InfiniteScrollingBehaviour) -> CGFloat
}

public extension InfiniteScrollingBehaviourDelegate {
    func didSelectItem(at indexPath: IndexPath, originallyAt index: Int, and data: InfiniteScollingData, for behaviour: InfiniteScrollingBehaviour) {}
    func didEndScrolling(in behaviour: InfiniteScrollingBehaviour) {}
    func verticalPaddingForHorizontal(behaviour: InfiniteScrollingBehaviour) -> CGFloat {
        return 0
    }
    
    func horizontalPaggingForHorizontal(behaviour: InfiniteScrollingBehaviour) -> CGFloat {
        return 0
    }
}
