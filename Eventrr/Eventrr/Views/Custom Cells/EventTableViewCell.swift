//
//  EventCellTableViewCell.swift
//  Eventrr
//
//  Created by Dev on 8/19/24.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: EventTableViewCell.self)

    // MARK: - IBOutlets
    
    @IBOutlet weak var cardBackground: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Life Cycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCardEffectToCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Private Methods
    
    private func applyCardEffectToCell() {
        cardBackground.layer.borderColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)?.cgColor
        
        cardBackground.alpha = 0.9
        
        cardBackground.layer.shadowColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)?.cgColor
        cardBackground.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardBackground.layer.shadowOpacity = 1.0
        cardBackground.layer.masksToBounds = false
        cardBackground.layer.cornerRadius = K.UI.defaultTertiaryCornerRadius
    }
}
