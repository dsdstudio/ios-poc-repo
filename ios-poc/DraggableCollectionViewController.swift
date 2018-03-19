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

class DraggableCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var colors:[UIColor] = {
        var list = [UIColor]()
        for v in 0...10 {
            list.append(UIColor.randomColor())
        }
        return list
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension DraggableCollectionViewController:UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColorSelectionCell
        cell.color = colors[indexPath.row]
        
        return cell
    }
}

extension DraggableCollectionViewController: UICollectionViewDataSource {
    
}

extension DraggableCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let d = colors[indexPath.row]
        // NSITemProvider안에 객체는 NSSecureCoding protocol로
        let p = NSItemProvider(item: d, typeIdentifier: cellDataIdentifier)
        let item = UIDragItem(itemProvider: p)
        item.localObject = d
        return [item]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        collectionView.reloadData()
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
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("s: \(sourceIndexPath) e: \(destinationIndexPath)")
        colors.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
}


extension DraggableCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let p = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        var destinationIndex = p.item
        for item in coordinator.items {
            guard let _ = item.dragItem.localObject as? UIColor else { continue }
            let insertionIndexPath = IndexPath(item: destinationIndex, section: 0)
            let sourceIndexPath = item.sourceIndexPath!
            
            collectionView.performBatchUpdates({
                colors.swapAt(sourceIndexPath.row, destinationIndex)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [insertionIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: insertionIndexPath)
            
            destinationIndex += 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [cellDataIdentifier])
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let proposal = UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        return proposal
    }
}
