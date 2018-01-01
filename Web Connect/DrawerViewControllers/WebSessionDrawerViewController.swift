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

    func bookmark()
    func searchFor(_ url: URL)
    func reload()
    
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
}

class WebSessionDrawerViewController: UIViewController {
    
    // MARK: Properties
    
    public var delegate: ContentDelegate?
    
    public var isHosting: Bool! {
        didSet {
            setUpCustomView()
        }
    }
    
    private var editingBookmarks = false
    
    private let bookmarkCellID = "bookmarkCellID"
    private let noBookmarksCellID = "noBookmarksCellID"
    private let baseURL = "https://www.google.com/search?q="
    
    private var bookmarks = [Bookmark]()
    
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var profileView: ProfileManagementView?
    private var userManagementView: UserManagementView?
    
    @IBOutlet weak var gripperTopConstraint: NSLayoutConstraint!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        getBookmarks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileView?.updateDataUsageGraph(withDataSet: DataSet(0, 100))
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
        
        var bookmarkToDelete: Bookmark?
        for bookmark in bookmarks {
            guard bookmark.url == currentURL.absoluteString else { continue }
            bookmarkToDelete = bookmark
        }
        
        if let bookmarkToDelete = bookmarkToDelete {
            moc?.delete(bookmarkToDelete)
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
        progressBar.setProgress(0.15, animated: true)
    }
    
    private func getBookmarks() {
        guard let moc = moc else { return }
        let fetchRequest = Bookmark.fetchRequest() as NSFetchRequest<Bookmark>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            bookmarks = try moc.fetch(fetchRequest)
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
        if isHosting {
            userManagementView = UserManagementView()
            userManagementView?.translatesAutoresizingMaskIntoConstraints = false
            customView.addSubview(userManagementView!)
            userManagementView?.constrainToParent()
            userManagementView?.delegate = self
        } else {
            profileView = ProfileManagementView()
            profileView?.translatesAutoresizingMaskIntoConstraints = false
            customView.addSubview(profileView!)
            profileView?.constrainToParent()
            profileView?.delegate = self
        }
    }
    
    private func setUpSearchBar() {
        searchBar.setImage(#imageLiteral(resourceName: "ReloadIcon"), for: .bookmark, state: .normal)
        searchBar.autocapitalizationType = .none
        
        guard let searchBarRoundedView = searchBar.subviews.first?.subviews[1].subviews[0] else { return }
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
        collectionView.cellForItem(at: indexPath)?.isSelected = false
        guard !bookmarks.isEmpty,
            let urlString = bookmarks[indexPath.item].url,
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
        let width = height * 0.592
        return CGSize(width: width, height: height)
    }
}

extension WebSessionDrawerViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let search = text.isLink ? text : baseURL + text.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: search) else { return }
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
        delegate?.reload()
    }
}

extension WebSessionDrawerViewController: WebSessionDrawerDelegate {
    
    func updateUsers(_ users: [User]) {
        userManagementView?.users = users
    }
    
    func updateDataUsageGraph(dataSet: DataSet) {
        profileView?.updateDataUsageGraph(withDataSet: dataSet)
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
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.layoutIfNeeded()
            }) { _ in
                self.progressBar.setProgress(0, animated: false)
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
        moc?.delete(bookmarkToDelete)
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
            strongSelf.view.transform = CGAffineTransform.identity
        }
    }
}

extension WebSessionDrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 290 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        guard gripperTopConstraint != nil else { return }
        gripperTopConstraint.isActive = drawer.currentDisplayMode != .leftSide
    }
}
