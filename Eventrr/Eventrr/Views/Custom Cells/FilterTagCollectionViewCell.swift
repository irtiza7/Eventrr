//
//  FilterTagCollectionViewCell.swift
//  Eventrr
//
//  Created by Dev on 8/19/24.
//

import UIKit

class FilterTagCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: FilterTagCollectionViewCell.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    
    // MARK: - Life Cycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
    }
    
    // MARK: - Private Methods
    
    private func configureUI() {
        cardBackgroundView.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        
//        cardBackgroundView.layer.shadowColor = UIColor(named: K.ColorConstants.AccentSecondary.rawValue)?.cgColor
//        cardBackgroundView.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
//        cardBackgroundView.layer.shadowOpacity = 1.0
    }
    
}
