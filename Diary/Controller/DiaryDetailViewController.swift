//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/08/30.
//

import UIKit
import CoreData

final class DiaryDetailViewController: UIViewController {
    var delegate: CoreDataReceivable?
    private var diary: Diary?
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    init(diary: Diary?) {
        self.diary = diary
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupConstraint()
        setupComponents()
        diaryTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addBackgroundObserver()
        if #unavailable(iOS 15.0) {
            addKeyboardObserver()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeBackgroundObserver()
        if #unavailable(iOS 15.0) {
            removeKeyboardObserver()
        }
    }
}

// private 때는 대신에 protocol 쓰는거임!!(명분!!) CoreDataSavable
extension DiaryDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text.isEmpty == false else {
            // 새로운 메모
            return
        }
        
        let lines = textView.text.components(separatedBy: "\n")
        guard var diary,
              let firstLine = lines.first else { return }
        
        diary.title = firstLine
        let bodyLines = lines.dropFirst()
        let body = bodyLines.joined(separator: "\n")
        diary.body = body
        
        if ContainerManager.shared.isExist(diary) {
            ContainerManager.shared.update(diary)
        } else {
            ContainerManager.shared.insert(diary)
        }
        // delegate?.updateCollectionView()
    }
}

// MARK: Setup Components
extension DiaryDetailViewController {
    private func setupComponents() {
        setupView()
        setupTextView()
        setupNavigationBar()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupTextView() {
        guard let diary else {
            return
        }
        
        if diary.title.isEmpty && diary.body.isEmpty {
            diaryTextView.text = nil
        } else {
            diaryTextView.text = String(format: NameSpace.diaryText,
                                        arguments: [diary.title, diary.body])
        }
        diaryTextView.keyboardDismissMode = .onDrag
    }
    
    private func setupNavigationBar() {
        navigationItem.title = diary?.createdDate
    }
}

// MARK: Configure UI
extension DiaryDetailViewController {
    private func configureUI() {
        configureView()
    }
    
    private func configureView() {
        view.addSubview(diaryTextView)
    }
}

// MARK: Setup Constraint
extension DiaryDetailViewController {
    private func setupConstraint() {
        setupDiaryTextViewConstraint()
    }
    
    private func setupDiaryTextViewConstraint() {
        if #unavailable(iOS 15.0) {
            NSLayoutConstraint.activate([
                diaryTextView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
                diaryTextView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor),
                diaryTextView.leftAnchor.constraint(equalTo: view.readableContentGuide.leftAnchor),
                diaryTextView.rightAnchor.constraint(equalTo: view.readableContentGuide.rightAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                diaryTextView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
                diaryTextView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
                diaryTextView.leftAnchor.constraint(equalTo: view.readableContentGuide.leftAnchor),
                diaryTextView.rightAnchor.constraint(equalTo: view.readableContentGuide.rightAnchor)
            ])
        }
    }
}

// MARK: Notification
extension DiaryDetailViewController {
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func addBackgroundObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveCoreData),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeBackgroundObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        diaryTextView.contentInset.bottom = keyboardFrame.size.height
    }
    
    @objc private func keyboardWillHide() {
        // 여기서 데이터 저장 처리해줘도됨!
        diaryTextView.contentInset = UIEdgeInsets.zero
    }
    
    @objc private func saveCoreData() {
        print("실행중")
        let lines = diaryTextView.text.components(separatedBy: "\n")
        guard var diary,
              let firstLine = lines.first else { return }
        
        diary.title = firstLine
        let bodyLines = lines.dropFirst()
        let body = bodyLines.joined(separator: "\n")
        diary.body = body
        
        if ContainerManager.shared.isExist(diary) {
            ContainerManager.shared.update(diary)
        } else {
            ContainerManager.shared.insert(diary)
        }
    }
}

// MARK: Name Space
extension DiaryDetailViewController {
    private enum NameSpace {
        static let diaryText = "%@\n%@"
    }
}
