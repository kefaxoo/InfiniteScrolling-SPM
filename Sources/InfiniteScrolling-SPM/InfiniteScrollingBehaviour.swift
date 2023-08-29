//
//  InfiniteScrollingBehaviour.swift
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

public class InfiniteScrollingBehaviour: NSObject {
    fileprivate var cellSize: CGFloat = 0
    fileprivate var padding: CGFloat = 0
    fileprivate var numberOfBoundaryElements = 0
    
    fileprivate(set) public weak var collectionView: UICollectionView!
    fileprivate(set) public weak var delegate: InfiniteScrollingBehaviourDelegate?
    fileprivate(set) public var data: [InfiniteScrollingData]
    fileprivate(set) public var dataWithBoundary = [InfiniteScrollingData]()
    
    fileprivate var collectionViewBoundsValue: CGFloat {
        get {
            switch collectionConfiguration.scrollingDirection {
                case .horizontal:
                    return collectionView.bounds.size.width
                case .vertical:
                    return collectionView.bounds.size.height
            }
        }
    }
    
    fileprivate var scrollViewContentSizeValue: CGFloat {
        get {
            switch collectionConfiguration.scrollingDirection {
                case .horizontal:
                    return collectionView.contentSize.width
                case .vertical:
                    return collectionView.contentSize.height
            }
        }
    }
    
    fileprivate(set) public var collectionConfiguration: CollectionViewConfiguration
    
    public init(with collectionView: UICollectionView, and data: [InfiniteScrollingData], delegate: InfiniteScrollingBehaviourDelegate, collectionConfiguration: CollectionViewConfiguration = .shared) {
        self.collectionView = collectionView
        self.data = data
        self.collectionConfiguration = collectionConfiguration
        self.delegate = delegate
        
        super.init()
        
        self.configureBoundariesForInfiniteScroll()
        self.configureCollectionView()
        self.scrollToFirstElement()
    }
    
    
    private func configureBoundariesForInfiniteScroll() {
        dataWithBoundary = data
        calculateCellWidth()
        
        let absoluteNumberOfElementsOnScreen = ceil(collectionViewBoundsValue / cellSize)
        numberOfBoundaryElements = Int(absoluteNumberOfElementsOnScreen)
        addLeadingBoundaryElements()
        addTrailingBoundaryElements()
    }
    
    private func calculateCellWidth() {
        switch collectionConfiguration.layoutType {
            case .fixedSize(let size, let padding):
                self.cellSize = size
                self.padding = padding
            case .numebrOfCellOnScreen(let count):
                cellSize = collectionViewBoundsValue / count.cgFloat
                padding = 0
            }
    }
    
    private func addLeadingBoundaryElements() {
        guard !self.data.isEmpty else { return }
        
        for index in stride(from: numberOfBoundaryElements, to: 0, by: -1) {
            let indexToAdd = (self.data.count - 1) - ((numberOfBoundaryElements - index) % self.data.count)
            let data = self.data[indexToAdd]
            dataWithBoundary.insert(data, at: 0)
        }
    }
    
    private func addTrailingBoundaryElements() {
        guard !self.data.isEmpty else { return }
        
        for index in 0..<numberOfBoundaryElements {
            let data = self.data[index % self.data.count]
            dataWithBoundary.append(data)
        }
    }
    
    private func configureCollectionView() {
        guard delegate != nil else { return }
        
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = collectionConfiguration.scrollingDirection
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func scrollToFirstElement() {
        scroll(toElementAtIndex: 0)
    }
    
    
    public func scroll(toElementAtIndex index: Int) {
        let boundaryDataSetIndex = indexInBoundarySet(forIndexInOriginalSet: index)
        let indexPath = IndexPath(item: boundaryDataSetIndex, section: 0)
        let scrollPosition: UICollectionView.ScrollPosition = collectionConfiguration.scrollingDirection == .horizontal ? .left : .top
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
    }
    
    public func indexInOriginalSet(forIndexInBoundarySet index: Int) -> Int {
        let difference = index - numberOfBoundaryElements
        if difference < 0 {
            let originalIndex = data.count + difference
            return abs(originalIndex % data.count)
        } else if difference < data.count {
            return difference
        } else {
            return abs((difference - data.count) % data.count)
        }
    }
    
    public func indexInBoundarySet(forIndexInOriginalSet index: Int) -> Int {
        return index + numberOfBoundaryElements
    }
    
    
    public func reload(with data: [InfiniteScrollingData]) {
        self.data = data
        configureBoundariesForInfiniteScroll()
        collectionView.reloadData()
        scrollToFirstElement()
    }
    
    public func updateConfiguration(configuration: CollectionViewConfiguration) {
        collectionConfiguration = configuration
        configureBoundariesForInfiniteScroll()
        configureCollectionView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.collectionView.reloadData()
            self.scrollToFirstElement()
        }
    }
}

extension InfiniteScrollingBehaviour: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch (collectionConfiguration.scrollingDirection, delegate) {
        case (.horizontal, .some(let delegate)):
            let inset = delegate.verticalPaddingForHorizontal(behaviour: self)
            return UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        case (.vertical, .some(let delegate)):
            let inset = delegate.horizontalPaggingForHorizontal(behaviour: self)
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        case (_, _):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch (collectionConfiguration.scrollingDirection, delegate) {
        case (.horizontal, .some(let delegate)):
            let height = collectionView.bounds.size.height - 2 * delegate.verticalPaddingForHorizontal(behaviour: self)
            return CGSize(width: cellSize, height: height)
        case (.vertical, .some(let delegate)):
            let width = collectionView.bounds.size.width - 2 * delegate.horizontalPaggingForHorizontal(behaviour: self)
            return CGSize(width: width, height: cellSize)
        case (.horizontal, _):
            return CGSize(width: cellSize, height: collectionView.bounds.size.height)
        case (.vertical, _):
            return CGSize(width: collectionView.bounds.size.width, height: cellSize)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let originalIndex = indexInOriginalSet(forIndexInBoundarySet: indexPath.item)
        delegate?.didSelectItem(at: indexPath, originallyAt: originalIndex, and: dataWithBoundary[indexPath.item], for: self)
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let boundarySize = numberOfBoundaryElements.cgFloat * cellSize + (numberOfBoundaryElements.cgFloat * padding)
        let contentOffsetValue = collectionConfiguration.scrollingDirection == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let updatedOffsetPoint: CGPoint
        if contentOffsetValue >= (scrollViewContentSizeValue - boundarySize) {
            let offset = boundarySize - padding
            updatedOffsetPoint = collectionConfiguration.scrollingDirection == .horizontal ?
                CGPoint(x: offset, y: 0) : CGPoint(x: 0, y: offset)
        } else if contentOffsetValue <= 0 {
            let boundaryLessSize = data.count.cgFloat * cellSize + (data.count.cgFloat * padding)
            updatedOffsetPoint = collectionConfiguration.scrollingDirection == .horizontal ?
                CGPoint(x: boundaryLessSize, y: 0) : CGPoint(x: 0, y: boundaryLessSize)
        } else {
            return
        }
        
        scrollView.contentOffset = updatedOffsetPoint
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didEndScrolling(in: self)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        delegate?.didEndScrolling(in: self)
    }
    
}

extension InfiniteScrollingBehaviour: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataWithBoundary.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate else { return UICollectionViewCell() }
        
        let originalIndex = indexInOriginalSet(forIndexInBoundarySet: indexPath.item)
        return delegate.configuredCell(forItemAt: indexPath, originallyAt: originalIndex, and: dataWithBoundary[indexPath.item], for: self)
    }
}
