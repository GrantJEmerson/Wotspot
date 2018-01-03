//
//  WebSessionDrawerViewController.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/8/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import CoreData
import MultipeerConnectivity

@objc public protocol ContentDelegate {
    
    var currentURL: URL? { get }

    func searchFor(_ url: URL)
    func reload()
    func cancel()
    func bookmark()
    
    @objc optional func addUsers()
    func leaveSession()
    @objc optional func setPeerIDTo(_ displayName: String)
    @objc optional func addDataForPeer(_ peerID: MCPeerID)
    @objc optional func removePeer(_ peerID: MCPeerID)
    
    func switchUserAgent()
    func switchBlurEffectStyle()
    func setPulleyPosition(_ pulleyPosition: Int)
}

protocol WebSessionDrawerDelegate {
    func endEditing()
    func updateBookmarkIconFor(_ url: URL)
    func updateDataUsageGraph(dataSet: DataSet)
    func updateUsers(_ users: [User])
    func setProgressBarTo(_ progress: Float)
    func prepareForSearch()
}

class WebSessionDrawerViewController: UIViewController {
    
    // MARK: Properties
    
    public var delegate: ContentDelegate?
    
    private let isHost: Bool
    
    private var isLoading = false
    private var editingBookmarks = false
    
    private let bookmarkCellID = "bookmarkCellID"
    private let noBookmarksCellID = "noBookmarksCellID"
    
    private var bookmarks = [Bookmark]()
    
    private lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    @available(iOS 10.0, *)
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private lazy var profileManagementView: ProfileManagementView = {
        let view = ProfileManagementView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userManagementView: UserManagementView = {
        let view = UserManagementView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var nightModeButton: UIButton! {
        didSet {
            let prefersDark = UserDefaults.standard.bool(forKey: "prefersDark")
            nightModeButton.setImage(prefersDark ? #imageLiteral(resourceName: "FilledMoonIcon") : #imageLiteral(resourceName: "UnfilledMoonIcon"), for: .normal)
        }
    }
    
    private lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet { setUpSearchBar() }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: bookmarkCellID)
            collectionView.register(NoBookmarksCollectionViewCell.self, forCellWithReuseIdentifier: noBookmarksCellID)
            collectionView.backgroundColor = .clear
            collectionView.autoresizesSubviews = true
        }
    }
    
    // MARK: View Controller Life Cycle
    
    init(isHost: Bool) {
        self.isHost = isHost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getBookmarks()
        setUpCustomView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isHost else { return }
        profileManagementView.updateDataUsageGraph(withDataSet: DataSet(0, 100))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
    }
        
    // MARK: IBActions
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let url = delegate?.currentURL else { return }
        let shareView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(shareView, animated: true)
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        
        guard let currentURL = delegate?.currentURL else { return }

        let existingBookmark = bookmarks.first { (bookmark) -> Bool in
            return bookmark.url == currentURL.absoluteString
        }
        
