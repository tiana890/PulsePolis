//
//  CenterCellCollectionViewFlowLayout.swift
//  PulsePolis
//
//  Created by IMAC  on 09.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    let CELL_SIZE_WIDTH:CGFloat = 180.0
    let CELL_SIZE_HEIGHT:CGFloat = 240.0
    
    var selectedIndex: Int?
    
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var elementsInRect = [UICollectionViewLayoutAttributes]()
        
        for(var j = 0; j < collectionView?.numberOfSections(); j++){
            for(var i = 0; i < collectionView?.numberOfItemsInSection(j); i++){
                var x:CGFloat = 0.0
                var y:CGFloat = 35.0/*(collectionView?.frame.height)!/2 - CELL_SIZE_HEIGHT/2*/
                if(i != 0){
                     x = CGFloat(i) * (CELL_SIZE_WIDTH + 35.0)
                }
                var cellFrame = CGRectMake(x, y, CELL_SIZE_WIDTH, CELL_SIZE_HEIGHT)
                if(CGRectIntersectsRect(cellFrame, rect)){
                    let ip = NSIndexPath(forRow: i, inSection: j)
                    var attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: ip)
                    attr.frame = cellFrame
                    elementsInRect.append(attr)
                }
            }
        }
        
        return elementsInRect
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            
            if let attributesForVisibleCells = self.layoutAttributesForElementsInRect(cvBounds){
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.Cell {
                        continue
                    }
                    
                    if let candAttrs = candidateAttributes {
                        
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                        
                    }
                    else { // == First time in the loop == //
                        
                        candidateAttributes = attributes;
                        continue;
                    }
                    
                    
                }
                
                // Beautification step , I don't know why it works!
                if(proposedContentOffset.x == -(cv.contentInset.left)) {
                    return proposedContentOffset
                }
                
                return CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                
            }
            
            
        }
        
        // fallback
        
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
    
}
