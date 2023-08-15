import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: UIViewController {
    
    //MARK: - vars/lets
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
            selectedCategoryColor = UIColor(hexString: selectedCategory?.color ?? "FFFFFF")
        }
    }
    var selectedCategoryColor: UIColor?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tableView = UITableView()
    var searchBar = UISearchBar()
    
    
    //MARK: - Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    //MARK: - Flow functions
    private func setup() {
        setupSearchBar()
        setupBarButton(selector: #selector(addButtonPressed))
        setupTableView()
        title = selectedCategory?.name
        setupColor(color: selectedCategoryColor!)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.reuseID)
        tableView.separatorStyle = .none
        tableView.backgroundColor = selectedCategoryColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = selectedCategoryColor
        searchBar.searchTextField.backgroundColor = .lightText
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    //MARK: - IBActions
    @objc func addButtonPressed() {
        let alert = UIAlertController(title: "New Todoey Item", message: "Do you want to add new item?", preferredStyle: .alert)
        
        var textField = UITextField()
        let yesAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let newItem = Item(context: self.context)
            newItem.title = textField.text
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        let noAlertAction = UIAlertAction(title: "No", style: .destructive)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
            alert.setupYesAlertAction(alertAction: yesAlertAction, textField: textField)
        }

        alert.addAction(yesAlertAction)
        alert.addAction(noAlertAction)
        present(alert, animated: true)
    }
    
   
    
    //MARK: - coreData methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let selectedCategory = selectedCategory, let name = selectedCategory.name else { return }
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error of loading data is \(error)")
        }
        tableView.reloadData()
    }
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myCell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.reuseID, for: indexPath) as? TodoListCell else {
            return UITableViewCell()
        }
        myCell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        if let categoryColor = selectedCategoryColor,
           let color = categoryColor.darken(byPercentage: CGFloat(CGFloat(indexPath.row)/CGFloat(itemArray.count))){
            myCell.backgroundColor = color
            myCell.configure(itemArray[indexPath.row], textColor: ContrastColorOf(color, returnFlat: true))
        }
        return myCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Deleting row by swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completionHandler in
            self?.context.delete((self?.itemArray[indexPath.row])!)
            self?.itemArray.remove(at: indexPath.row)
            UIView.animate(withDuration: 0.2, animations: {
                self?.tableView.deleteRows(at: [indexPath], with: .none)
              }, completion: { _ in
                self?.saveItems()
              })
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] '\(text)'")
        request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
