//
//  DiaryViewController.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/08/28.
//

import UIKit
import CoreData

protocol CoreDataReceivable {
    func updateCollectionView()
}

final class DiaryViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        let listLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        
        return collectionView
    }()
    private var diaryDataSource: UICollectionViewDiffableDataSource<Section, DiaryEntity>?
    private var fetchedResultsController: NSFetchedResultsController<DiaryEntity>?
    private var diaryManager: DiaryManager?
    
    init(diaryManager: DiaryManager) {
        self.diaryManager = diaryManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ContainerManager.shared.deleteAll()
        
        initFetchedResultsController()
        setupObject()
        configureUI()
        setupConstraint()
        configureDataSource()
        loadData()
    }
    
    // 지금 하는 일 별로 없음
    func initFetchedResultsController() {
        let fetchRequest = DiaryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: ContainerManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension DiaryViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        // 의존성 문제
//        diaryDataSource?.apply(snapshot as NSDiffableDataSourceSnapshot<DiaryViewController.Section, DiaryEntity>, animatingDifferences: true)
        
        loadData()
        collectionView.reloadData()
    }
}

extension DiaryViewController: CoreDataReceivable {
    func updateCollectionView() {
        loadData()
        collectionView.reloadData()
    }
}

// MARK: Setup Object
extension DiaryViewController {
    private func setupObject() {
        setupView()
        setupNavigationBar()
        setupDiaryManager()
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let selectDateButton = UIBarButtonItem(
            image: UIImage(systemName: NameSpace.plusButtonImage),
            style: .plain,
            target: self,
            action: #selector(didTapSelectPlusButton)
        )
        navigationItem.title = NameSpace.diaryTitle
        navigationItem.rightBarButtonItem = selectDateButton
    }
    
    private func setupDiaryManager() {
        diaryManager?.delegate = self
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

// MARK: Load Data
extension DiaryViewController {
    private func loadData() {
        // diaryManager?.fetchDiaryList()
        applySnapshot()
    }
}

// MARK: CollectionView Delegate
extension DiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // guard let diary = diaryManager?.diaryList[indexPath.item] else { return }
        guard let diaryList = ContainerManager.shared.getDiary() else {
            // 작성된 일기가 없습니다.
            return
        }

        let diaryDetailViewController = DiaryDetailViewController(diary: diaryList[indexPath.item])
        diaryDetailViewController.delegate = self
        
        show(diaryDetailViewController, sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: CollectionView DataSource
extension DiaryViewController {
    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<DiaryCollectionViewListCell, DiaryEntity> { cell, _, diary in
            cell.setupLabels(diary)
        }

        diaryDataSource = UICollectionViewDiffableDataSource<Section, DiaryEntity>(collectionView: collectionView) { collectionView, indexPath, diary in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: diary)
        }
    }
    
    private func applySnapshot() {
        // load
        // 뷰컨이 list를 들고 있는 것이 좋음. didset -> applySnapshot()
//        guard let diaryDataSource,
//              let fetchedObjects = ContainerManager.shared.fetchDiaryEntity() else { return }
        guard let diaryDataSource,
              let fetchedObjects = fetchedResultsController?.fetchedObjects else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DiaryEntity>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedObjects)
        diaryDataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: CollectionView Layout
extension DiaryViewController {
    private func listLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath,
              let diary = fetchedResultsController?.object(at: indexPath),
              let id = diary.id
        else { return nil }
        
        let shareAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            // 공유
            self.setupActivityView(for: indexPath)
            completion(false)
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            ContainerManager.shared.delete(id: id)
            // self?.collectionView.reloadData()
            completion(false)
        }
        
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        shareAction.backgroundColor = .darkGray
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
    }
    
    func setupActivityView(for indexPath: IndexPath?) {
        guard let indexPath = indexPath,
              let diary = fetchedResultsController?.object(at: indexPath)
        else { return }
        
        let text = (diary.createdDate ?? "") + "\n" + (diary.title ?? "") + (diary.content ?? "")
        
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        // 2. 기본으로 제공되는 서비스 중 사용하지 않을 UIActivityType 제거(선택 사항)
//        activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.assignToContact]
        
        // 3. 컨트롤러를 닫은 후 실행할 완료 핸들러 지정
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                // 성공했을 때 작업
            }  else  {
                // 실패했을 때 작업
            }
        }
        // 4. 컨트롤러 나타내기(iPad에서는 팝 오버로, iPhone과 iPod에서는 모달로 나타냅니다.)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: CollectionView Section
extension DiaryViewController {
    private enum Section {
        case main
    }
}

// MARK: Alert Action
extension DiaryViewController: DiaryManagerDelegate {
    func showErrorAlert(error: Error) {
        let alertAction = UIAlertAction(title: NameSpace.check, style: .default)
        let alert = UIAlertController.customAlert(
            alertTile: NameSpace.error,
            alertMessage: error.localizedDescription,
            preferredStyle: .alert,
            alertActions: [alertAction]
        )
        
        navigationController?.present(alert, animated: true)
    }
}

// MARK: Button Action
extension DiaryViewController {
    @objc private func didTapSelectPlusButton() {
        guard let diary = diaryManager?.newDiary() else {
            return
        }
        
        let diaryDetailViewController = DiaryDetailViewController(diary: diary)
        diaryDetailViewController.delegate = self
        
        show(diaryDetailViewController, sender: self)
    }
}

// MARK: Name Space
extension DiaryViewController {
    private enum NameSpace {
        static let diaryTitle = "일기장"
        static let plusButtonImage = "plus"
        static let check = "확인"
        static let error = "Error"
    }
}
