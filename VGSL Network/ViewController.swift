//
//  ViewController.swift
//  VGSL Network
//
//  Created by Denis Lvovich on 10.12.2025.
//

import UIKit

class ViewController: UIViewController {

    private let jsonButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Load JSON", for: .normal)
        return b
    }()

    private let imageButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Load Image", for: .normal)
        return b
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tv.font = .systemFont(ofSize: 14)
        return tv
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        jsonButton.addTarget(self, action: #selector(loadJSON), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(loadImage), for: .touchUpInside)

        layout()
    }

    private func layout() {
        [jsonButton, imageButton, textView, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            jsonButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            jsonButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            imageButton.topAnchor.constraint(equalTo: jsonButton.topAnchor),
            imageButton.leadingAnchor.constraint(equalTo: jsonButton.trailingAnchor, constant: 20),

            textView.topAnchor.constraint(equalTo: jsonButton.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200),

            imageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func loadJSON() {
        textView.text = "Loading JSON…"
        imageView.image = nil

        Task { @MainActor in
            do {
                let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let text = String(data: data, encoding: .utf8) ?? "Invalid UTF-8"
                let lines = text.split(separator: "\n").prefix(20).joined(separator: "\n")
                textView.text = lines
            } catch {
                textView.text = "Error: \(error.localizedDescription)"
            }
        }
    }

    @objc private func loadImage() {
        textView.text = "Loading Image…"
        imageView.image = nil

        Task { @MainActor in
            do {
                let url = URL(string: "https://picsum.photos/400")!
                let (data, _) = try await URLSession.shared.data(from: url)
                imageView.image = UIImage(data: data)
                textView.text = "Image loaded"
            } catch {
                textView.text = "Error: \(error.localizedDescription)"
            }
        }
    }
}


