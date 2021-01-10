//  Created by dasdom on 01.01.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import UIKit

class BookDetailsViewController: UIViewController {
  
  private var saveButton: UIBarButtonItem?
  private var contentView: BookDetailsView {
    return view as! BookDetailsView
  }
  private var titleTextField: UITextField {
    return contentView.titleTextField
  }
  private var authorTextField: UITextField {
    return contentView.authorTextField
  }
  private let addCompletion: (Book) -> Void
  
  init(addCompletion: @escaping (Book) -> Void) {
    
    self.addCompletion = addCompletion
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    let contentView = BookDetailsView()
    
    contentView.addImageButton.addTarget(self, action: #selector(addImage(_:)), for: .touchUpInside)
    
    contentView.titleTextField.delegate = self
    contentView.authorTextField.delegate = self
    
    view = contentView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Add Book"
    
    saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
    navigationItem.rightBarButtonItem = saveButton
    saveButton?.isEnabled = false
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(dismiss(_:)))
    navigationItem.leftBarButtonItem = cancelButton
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    contentView.stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20).isActive = true
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}

// MARK: - Actions
extension BookDetailsViewController {
  @objc func save(_ sender: UIBarButtonItem) {
    guard let title = titleTextField.text, let author = authorTextField.text else {
      return
    }
    
    let book = Book(title: title, author: author)
    
    FileManager.default.createBooksDiretory(for: book)
    guard let image = contentView.coverImageView.image, let data = image.jpegData(compressionQuality: 0.8) else {
      return
    }
    do {
      try data.write(to: FileManager.default.bookCoverURL(for: book))
    } catch {
      print("error: \(error)")
    }
    
    addCompletion(book)
    dismiss(animated: true)
  }
  
  @objc func dismiss(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
  
  @objc func addImage(_ sender: UIButton) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
}

extension BookDetailsViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    guard let text = textField.text else {
      return true
    }
    let nsText = text as NSString
    let finalText = nsText.replacingCharacters(in: range, with: string)
    
    let title: String?
    let author: String?
    if textField == titleTextField {
      title = finalText
      author = authorTextField.text
    } else if textField == authorTextField {
      title = titleTextField.text
      author = finalText
    } else {
      title = nil
      author = nil
    }
    
    updateSaveButton(title: title, author: author)
    
    return true
  }
  
  func updateSaveButton(title: String?, author: String?) {
    if let title = title, !title.isEmpty,
       let author = author, !author.isEmpty,
       contentView.coverImageView.image != nil {
      saveButton?.isEnabled = true
    } else {
      saveButton?.isEnabled = false
    }
  }
}

extension BookDetailsViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    dismiss(animated: true)
        
    contentView.coverImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    
    updateSaveButton(title: titleTextField.text, author: authorTextField.text)
  }
}
