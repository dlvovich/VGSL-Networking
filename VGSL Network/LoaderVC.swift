//
//  LoaderVC.swift
//  VGSL Network
//
//  Created by Denis Lvovich on 10.12.2025.
//

@preconcurrency import UIKit
import VGSL

class LoaderViewController: UIViewController {
  
  lazy var cache: Cache = {
    CacheFactory.makeLRUDiskCache(
      name: "common.cache-queue",
      ioQueue: OperationQueue.serialQueue(
        name: "CommonResourcesCache",
        qos: .userInitiated
      ),
      maxCapacity: 100 * 1024 * 1024, // 100MB
      fileManager: FileManager.default,
      reportError: { error in
        print("Cache error: \(error)")
      }
    )
  }()
  
  let performer = URLRequestPerformer(urlTransform: nil)
  lazy var networkRequester = {
    NetworkURLResourceRequester(performer: performer)
  }()
  
  lazy var cachedRequester = {
    CachedURLResourceRequester(
      cache: cache,
      cachemissRequester: networkRequester
    )
  }()
  
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
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    cachedRequester.getDataWithSource(from: url) { [weak self] result in
      switch result {
        case .success(let urlResult):
          let data = urlResult.data
          let source = urlResult.source
          print(source)
          let text = String(data: data, encoding: .utf8) ?? "Invalid UTF-8"
          let lines = text.split(separator: "\n").prefix(20).joined(separator: "\n")
          self?.textView.text = lines
        case .failure(let error):
          self?.textView.text = "Error: \(error.localizedDescription)"
      }
    }
  }
  
  var imageHolder: RemoteImageHolder?
  
  deinit {
    print("deinit")
  }
  
  @objc private func loadImage() {
    textView.text = "Loading Image…"
    imageView.image = nil
    
    let imageUrl = URL(string: "https://picsum.photos/400")!
    
    let queue = OperationQueue(
      name: "tech.divkit.svg-image-processing",
      qos: .userInitiated
    )
    
    imageHolder = RemoteImageHolder(
      url: imageUrl,
      placeholder: .color(.green),
      requester: cachedRequester,
      imageProcessingQueue: queue,
      imageLoadingOptimizationEnabled: true
    )
    
    imageHolder?.requestImageWithCompletion { [weak self] image in
      if let image {
        self?.textView.text = "Image loaded"
        self?.imageView.image = image
      } else {
        self?.textView.text = "Error loading image"
      }
    }
  }
}


