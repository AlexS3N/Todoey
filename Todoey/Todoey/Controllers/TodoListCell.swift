import UIKit

class TodoListCell: UITableViewCell {

    var todoListTextLabel = UILabel()
    static let reuseID = "TodoListCell"    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TodoListCell {
    private func setup() {
        todoListTextLabel.translatesAutoresizingMaskIntoConstraints = false
        todoListTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
        todoListTextLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(todoListTextLabel)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            todoListTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            todoListTextLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2)
        ])
    }
    
    func configure(_ item: Item, textColor: UIColor) {
        todoListTextLabel.text = item.title
        todoListTextLabel.textColor =  textColor
        self.tintColor = textColor
    }
}
