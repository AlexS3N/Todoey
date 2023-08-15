
import UIKit

class CategoryCell: UITableViewCell {
    
    let categoryLabel = UILabel()
    let chevronImageView = UIImageView()
    static let reuseID = "CategoryCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryCell {
    
    private func setup() {
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .body)
        categoryLabel.adjustsFontSizeToFitWidth = true
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        contentView.addSubview(chevronImageView)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: chevronImageView.trailingAnchor, multiplier: 2)
        ])
    }
    
    func configure(_ category: Category, textColor: UIColor) {
        categoryLabel.text = category.name
        categoryLabel.textColor = textColor
        chevronImageView.image = UIImage(systemName: "chevron.right")?.withTintColor(textColor, renderingMode: .alwaysOriginal)
    }
}


