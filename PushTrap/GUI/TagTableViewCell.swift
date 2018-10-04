import UIKit

class TagTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var cellTag: Tag? {
        didSet {
            self.keyInput.text = cellTag?.key
            self.valueInput.text = cellTag?.value
        }
    }
    
    var updatedTag: ((Tag?) -> Void)?
    
    @IBOutlet weak var keyInput: UITextField!
    @IBOutlet weak var valueInput: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.keyInput.delegate = self
        self.valueInput.delegate = self
    }
    
    @IBAction func keyEndEdit(_ sender: Any) {
        self.cellTag?.key = self.keyInput.text ?? ""
        if let callback = self.updatedTag {
            callback(self.cellTag)
        }
    }
    @IBAction func valueEndEdit(_ sender: Any) {
        self.cellTag?.value = self.valueInput.text  ?? ""
        if let callback = self.updatedTag {
            callback(self.cellTag)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return false
    }
}
