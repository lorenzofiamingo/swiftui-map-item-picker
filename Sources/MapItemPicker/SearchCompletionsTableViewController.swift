//
//  SearchCompletionsTableViewController.swift
//
//
//  Created by Lorenzo Fiamingo on 20/02/22.
//

#if os(iOS)

import UIKit
import MapKit

class SearchCompletionsTableViewController: UITableViewController {
    
    static private let cellReuseID = "CellReuseID"
    
    private var searchCompleter: MKLocalSearchCompleter?
    var searchRegion: MKCoordinateRegion = MKCoordinateRegion(.world) {
        didSet  {
            searchCompleter?.region =  searchRegion
        }
    }
    
    var onCompletionSelection: ((MKLocalSearchCompletion) -> Void)?
    
    var onAppear: (() -> Void)?
    var onDisappear: (() -> Void)?
    
    var searchCompletions: [MKLocalSearchCompletion]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SearchCompletionsTableViewController.cellReuseID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppear?()
        startProvidingCompletions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDisappear?()
        stopProvidingCompletions()
    }
    
    private func startProvidingCompletions() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.region = searchRegion
    }
    
    private func stopProvidingCompletions() {
        searchCompleter = nil
    }
}

extension SearchCompletionsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchCompletions?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Suggestions"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if #available(iOS 14.0, *) {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCompletionsTableViewController.cellReuseID, for: indexPath)
            guard let completion = searchCompletions?[indexPath.item] else { return cell }
            var content = cell.defaultContentConfiguration()
            let text = NSMutableAttributedString(string: completion.title)
            for value in completion.titleHighlightRanges {
                text.setAttributes([.font: content.textProperties.font.bold()], range: value.rangeValue)
            }
            content.attributedText = text
            let secondaryText = NSMutableAttributedString(string: completion.subtitle)
            for value in completion.subtitleHighlightRanges {
                secondaryText.setAttributes([.font: content.secondaryTextProperties.font.bold()], range: value.rangeValue)
            }
            content.secondaryAttributedText = secondaryText
            cell.contentConfiguration = content
            cell.backgroundColor = .clear
            return cell
        } else {
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let completion = searchCompletions?[indexPath.item] else { return }
        onCompletionSelection?(completion)
    }
}

extension SearchCompletionsTableViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

extension SearchCompletionsTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.count > 0 {
            searchCompleter?.queryFragment = text
        } else {
            searchCompleter?.cancel()
            searchCompletions = nil
        }
    }
}


private extension UIFont {
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        
        guard let fd = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        
        return UIFont(descriptor: fd, size: pointSize)
    }
    
    func bold() -> UIFont {
        withTraits(.traitBold)
    }
}

#endif
