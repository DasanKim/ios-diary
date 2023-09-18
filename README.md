# 일기장 

- 프로젝트 기간: [2023년 8월 28일 ~ 9월 15일](https://github.com/YaRkyungmin/ios-diary/wiki/타임라인-📋)
- 프로젝트 팀원: [kyungmin🐼](https://github.com/YaRkyungmin), [Dasan🌳](https://github.com/DasanKim)
- 프로젝트 리뷰어: 제임스

---
## 📖 목차
🍀 [소개](#소개) </br>
💻 [실행 화면](#실행_화면) </br>
🛠️ [사용 기술](#사용_기술) </br>
👀 [다이어그램](#Diagram) </br>
🧨 [트러블 슈팅](#트러블_슈팅) </br>
📚 [참고 링크](#참고_링크) </br>
👩‍👧‍👧 [about TEAM](#about_TEAM) </br>

</br>

## 🍀 소개<a id="소개"></a>
- 일기를 작성, 수정, 저장 할 수 있는 일기장 앱입니다.

</br>

## 💻 실행 화면<a id="실행_화면"></a>

| 새로운 일기장 추가 화면 | 기존 일기장 편집 화면 |
| :--------: | :--------: |
| <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152970463513936052/1._.gif" width = "200"> | <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152970497819156530/2._.gif"  width = "200"> |

<details>
        <summary> 추가 실행화면 펼쳐 보기 </summary>

| 일기장 삭제 화면 | 일기장 공유 화면 |
| :--------: | :--------: |
| <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152970525145055335/3._.gif" width = "200"> | <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152970587166216212/4._.gif"  width = "200"> |

| 백그라운드 모드 진입 화면 | 제목없는 일기장 |
| :--------: | :--------: |
| <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152970612478840832/5._.gif" width = "200"> | <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152972805642670151/7._.gif"  width = "200"> |

| 화면모드 변경 |
| :--------: | 
| <img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1152970652672860190/6._.gif" width = "440"> | 
</details>

</br>

## 🛠️ 사용 기술<a id="사용_기술"></a>
| 구현 내용	| 도구 |
|:---:|:---:|
|아키텍쳐|MVC|
|UI|UIKit|
|Localized|Locale|
|리스트 표시|Modern Collection Veiw|
|데이터 관리|Core Data|

</br>

## 👀 Diagram<a id="Diagram"></a>
### 📐 UML
<img src = "https://github.com/YaRkyungmin/ios-diary/assets/106504779/95de7274-33b9-4562-b387-c273d5181a00.jpg" width = "800">

</br>

## 🧨 트러블 슈팅<a id="트러블_슈팅"></a>

### 1️⃣ TextView와 Keyboard
편집중인 텍스트가 키보드에 의해 가리지 않도록하기 위하여 `diaryTextView`와 `keyboard` 사이에 레이아웃 설정이 필요했습니다.

🚨 **문제점** <br>
- diaryTextView와 `keyboardLayoutGuide` 사이에 constraint를 아래와 같이 잡아주었습니다.
    - 키보드의 위치를 추적하는 `keyboardLayoutGuide`와 constraint를 설정하였습니다.
    - 더불어 readability에 최적화된 width를 제공해주는 `readableContentGuide`와 constraint를 설정하여, **긴 글을 쉽게 읽을 수 있도록** 하였습니다.
    ```swift
    NSLayoutConstraint.activate([
        diaryTextView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
        diaryTextView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        diaryTextView.leftAnchor.constraint(equalTo: view.readableContentGuide.leftAnchor),
        diaryTextView.rightAnchor.constraint(equalTo: view.readableContentGuide.rightAnchor)
    ])
    ```
- 하지만 `keyboardLayoutGuide` 같은 경우 `iOS 15`에서부터 적용할 수 있습니다. 
- 아래와 같이 `iOS15` 이상을 사용하는 사람들이 대부분이지만 그 이하 버전을 사용하는 `6%`를 위하여 다른 방법을 모색할 필요가 있었습니다.
    ![](https://hackmd.io/_uploads/B194oMyC3.png)

💡 **해결방법** <br>
- iOS 15 이상일 때와 그 미만 버전일 때를 나누어 레이아웃을 적용해주었습니다.
    - iOS 15이상: keyboardLayoutGuide 적용
    - iOS 15미만: diaryTextView의 contentInset 변경

- iOS 15미만일 때에는 `NotificationCenter`를 통해 키보드가 나타나고 사라질 때를 추적하여, `diaryTextView`의 `contentInset.bottom`을 키보드 높이만큼 변경하였습니다.
    <details>
    <summary> 코드 보기 </summary>
    
    ```swift
    // DiaryDetailViewController.swift
    override func viewWillAppear(_ animated: Bool) {
        if #unavailable(iOS 15.0) {
            addKeyboardObserver()
        }
    }

    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        diaryTextView.contentInset = UIEdgeInsets(
            top: .zero,
            left: .zero,
            bottom: keyboardFrame.size.height,
            right: .zero
        )
    }
    ```
    </details>

<br>

### 2️⃣ Locale 적용

🚨 **문제점** <br>
- Date 포맷을 DateFormatter의 lacale을 `ko_KR`로 적용하였을 때 지역화가 되지 않는 문제점이 발생했습니다.
    ```swift
    dateFormatter.locale = Locale(identifier: "ko_KR")
    ```

💡 **해결방법** <br>
- **프로퍼티를 읽을 당시 사용자의 지역 설정을 나타내는** Locale의 `current` 프로퍼티를 사용하여 지역화 문제를 해결했습니다.
    ```swift
    dateFormatter.locale = Locale.current.identifier
    ```
<br>

### 3️⃣ 100Kg DiaryManager (Model과 ViewController사이의 중간 객체)

🚨 **문제점** <br>
- 기존의 `DiaryManager`타입에서 `DiaryViewController`와 `DiaryDetailViewController`의 비지니스 로직을 모두 가지고 있도록 구현한 뒤 각각의 `ViewController`에 주입시켜줬습니다. 각각의 `ViewController`의 비지니스 로직은 분리시켜줄 수 있었지만 `DiaryManager`가 무거워지는 문제가 발생했습니다.

💡 **해결방법** <br>
- 각각의 `ViewController`마다 `UseCase`를 따로 만들어 `DiaryManager`가 가지고 있는 로직을 분리해준 뒤, 다른 `UseCase`끼리 통신하기 위해서는 `ViewController`의 `Delegate`를 이용하여 통신할 수 있도록 하여 `DiaryManager`의 복잡성을 낮췄습니다.

    ![](https://hackmd.io/_uploads/BJCPhpCRn.png)

<br>

### 4️⃣ 일기 화면에서 수정된 text 반영하기

🚨 **문제점** <br>
두번째 화면(일기 화면)에서 작성 및 수정된 text를 첫번째 화면(리스트 화면)에 반영해주기 위하여 아래와 같은 방법들을 시도해보았습니다.
- 기본적으로 CollectionView에서 `DiffableDataSource`를 사용하고 있으므로 `snapshot`을 활용하여 CollectionView의 data를 업데이트 해주고 있습니다.

#### 1. FetchedResultsController
- 적용
    - `FetchedResultsController`는 Core Data fetch requset 요청의 결과를 관리하고 사용자에게 데이터를 표시하는 데 사용하는 컨트롤러입니다. 이 컨트롤러의 delegate는 **fetch results가 변경되었을 때** fetched results controller가 호출할 메서드를 가지고 있습니다.
    - 메서드들 중 아래 메서드를 활용한다면 fetch results가 변경되었을 때 `쉽게` snapShot을 apply를 해줄 수 있을 것 같아 적용해보기로 하였습니다.
    ```swift
    optional func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith **snapshot**: NSDiffableDataSourceSnapshot
    )
    ```
    - 하지만 해당 controller 메서드의 snapshot를 활용하려고 하였을 때, apply하는 부분에서 아래와 같은 오류가 계속 발생하였습니다🥲(이 부분의 문제 해결을 위하여 오랫동안 붙잡고 있었으나, 결국 원인을 찾지 못하였습니다.) 이에 매개변수의 snapshot를 활용하는 대신 기존에 구현해 놓은 applySnapshot()를 호출하였습니다.
    ```
    Could not cast value of type 'NSTemporaryObjectID_default' (0x1ba22d4c8) to 'Diary.DiaryEntity' (0x104c15c10).
    ```
    
    <details>
        <summary> 코드 보기 </summary>

    ```swift
    // DiaryViewController.swift
    private func applySnapshot() {
        guard let diaryDataSource,
              let fetchedObjects = fetchedResultsController?.fetchedObjects else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, DiaryEntity>()

        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedObjects)
        diaryDataSource.apply(snapshot, animatingDifferences: true)
    }
    ```
    ```swift
    // DiaryViewController.swift
    extension DiaryViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        diaryDataSource?.apply(snapshot as NSDiffableDataSourceSnapshot<DiaryViewController.Section, DiaryEntity>, animatingDifferences: true)
        }
    }
    ```
    </details>  
    
- 장점
    - fetch results의 변경시점을 신경쓰지 않아도 되어 변경할 때 하고 싶은 작업을 수행할 수 있었습니다.
- 단점
    - `diaryDataSource?.apply(snapshot as...)` 대신 기존에 구현해놓은 `applySnapshot`를 활용하면 fetch results가 변경되었을 때 첫번째 화면에 데이터를 반영하는 것에는 문제가 없었지만, controller 매개변수가 제공하는 sanpshot를 활용하지 못해 해당 contorller를 **사용하는 의미가 없다**고 판단하였습니다.
    - 또한 controller 같은 메서드를 사용한다면 ViewController가 특정 delegate를 의존하고 있는 것이므로 **의존성 문제**가 발생할 수 있어 다른 방법을 찾아보기로 하였습니다.

    
#### 2. Delegate 패턴
- 적용
    <details>
        <summary> 코드 보기 </summary>
        
    ```swift
    protocol DiaryDetailViewControllerDelegate: AnyObject {
        func diaryDetailViewController(_ diaryDetailViewController: DiaryDetailViewController, upsert diary: Diary)
        func diaryDetailViewController(_ diaryDetailViewController: DiaryDetailViewController, delete diary: Diary)
    } 
    ```

    ```swift
    // MARK: DiaryDetailViewController Delegate
    extension DiaryViewController: DiaryDetailViewControllerDelegate {
        func diaryDetailViewController(_ diaryDetailViewController: DiaryDetailViewController, upsert diary: Diary) {
            useCase?.upsert(diary)
            loadData()
            applySnapshot()
        }

        func diaryDetailViewController(_ diaryDetailViewController: DiaryDetailViewController, delete diary: Diary) {
            useCase?.delete(diary)
            loadData()
            applySnapshot()
        }
    }
    ```
    </details>
- 단점 
    - `Delegate` 패턴을 이용하여 `diaryDetailViewController`에서 `diaryViewController`로  변경된 데이터의 업데이트를 요청하고 `applySnapshot()`을 호출 하면 보이지 않는 뷰에 대해서 계속해서 `applySnapshot()`하는 단점이 있었습니다.


💡 **해결방법** <br>
#### 3. Delegate 패턴 + viewDidAppear 메서드
- 적용
    - `coreData`를 업데이트 하는 작업만을 `delegate`를 통해 작업하도록 했습니다.
    - `applySnapshot()`은 `delegate`를 통해서 호출하는 대신, `viewDidAppear` 메서드 내에서 호출해주었습니다.
    <details>
        <summary> 코드 보기 </summary>
        
    ```swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applySnapshot()
    }
    ```
    </details>
- 장점
    - 첫번째 화면(리스트 화면)으로 돌아갈 때만 `applySnapshot()`을 호출하므로 보이지 않는 뷰에 대해서 호출하던 단점을 보안할 수 있었습니다.

<br>

### 5️⃣ 배열에 안전하게 접근하기
    
🚨 **문제점** <br>
- `didSelectItemAt`에서 `IndexPath.item`를 통해 `diaryList`에 접근할때 `diaryList` 데이터가 미리 업데이트 되어 있지 않을 때 `Index out of range`가 발생했습니다.

💡 **해결방법** <br>
- `IndexPath.item` 를 통해 `diaryList`를 접근하기 전에 데이터를 미리 업데이트 하지 않은 것은 휴먼에러이지만 이런 상황에서도 `Index out of range`에러를 통한 `Crash`를 막기위한 방법을 고민했습니다. 
    ```swift
    extension Collection {
        subscript (safe index: Index) -> Element? {
            return indices.contains(index) ? self[index] : nil
        }
    }   
    ```
- `Collection` 타입의 유효 범위를 가지고 있는 `indices`라는 프로퍼티에 대해 알게됐고, 접근한 `Index`가 유효할 때는 `Element` 타입을 반환하고 유효하지 않을 때는 `nil`을 반환 하도록 `subscript`메서드를 정의 했습니다. 

<br>

### 6️⃣ 제목없을 때 리스트 높이가 줄어드는 현상
    
🚨 **문제점** <br>
- 일기장의 첫 줄이 없을때 `Diary` 타입의 `title` 속성으로 빈 문자열이 들어갈 경우 목록에서 `cell`의 높이가 줄어드는 문제가 발생했습니다.<br>
    <img src = "https://hackmd.io/_uploads/BkuzARCAh.png" width = "400">

💡 **해결방법** <br>
- `title`속성이 비어있을 경우 `제목 없음` 텍스트를 넣어주도록 로직을 수정하여 해결하였습니다.<br>
    <img src = "https://hackmd.io/_uploads/HkjD0RRR3.png" width = "400">
    
<br>
    
### 7️⃣ 동시접근 문제
    
🚨 **문제점** <br>
1. `DiaryDetailVeiwController`의 `textViewDidEndEditing`에서 `UseCase`의 메서드를 호출
2. `UseCase`의 메서드에서 `UseCaseDelegate`를 통해 `DiaryDetailVeiwControllerDelegate`의 `upsert`메서드를 호출
3. `DiaryDetailVeiwControllerDelegate` 메서드에서 다시 `UseCase`의 프로퍼티로 접근

- 다음과 같은 상황에서 `Simultaneous` 에러가 발생했습니다.
    ![](https://hackmd.io/_uploads/HynGAnC03.png)
    ![](https://hackmd.io/_uploads/S1UzC3RAn.png)

💡 **해결방법** <br>
- UseCase가 struct 였기 때문에 UseCase내 mutating 메서드가 호출 되면 UseCase에 대한 메모리로 직접 접근하게 됩니다.
- 그런 와중에 mutating 메서드 내에서 델리게이트를 통해 다시 UseCase에 접근했기 때문에 동시 접근 오류가 난 것으로 보입니다. 원래 Test했던 코드도 mutating을 붙이니 동시 접근 에러가 발생 했습니다. 
- mutating을 지우거나 UseCase를 Class로 변경했을때는 에러가 발생하지 않았습니다.

    <details>
            <summary> 코드 보기 </summary>
      
    ```swift
    struct TestDiary {
        let content: String
    }
    
    protocol TestUseCaseDelegate: AnyObject {
        func delegateFunc()
    }
    
    struct TestUseCase {
        var testDiary: TestDiary // 호출 순서: 4번
        weak var delegate: TestUseCaseDelegate?
    
        mutating func doingTestUseCase() {
            testDiary = TestDiary(content: "경민")
            delegate?.delegateFunc() // 호출 순서: 2번
        }
    }
    
    class TestVC {
        var testUseCase: TestUseCase?
    
        init(testUseCase: TestUseCase) {
            self.testUseCase = testUseCase
        }
    
        func setupUseCaseDelegate() {
            testUseCase?.delegate = self
        }
    
        func doing() {
            testUseCase?.doingTestUseCase() // 호출 순서: 1번
        }
    }
    
    extension TestVC: TestUseCaseDelegate {
        func delegateFunc() {
            print(testUseCase?.testDiary) // 호출 순서: 3번
        }
    }
    
    let diary = TestDiary(content: "Dasan")
    let useCase = TestUseCase(testDiary: diary)
    let viewController = TestVC(testUseCase: useCase)
    
    viewController.setupUseCaseDelegate()
    viewController.doing()
    ```
    </details> 

</br>

### 8️⃣ 구조 개선
    
🚨 **문제점** <br>
- `diaryPersistentManager`에 접근하기 위해 `ViewController`를 `Delegate`패턴을 이용해 통신하였지만 Delegate간의 통신이 많아지면서 **가독성이 떨어지는 문제가 발생하였습니다.**
    
    <img src = "https://github.com/YaRkyungmin/ios-diary/assets/106504779/8c42a917-dadf-415f-876e-99b5b4e22141.jpg" width = "600">

💡 **해결방법** <br>
- 각각의 `UseCase`에서 `diaryPersistentManager`를 프로퍼티로 가지고 있게 한 뒤 `UseCase` 인스턴스 생성시 주입해줌으로써 복잡한 구조를 개선하였습니다.

    <img src = "https://github.com/YaRkyungmin/ios-diary/assets/106504779/ee8accc8-a776-4972-8d3e-af40463dc8f5.jpg" width = "600">

<br>

## 📚 참고 링크<a id="참고_링크"></a>
    
<details>
        <summary> 참고 링크 펼쳐 보기 </summary>
    
- [🍎Apple Docs: Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [🍎Apple Docs: KeyboardLayoutGuide](https://developer.apple.com/documentation/uikit/uiview/3752221-keyboardlayoutguide)
- [🍎Apple Docs: UITextView](https://developer.apple.com/documentation/uikit/uitextview)
- [🍎Apple Docs: current](https://developer.apple.com/documentation/foundation/locale/2293654-current)
- [🍎Apple Docs: DateFormatter](https://developer.apple.com/documentation/foundation/dateformatter)
- [🍎Apple Docs: NSFetchedResultsController](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller)
- [🍎Apple Docs: NSFetchedResultsControllerDelegate](https://developer.apple.com/documentation/coredata/nsfetchedresultscontrollerdelegate)
- [🍎Apple Docs: Core Data](https://developer.apple.com/documentation/coredata)
- [🍎Apple Docs: Setting up a Core Data stack](https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack)
- [🍎Apple Docs: UITextViewDelegate](https://developer.apple.com/documentation/uikit/uitextviewdelegate)
- [🍎Apple Docs: UISwipeActionsConfiguration](https://developer.apple.com/documentation/uikit/uiswipeactionsconfiguration)
- [🍎Apple Docs: collection](https://developer.apple.com/documentation/swift/collection)
</details>

<br>

---

## 👩‍👧‍👧 about TEAM<a id="about_TEAM"></a>

| <Img src = "https://cdn.discordapp.com/attachments/1100965172086046891/1108927085713563708/admin.jpeg" width="100"> | 🐼Kyungmin🐼  | https://github.com/YaRkyungmin |
| -------- | :--------: | -------- |
| <Img src = "https://user-images.githubusercontent.com/106504779/253477235-ca103b42-8938-447f-9381-29d0bcf55cac.jpeg" width="100"> | **🌳Dasan🌳** | **https://github.com/DasanKim** |