        if let existingBookmark = existingBookmark {
            if #available(iOS 10.0, *) {
                moc?.delete(existingBookmark)
            } else {
                guard let moc = appDelegate?.managedObjectContext else { return }
                moc.delete(existingBookmark)
            }
        } else {
            delegate?.bookmark()
        }
        
        getBookmarks()

        sender.switchImage(imageSet: ImageSet(image1: #imageLiteral(resourceName: "BookmarkIcon"), image2: #imageLiteral(resourceName: "FilledBookmarkIcon")),
                           transition: .transitionCrossDissolve)
    }
    
    @IBAction func userAgentButtonTapped(_ sender: UIButton) {
        delegate?.switchUserAgent()
        let transition: UIViewAnimationOptions = (sender.image(for: .normal) == #imageLiteral(resourceName: "MobileIcon")) ? .transitionFlipFromRight : .transitionFlipFromLeft
        sender.switchImage(imageSet: ImageSet(image1: #imageLiteral(resourceName: "DesktopIcon"), image2: #imageLiteral(resourceName: "MobileIcon")),
                           transition: transition)
    }
    
    @IBAction func nightModeButtontTapped(_ sender: UIButton) {
        delegate?.switchBlurEffectStyle()
        sender.switchImage(imageSet: ImageSet(image1: #imageLiteral(resourceName: "UnfilledMoonIcon"), image2: #imageLiteral(resourceName: "FilledMoonIcon")),
                           transition: .transitionCrossDissolve)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        editingBookmarks = !editingBookmarks
        let currentTitle = sender.titleLabel?.text
        sender.setTitle(currentTitle == "Edit" ? "Done" : "Edit", for: .normal)
        NotificationCenter.default.post(name: editingBookmarks ? .startEditing : .endEditing, object: self)
    }
    
    // MARK: Private Functions
    
    private func searchFor(_ url: URL) {
        delegate?.searchFor(url)
        prepareForSearch()
    }
    
    internal func prepareForSearch() {
        progressBar.setProgress(0.15, animated: true)
        searchBar.setImage(#imageLiteral(resourceName: "CancelLoadIcon"), for: .bookmark, state: .normal)
        isLoading = true
    }
    
    private func getBookmarks() {
        var moc: NSManagedObjectContext?
        if #available(iOS 10.0, *) {
            moc = self.moc
        } else {
            moc = appDelegate?.managedObjectContext
        }
        
        let fetchRequest = Bookmark.fetchRequest() as NSFetchRequest<Bookmark>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            guard let bookmarks = try moc?.fetch(fetchRequest) else { return }
            self.bookmarks = bookmarks
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func changeBookmarkIconForURL(_ url: URL) {
        let bookmarkExists = bookmarks.contains { (bookmark) -> Bool in
            return bookmark.url == url.absoluteString
        }
        bookmarkButton.setImage(bookmarkExists ? #imageLiteral(resourceName: "FilledBookmarkIcon") : #imageLiteral(resourceName: "BookmarkIcon"), for: .normal)
    }
    
    private func setUpCustomView() {
        let view = isHost ? userManagementView : profileManagementView
        customView.addSubview(view)
        view.constrainToParent()
    }
    
    private func setUpSearchBar() {
        searchBar.setImage(#imageLiteral(resourceName: "ReloadIcon"), for: .bookmark, state: .normal)
        searchBar.tintColor = UserDefaults.standard.bool(forKey: "prefersDark") ? .white : .defaultButtonColor
        searchBar.autocapitalizationType = .none
        
        NotificationCenter.default.addObserver(forName: .lightenLabels, object: nil, queue: .main) { (_) in
            UIView.animate(withDuration: 0.8) {
                self.searchBar.tintColor = .white
            }
        }
        
        NotificationCenter.default.addObserver(forName: .darkenLabels, object: nil, queue: .main) { (_) in
            UIView.animate(withDuration: 0.8) {
                self.searchBar.tintColor = .defaultButtonColor
            }
        }
        
        guard let searchBarRoundedView = searchBar.subviews.first?.subviews[1].subviews.first else { return }
        searchBarRoundedView.addSubview(progressBar)
        searchBarRoundedView.layer.cornerRadius = 10
        searchBarRoundedView.clipsToBounds = true
                
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: searchBarRoundedView.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: searchBarRoundedView.trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: searchBarRoundedView.bottomAnchor)
        ])
    }
    
}

// MARK: Implementation Of Delegates

extension WebSessionDrawerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !bookmarks.isEmpty else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: noBookmarksCellID, for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bookmarkCellID, for: indexPath) as! BookmarkCollectionViewCell
        let bookmark = bookmarks[indexPath.item]
        cell.bookmark = bookmark
        cell.editing = editingBookmarks
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = false
        guard let bookmarkCell = cell as? BookmarkCollectionViewCell else { return }
        guard let urlString = bookmarkCell.bookmark?.url,
            let url = URL(string: urlString) else { return }
        searchFor(url)
    }
}

