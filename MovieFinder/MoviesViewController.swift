//
//  MoviesViewController.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit
import MBProgressHUD
import DropDown
import SnapKit


enum LayoutType {
    case list
    case grid
}


class MoviesViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    // MARK: - Stored Properties
    
    var collectionView: UICollectionView!
    var changeLayoutBarButtonItem: UIBarButtonItem!
    var tableViewRefreshControl: UIRefreshControl!
    var collectionViewRefreshControl: UIRefreshControl!
    
    var movieAPI: TheMovieDBAPI!
    var endpoint = ""
    
    var collectionViewDataSource = MoviesCollectionViewDataSource()
    var tableViewDataSource = MoviesTableViewDataSource()
    let rowHeight = 200
    
    var movies = [Movie]()
    
    let dropDown = DropDown()
    var searchList = [String]()
    let maxQueries = 10
    
    var errorBannerView: UIView!
    
    
    // MARK: - Property Observers
    
    var filteredMovies = [Movie]() {
        didSet {
            tableViewDataSource.movies = filteredMovies
            collectionViewDataSource.movies = filteredMovies
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    var displayType: LayoutType = .list {
        didSet {
            switch displayType {
            case .list:
                self.tableView.isHidden = false
                self.collectionView.isHidden = true
            case .grid:
                self.tableView.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }
    
    var isErrorBannerDisplayed: Bool! {
        didSet {
            errorBannerView.isHidden = !isErrorBannerDisplayed
        }
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        movieAPI = TheMovieDBAPI(endpoint: endpoint)
        movieAPI.delegate = self
        fetchData()
        
        self.edgesForExtendedLayout = []
        
        isErrorBannerDisplayed = false
        
        displayType = .list
        
        searchBar.delegate = self
        
        if endpoint == "popular" {
            searchBar.placeholder = "Look for a popular movie"
        } else if endpoint == "search" {
            searchBar.placeholder = "Search any movie"
            self.navigationItem.leftBarButtonItems = nil
        }
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(hideDropDown))
        swipe.direction = .up
        self.dropDown.addGestureRecognizer(swipe)
        
    }
    
    
    // MARK: - Target Action
    
    @objc func switchLayout() {
        switch displayType {
        case .grid:
            changeLayoutBarButtonItem.image = UIImage(named:"grid")
            displayType = .list
        case .list:
            changeLayoutBarButtonItem.image = UIImage(named: "list")
            displayType = .grid
        }
    }
    
    @objc func refreshData() {
        if endpoint == "popular" {
            fetchData()
        } else if endpoint == "search" {
            DispatchQueue.main.async {
                self.tableViewRefreshControl.endRefreshing()
                self.collectionViewRefreshControl.endRefreshing()
            }
            
        }
    }
}


// MARK: - Network Requests

extension MoviesViewController {
    
    func fetchData() {
        if endpoint == "popular" {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            movieAPI.startUpdatingMovies()
        }
    }
    
}


// MARK: - SearchBar Delegate

extension MoviesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies :  movies.filter {($0.title ?? "").range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil }
        if endpoint == "search" {
            movieAPI.startSearchMovies(query: searchText)
        }

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !(searchBar.text?.isEmpty)!{
            
            if endpoint == "search" {
            
                movieAPI.startSearchMovies(query: searchBar.text!)
            
                if !(movies.contains(where: {$0.title?.caseInsensitiveCompare("\(String(describing: searchBar.text))") != .orderedSame})) {
                    
                    alert(alertTitle: "Movie not found!", alertMessage: "The movie '\(searchBar.text!.lowercased())' doesn't exist. Search another one!")
                    
                } else {
                    
                    if !searchList.contains(searchBar.text!) {
                        
                        if searchList.count < 10 {
                        
                            self.searchList.insert(searchBar.text!, at: 0)
                            
                        } else {
                            
                            searchList.remove(at: maxQueries - 1)
                            self.searchList.insert(searchBar.text!, at: 0)
                        }
                    }
                    
                    setupDropDown()
                    
                    searchBar.resignFirstResponder()
                    
                }
         
            } else {
                
                searchBar.resignFirstResponder()
                
            }
            
        } else {
            
        alert(alertTitle: "Search box is empty!", alertMessage: "Please enter the title of a movie.")
            
        }
    }
    
    
    func setupDropDown() {
        
        // The view to which the drop down will appear on
        dropDown.anchorView = searchBar // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = searchList
        
        
        // Top of drop down will be below the anchorView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.searchBar.text = item
            self.movieAPI.startSearchMovies(query: item)
        }
        
        dropDown.show()
    }
    
    
    @objc func hideDropDown() {
        self.dropDown.hide()
    }
    
    
    func alert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        filteredMovies = movies
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        setupDropDown()
        return true
    }
    
}

