//
//  DiaryViewController.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/08/28.
//

import UIKit

final class DiaryViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var diaryDataSource: UICollectionViewDiffableDataSource<Section, Diary>!
    private var diaryManager: DiaryManager
    
    init(diaryManager: DiaryManager) {
        self.diaryManager = diaryManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObject()
        configureUI()
        setupConstraint()
        configureDataSource()
        loadData()
    }
}

extension DiaryViewController: DiaryManagerDelegate {
    func showErrorAlert(error: Error) {}
}

// MARK: Road Data
extension DiaryViewController {
    private func loadData() {
        diaryManager.fetchDiaryList()
        applySnapshot()
    }
}

// MARK: Button Action
extension DiaryViewController {
    @objc private func didTapSelectPlusButton() {
        let diaryDetailViewController = DiaryDetailViewController()
        show(diaryDetailViewController, sender: self)
    }
}

// MARK: Setup Object
extension DiaryViewController {
    private func setupObject() {
        setupView()
        setupCollectionView()
        setupNavigationBar()
        setupDiaryManager()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
    }
    
    private func setupNavigationBar() {
        let selectDateButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapSelectPlusButton))
        navigationItem.title = "일기장"
        navigationItem.rightBarButtonItem = selectDateButton
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    private func setupDiaryManager() {
        diaryManager.delegate = self
    }
}

// MARK: Configure UI
extension DiaryViewController {
    private func configureUI() {
        configureView()
    }
    
    private func configureView() {
        view.addSubview(collectionView)
    }
}

// MARK: Setup Constraints
extension DiaryViewController {
    private func setupConstraint() {
        setupCollectionViewConstraint()
    }
    
    private func setupCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}

// MARK: CollectionView Delegate
extension DiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let diaryDetailViewController = DiaryDetailViewController()
        show(diaryDetailViewController, sender: self)
    }
}

// MARK: CollectionView DataSource
extension DiaryViewController {
    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<DiaryCollectionViewListCell, Diary> { cell, _, diary in
            cell.setupLabels(diary)
        }

        diaryDataSource = UICollectionViewDiffableDataSource<Section, Diary>(collectionView: collectionView) { collectionView, indexPath, diary in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: diary)
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Diary>()
        snapshot.appendSections([.main])
        snapshot.appendItems(diaryManager.diaryList)
        
        diaryDataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: CollectionView Layout
extension DiaryViewController {
    private func listLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: CollectionView Section
extension DiaryViewController {
    private enum Section {
        case main
    }
}
