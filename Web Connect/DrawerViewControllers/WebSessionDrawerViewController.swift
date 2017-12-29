//
//  WebSessionDrawerViewController.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/8/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import CoreData

@objc public protocol ContentDelegate {
    
    var currentURL: URL? { get }

    func bookmark()
    func searchFor(_ url: URL)
    func reload()
    
    @objc optional func addUsers()
    func switchUserAgent()
    func switchBlurEffectStyle()
    func setPulleyPosition(_ pulleyPosition: Int)
}

public protocol WebSessionDrawerDelegate {
    func endEditing()
    func updateBookmarkIconFor(_ url: URL)
    func updateDataUsageGraph(dataUsed: CGFloat, dataCap: CGFloat)
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
    
    private let cellID = "cellID"
    private let baseURL = "https://www.google.com/search?q="
    
    private var bookmarks = [Bookmark]()
    
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var profileView: ProfileManagementView?
    private var userManagementView: UserManagementView?
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var customView: UIView!
    
    @IBOutlet weak var nightModeButton: UIButton! {
        didSet {
            let prefersDark = UserDefaults.standard.bool(forKey: "prefersDark")
            nightModeButton.setImage(prefersDark ? #imageLiteral(resourceName: "FilledMoonIcon") : #imageLiteral(resourceName: "UnfilledMoonIcon"), for: .normal)
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.setImage(#imageLiteral(resourceName: "ReloadIcon"), for: .bookmark, state: .normal)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
            collectionView.backgroundColor = .clear
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
        sender.setTitle(currentTitle == "edit" ? "done" : "edit", for: .normal)
        NotificationCenter.default.post(name: editingBookmarks ? .startEditing : .endEditing, object: self)
    }
    
    // MARK: Private Functions
    
    private func searchFor(_ url: URL) {
        delegate?.searchFor(url)
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
        } else {
            profileView = ProfileManagementView()
            profileView?.translatesAutoresizingMaskIntoConstraints = false
            customView.addSubview(profileView!)
            profileView?.constrainToParent()
        }
    }
    
}

extension WebSessionDrawerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BookmarkCollectionViewCell
        let bookmark = bookmarks[indexPath.item]
        cell.bookmark = bookmark
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = false
        guard let urlString = bookmarks[indexPath.item].url,
            let url = URL(string: urlString) else { return }
        searchFor(url)
    }
}

extension WebSessionDrawerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func updateDataUsageGraph(dataUsed: CGFloat, dataCap: CGFloat) {
        profileView?.updateDataUsageGraph(withDataSet: DataSet(dataUsed, dataCap))
    }
    
    func updateBookmarkIconFor(_ url: URL) {
        changeBookmarkIconForURL(url)
    }
    
    func endEditing() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
}

extension WebSessionDrawerViewController: BookMarkCellDelegate {
    
    func deleteCell(_ cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let bookmarkToDelete = bookmarks[indexPath.row]
        bookmarks.remove(at: indexPath.row)
        moc?.delete(bookmarkToDelete)
        collectionView.deleteItems(at: [indexPath])
    }
}