// MARK: - TheMovieDBAPI Delegate

extension MoviesViewController: TheMovieDBDelegate {
    func theMovieDB(didFinishUpdatingMovies movies: [Movie]) {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.movies = movies
            self.filteredMovies = movies
            DispatchQueue.main.async {
                self.tableViewRefreshControl.endRefreshing()
                self.collectionViewRefreshControl.endRefreshing()
            }
            isErrorBannerDisplayed = false
    }
    
    func theMovieDB(didFailWithError error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true)
        DispatchQueue.main.async {
            self.tableViewRefreshControl.endRefreshing()
            self.collectionViewRefreshControl.endRefreshing()
        }
        isErrorBannerDisplayed = true
    }
}


// MARK: - Navigation

extension MoviesViewController {
    
    func pushToDetailViewController(with indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "movieDetailViewController") as! MovieDetailViewController
        detailViewController.movie = filteredMovies[indexPath.row]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - TableView Delegate

extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        pushToDetailViewController(with: indexPath)
    }
}

// MARK: - CollectionView Delegate

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushToDetailViewController(with: indexPath)
    }
}

// MARK: - Helpers

extension MoviesViewController {
    func setupViews() {
        setupErrorBannerView()
        setupCollectionView()
        setupTableView()
        setupRefreshControls()
        setupChangeLayoutBarButton()
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: GridLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.darkText
        collectionView.register(MovieCollectionCell.self, forCellWithReuseIdentifier: "movieCollectionCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = collectionViewDataSource
        self.view.addSubview(collectionView)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
        tableView.rowHeight = CGFloat(rowHeight)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }

    }
    
    func setupRefreshControls() {
        collectionViewRefreshControl = UIRefreshControl()
        collectionViewRefreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView.insertSubview(collectionViewRefreshControl, at: 0)
        
        tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableView.insertSubview(tableViewRefreshControl, at: 0)
    }
    
    func setupChangeLayoutBarButton() {
        changeLayoutBarButtonItem = UIBarButtonItem(image: UIImage(named:"grid"), style: .plain, target: self, action: #selector(self.switchLayout))
        self.navigationItem.leftBarButtonItem = changeLayoutBarButtonItem
    }
    
    func setupErrorBannerView() {
        let errorView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        errorView.backgroundColor = .darkGray
        let errorLabel = UILabel(frame: CGRect(x: errorView.bounds.origin.x + 8, y: errorView.bounds.origin.y + 8, width: errorView.bounds.width - 8, height: errorView.bounds.height - 8))
        errorLabel.textColor = .white
        
       //let mutableString = NSMutableAttributedString(attributedString: NSAttributedString(string: "   ", attributes: [NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 17)!, NSForegroundColorAttributeName : UIColor.lightGray]))
       //mutableString.append(NSAttributedString(string: "Network Error", attributes: [NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 15)!, NSForegroundColorAttributeName : UIColor.white]))
        
        let mutableString = NSMutableAttributedString(string: "   ", attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.white])
        mutableString.append(NSAttributedString(string: "Network Error", attributes: [NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-Bold", size: 15)!, NSAttributedStringKey.foregroundColor : UIColor.white]))
        errorLabel.attributedText = mutableString
        errorLabel.textAlignment = .center
        errorView.addSubview(errorLabel)
        errorBannerView = errorView
        self.view.addSubview(errorBannerView)
    }
}