extension WebSessionDrawerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !bookmarks.isEmpty else { return 1 }
        return bookmarks.count
    }
}

extension WebSessionDrawerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let widthToHeightRatio: CGFloat = 0.592
        let width = height * widthToHeightRatio
        return CGSize(width: width, height: height)
    }
}

extension WebSessionDrawerViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        guard let url = text.isLink ? URL(string: text) : URL(search: text) else { return }
        searchFor(url)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        delegate?.setPulleyPosition(PulleyPosition.collapsed.rawValue)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        delegate?.setPulleyPosition(PulleyPosition.collapsed.rawValue)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        delegate?.setPulleyPosition(PulleyPosition.partiallyRevealed.rawValue)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !isLoading && delegate?.currentURL != nil {
            prepareForSearch()
            delegate?.reload()
        } else {
            searchBar.setImage(#imageLiteral(resourceName: "ReloadIcon"), for: .bookmark, state: .normal)
            progressBar.setProgress(0, animated: false)
            delegate?.cancel()
        }
    }
}

// MARK: Implementation of Custom Delegates

extension WebSessionDrawerViewController: WebSessionDrawerDelegate {
    
    func updateUsers(_ users: [User]) {
        userManagementView.users = users
    }
    
    func updateDataUsageGraph(dataSet: DataSet) {
        profileManagementView.updateDataUsageGraph(withDataSet: dataSet)
    }
    
    func updateBookmarkIconFor(_ url: URL) {
        changeBookmarkIconForURL(url)
    }
    
    func endEditing() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    
    func setProgressBarTo(_ progress: Float) {
        guard progress < 1 else {
            progressBar.progress = 1
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.progressBar.layoutIfNeeded()
            }) { [weak self] _ in
                self?.progressBar.setProgress(0, animated: false)
                self?.searchBar.setImage(#imageLiteral(resourceName: "ReloadIcon"), for: .bookmark, state: .normal)
                self?.isLoading = false
            }
            return
        }
        progressBar.setProgress(progress, animated: true)
    }
}

extension WebSessionDrawerViewController: BookMarkCellDelegate {
    
    func deleteCell(_ cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let bookmarkToDelete = bookmarks[indexPath.row]
        bookmarks.remove(at: indexPath.row)
        if #available(iOS 10.0, *) {
            moc?.delete(bookmarkToDelete)
        } else {
            guard let moc = appDelegate?.managedObjectContext else { return }
            moc.delete(bookmarkToDelete)
        }
        appDelegate?.saveContext()
        if bookmarks.isEmpty {
            collectionView.reloadData()
        } else {
            collectionView.deleteItems(at: [indexPath])
        }
    }
}

extension WebSessionDrawerViewController: UserManagementViewDelegate {
    
    func addDataForPeer(_ peerID: MCPeerID) {
        delegate?.addDataForPeer!(peerID)
    }
    
    func removePeer(_ peerID: MCPeerID) {
        delegate?.removePeer!(peerID)
    }
    
    func endSession() {
        delegate?.leaveSession()
    }

    func addUsers() {
        delegate?.addUsers!()
    }
}

extension WebSessionDrawerViewController: ProfileManagementViewDelegate {
    
    func setPeerIDTo(_ displayName: String) {
        delegate?.setPeerIDTo!(displayName)
    }
    
    func leaveSession() {
        delegate?.leaveSession()
    }
    
    func movePulleyViewControllerUp() {
        UIView.animate(withDuration: 0.8) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.transform = strongSelf.view.transform.translatedBy(x: 0, y: -100)
        }
    }
    
    func movePulleyViewControllerDown() {
        UIView.animate(withDuration: 0.8) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.transform = .identity
        }
    }
}

extension WebSessionDrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        gripperTopConstraint.isActive = drawer.currentDisplayMode != .leftSide
    }
}
