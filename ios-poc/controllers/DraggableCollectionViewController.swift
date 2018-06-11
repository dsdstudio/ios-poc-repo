//
//  DraggableCollectionViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 3. 19..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"
private let cellDataIdentifier = "data"

struct TestData {
    var color:UIColor
    var index:Int
}
class DraggableCollectionViewController: UICollectionViewController {
    var list:[TestData] = (0...10).map{ TestData(color: UIColor.randomColor(), index: $0)}
    override func viewDidLoad() {
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        title = "CollectionView Drag N Drop Sample"
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColorSelectionCell
        let data = list[indexPath.row]
        cell.color = data.color
        cell.text = "\(data.index)"
        return cell
    }
}

extension DraggableCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let d = list[indexPath.row]
        let p = NSItemProvider(item: "" as NSString, typeIdentifier: cellDataIdentifier)
        let item = UIDragItem(itemProvider: p)
        item.localObject = d
        return [item]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let preview = UIDragPreviewParameters()
        if let cell = collectionView.cellForItem(at: indexPath) {
            let cellCenterPoint = cell.contentView.center
            let path = UIBezierPath(
                arcCenter: cellCenterPoint,
                radius: 24.0,
                startAngle: 0.0,
                endAngle: 360.0,
                clockwise: true
            )
            preview.visiblePath = path
        }
        return preview
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}


extension DraggableCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
            let dragItem = coordinator.items.first?.dragItem,
            let sourceIndexPath = coordinator.items.first?.sourceIndexPath,
            let data = dragItem.localObject as? TestData
        else { return }
        
        list.remove(at: sourceIndexPath.row)
        list.insert(data, at: destinationIndexPath.row)
        
        collectionView.performBatchUpdates({
            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        })
        
        let minIndex = min(sourceIndexPath.row, destinationIndexPath.row)
        let maxIndex = max(sourceIndexPath.row, destinationIndexPath.row)
        collectionView.reloadItems(at: (minIndex...maxIndex).map{IndexPath(row: $0, section: 0)})
        coordinator.drop(dragItem, toItemAt: destinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [cellDataIdentifier])
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}
