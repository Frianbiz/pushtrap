import UIKit

class SettingsViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    let tagCellIdentifier = "TagTableViewCell"
    @IBOutlet weak var tagsTableView: UITableView!
    
    var tags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            self.tagsTableView.refreshControl = refreshControl
        } else {
            self.tagsTableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(loadTags), for: .valueChanged)
        self.loadTags()
    }
    
    @IBAction func addButtonHandle(_ sender: Any) {
        self.tags.append(Tag())
        self.tagsTableView.reloadData()
    }
    
    @IBAction func updateTagsButtonHandle(_ sender: Any) {
        _ = PushService.registerUser(tags: self.tags)
    }
    
    // Setup
    @objc private func loadTags() {
        _ = PushService.getCurrentTags().done { [weak self] tags in
            self?.tags = tags
            self?.tagsTableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag: Tag = self.tags[indexPath.row]
        
        if let cell = self.tagsTableView.dequeueReusableCell(withIdentifier: tagCellIdentifier) as? TagTableViewCell {
            cell.cellTag = tag
            cell.updatedTag = { [weak self] t in
                if let newTag: Tag = t {
                    self?.tags[indexPath.row] = newTag
                }
            }
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            self.tags.remove(at: indexPath.row)
            _ = PushService.registerUser(tags: self.tags)
            tableView.reloadData()
        }
    }
}
