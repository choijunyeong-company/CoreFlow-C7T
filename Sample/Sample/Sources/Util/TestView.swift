import UIKit

final class TestView: UIView {
    private let size: CGSize
    override var intrinsicContentSize: CGSize { size }
    private let label = UILabel()
    init(string: String, size: CGSize) {
        self.size = size
        super.init(frame: .zero)
        label.text = string
        label.textColor = .black
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        self.layer.cornerRadius = 5
        self.backgroundColor = .lightGray
    }
    required init?(coder: NSCoder) { nil }
}
