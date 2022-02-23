//
//  File.swift
//  InfinityCouruselCounterTest
//
//  Created by Vlad on 17.01.22.
//

import Foundation
import UIKit

struct Dash {
    let number:Int
    init(_ number:Int) {
        self.number = number
    }
}

class InfinityCouruselCounter:NSObject, UICollectionViewDataSource, UICollectionViewDelegate  {
    var width: CGFloat?
    
    fileprivate(set) public var myCollectionView: UICollectionView!
    
    fileprivate let dataSet: [Dash] = [Dash(1), Dash(2), Dash(3), Dash(4), Dash(5)]
    
    fileprivate(set) public var dataSetWithBoundary: [Dash] = []
    
    fileprivate let cellSize: CGFloat = 2;
    fileprivate let cellHeightSmall: CGFloat = 20;
    fileprivate let cellHeightBig: CGFloat = 40;
    
    fileprivate let padding: CGFloat = 10.2
    
    fileprivate var numberOfBoundaryElements = 0
    
    fileprivate var tmpOffsetDifference: Float = 0.0
    fileprivate var tmpContentOffset: Float = 0.0
    
    fileprivate(set) public var swipeAction:((_ side:Int)->Void)?
     
    fileprivate var collectionViewBoundsValue: CGFloat {
        get {
            return myCollectionView.bounds.size.width
        }
    }
    
//    @objc func doubleTapped() {
//        swipeCounter = 0
//        self.swipeAction!(swipeCounter)
//    }
    
    init(callbackCounter: @escaping (_ side:Int) -> Void, width: CGFloat) {
        self.width = width
        self.swipeAction = callbackCounter
        
    }

    private func configureBoundariesForInfiniteScroll() {
        dataSetWithBoundary = dataSet
        let absoluteNumberOfElementsOnScreen = ceil(collectionViewBoundsValue/cellSize)
        numberOfBoundaryElements = Int(absoluteNumberOfElementsOnScreen)
        addLeadingBoundaryElements()
        addTrailingBoundaryElements()
    }
    
    private func addLeadingBoundaryElements() {
        for index in stride(from: numberOfBoundaryElements, to: 0, by: -1) {
            let indexToAdd = (dataSet.count - 1) - ((numberOfBoundaryElements - index)%dataSet.count)
            let data = dataSet[indexToAdd]
            dataSetWithBoundary.insert(data, at: 0)
        }
    }
    
    private func addTrailingBoundaryElements() {
        for index in 0..<numberOfBoundaryElements {
            let data = dataSet[index%dataSet.count]
            dataSetWithBoundary.append(data)
        }
    }
    
    func configureCollectionView() -> UICollectionView {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.width ?? 300, height: 72), collectionViewLayout: layout)
                
        myCollectionView.showsVerticalScrollIndicator = false
        myCollectionView.showsHorizontalScrollIndicator = false
        
        myCollectionView.backgroundColor = UIColor.clear
    
        myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//        tap.numberOfTapsRequired = 2
//        myCollectionView.addGestureRecognizer(tap)
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        configureBoundariesForInfiniteScroll()
//        scrollToFirstElement()
        
        return myCollectionView
        
    }
    
//    private func scrollToFirstElement() {
//        scroll(toElementAtIndex: 0)
//    }
//
//    public func scroll(toElementAtIndex index: Int) {
//        let boundaryDataSetIndex = indexInBoundaryDataSet(forIndexInOriginalDataSet: index)
//        let indexPath = IndexPath(item: boundaryDataSetIndex, section: 0)
//        let scrollPosition: UICollectionView.ScrollPosition = .left
//        myCollectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
//    }
    
    public func indexInOriginalDataSet(forIndexInBoundaryDataSet index: Int) -> Int {
        let difference = index - numberOfBoundaryElements
        if difference < 0 {
            let originalIndex = dataSet.count + difference
            return abs(originalIndex % dataSet.count)
        } else if difference < dataSet.count {
            return difference
        } else {
            return abs((difference - dataSet.count) % dataSet.count)
        }
    }

    public func indexInBoundaryDataSet(forIndexInOriginalDataSet index: Int) -> Int {
        return index + numberOfBoundaryElements
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension InfinityCouruselCounter: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height: CGFloat = indexPath.row % 5 == 0 ? cellHeightBig : cellHeightSmall
       
        return CGSize(width: cellSize, height: height)
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let step:Float = 12.2

        let contentOffset = Float(scrollView.contentOffset.x)

        if(tmpContentOffset<=contentOffset){
            tmpOffsetDifference += contentOffset - tmpContentOffset;

            if(tmpOffsetDifference/step >= 1){
            
                tmpOffsetDifference = tmpOffsetDifference.truncatingRemainder(dividingBy:12.2)
                
                self.swipeAction!( 1)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }

        } else {
            tmpOffsetDifference += tmpContentOffset - contentOffset;
            
            if(tmpOffsetDifference/step >= 1){
                
                tmpOffsetDifference = tmpOffsetDifference.truncatingRemainder(dividingBy:12.2)
                
                self.swipeAction!( -1)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }

        }
        
        if(contentOffset<0) {
            scrollView.contentOffset = CGPoint(x: 2000, y: 0)
            tmpContentOffset = 2000
        } else if(contentOffset>=3500) {
            scrollView.contentOffset = CGPoint(x: 2000, y: 0)
            tmpContentOffset = 2000
        } else {
            tmpContentOffset = contentOffset;
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 36, right: 0)
    }
    
    
}

extension InfinityCouruselCounter {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSetWithBoundary.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)

        cell.layer.cornerRadius = 1
        cell.backgroundColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1)
        return cell
    }
}

extension InfinityCouruselCounter {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("User tapped on item \(indexPath.row)")
    }
}
