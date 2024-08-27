//
//  NoEventTableViewCell.swift
//  Eventrr
//
//  Created by Irtiza on 8/27/24.
//

import UIKit

class NoEventTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: NoEventTableViewCell.self)

    @IBOutlet weak var backgroundRoundedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCardEffectToCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func applyCardEffectToCell() {
        backgroundRoundedView.layer.borderColor = UIColor(named: K.ColorConstants.AccentTertiary.rawValue)?.cgColor
        
        backgroundRoundedView.alpha = 0.8
        
        backgroundRoundedView.layer.shadowColor = UIColor(named: K.ColorConstants.AccentTertiary.rawValue)?.cgColor
        backgroundRoundedView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        backgroundRoundedView.layer.shadowOpacity = 0.8
        backgroundRoundedView.layer.masksToBounds = false
        backgroundRoundedView.layer.cornerRadius = K.UI.defaultTertiaryCornerRadius
    }
    
}
