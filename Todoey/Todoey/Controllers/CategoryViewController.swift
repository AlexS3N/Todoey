
import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: UIViewController {
    
    //MARK: - vars/lets
    var tableView = UITableView()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories = [Category]()
    let colorApp = UIColor(hexString: "FFC100")

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColor(color: colorApp!)
    }
  
    //MARK: - Flow functions
    private func setup() {
        title = "Todoey"
        setupBarButton(selector: #selector(addButtonPressed))
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = colorApp
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: - IBActions
    @objc func addButtonPressed() {
        let alert = UIAlertController(title: "New Todoey Category", message: "Do you want to create new category?", preferredStyle: .alert)
        var textField = UITextField()
        let yesAlertAction = UIAlertAction(title: "Yes", style: .default) { _ in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.color = UIColor.randomFlat().hexValue()
            self.categories.append(newCategory)
            self.saveCategories()
        }
        let noAlertAction = UIAlertAction(title: "No", style: .destructive)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Input name of category..."
            textField = alertTextField
            alert.setupYesAlertAction(alertAction: yesAlertAction, textField: textField)
        }
        alert.addAction(yesAlertAction)
        alert.addAction(noAlertAction)
        present(alert, animated: true)
    }
    
    //MARK: - CoreData methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Saving error is \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
           categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseID, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let categoryColor = UIColor(hexString: categories[indexPath.row].color ?? "FFFFFF")
        cell.configure(categories[indexPath.row], textColor: ContrastColorOf(categoryColor!, returnFlat: true))
        cell.backgroundColor = categoryColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = TodoListViewController()
        controller.selectedCategory = categories[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Deleting row by swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completionHandler in
            self?.context.delete((self?.categories[indexPath.row])!)
            self?.categories.remove(at: indexPath.row)
            UIView.animate(withDuration: 0.2, animations: {
                tableView.deleteRows(at: [indexPath], with: .none)
            }, completion: { _ in
                self?.saveCategories()
            })
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

