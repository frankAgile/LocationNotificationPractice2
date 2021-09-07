//
//  MapDataTableViewCell.swift
//  coreLocation2
//
//  Created by Digital on 02/09/21.
//

import UIKit

class MapDataTableViewCell: UITableViewCell {
    var actionMapData: (() -> Void)? = nil
    
    @IBOutlet weak var noteTextField: UITextField!
    var noteTextFieldChange: Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func noteTextFieldEditingChange(_ sender: UITextField) {
        noteTextFieldChange = !(noteTextField.text?.isEmpty ?? true)
        actionMapData?()
    }
    
}
