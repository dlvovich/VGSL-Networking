import UIKit

class RootViewController: UIViewController {

    private let button: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Show Loader Screen", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        button.addTarget(self, action: #selector(openLoader), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openLoader() {
        let vc = LoaderViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

