//
//  SearchResponseTableViewController.swift
//
//
//  Created by Lorenzo Fiamingo on 21/02/22.
//

#if os(iOS)

import UIKit
import MapKit

class SearchResponseTableViewController: UITableViewController {
    
    static private let cellReuseID = "CellReuseID"
    
    private var currentPlacemark: CLPlacemark?
    
    var onMapItemSelection: ((Int) -> Void)?
    
    var onViewWillLayoutSubviews: (() -> Void)?

    /// View which contains the loading text and the spinner
    let loadingView = UIView()

    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()

    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    var searchResponse: MKLocalSearch.Response? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SearchResponseTableViewController.cellReuseID)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        onViewWillLayoutSubviews?()
    }

    // Set the activity indicator into the main view
    func setLoadingScreen() {

        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2)
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        loadingLabel.isHidden = false

        // Sets spinner
        spinner.style = UIActivityIndicatorView.Style.medium
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        spinner.isHidden = false

        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)

        tableView.addSubview(loadingView)

    }

    // Remove the activity indicator from the main view
    func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true

    }
}

extension SearchResponseTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResponse?.mapItems.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let city = currentPlacemark?.locality {
            return "Results near \(city)"
        } else {
            return "Results"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if #available(iOS 14.0, *) {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResponseTableViewController.cellReuseID, for: indexPath)
            if let response = searchResponse {
                let mapItem = response.mapItems[indexPath.item]
                var content = cell.defaultContentConfiguration()
                content.text = mapItem.placemark.name
                content.secondaryText = mapItem.placemark.title
                cell.contentConfiguration = content
            }
            return cell
        } else {
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onMapItemSelection?(indexPath.item)
    }
}

#endif
