//
//  MapConfigTableViewCell.swift
//  coreLocation2
//
//  Created by Digital on 02/09/21.
//

import UIKit



class MapConfigTableViewCell: UITableViewCell {
    var actionMapConfig: (() -> Void)? = nil
    
    @IBOutlet weak var radiusTextField: UITextField!
    var radiusTextFieldChange: Bool?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func textFieldEditingChange(_ sender: UITextField) {
        radiusTextFieldChange = !(radiusTextField.text?.isEmpty ?? true)
        actionMapConfig?()
    }
    
}
