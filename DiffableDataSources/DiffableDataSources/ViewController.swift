//
//  ViewController.swift
//  DiffableDataSources
//
//  Created by Anupam Chugh on 24/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import UIKit

enum Section : CaseIterable {
    case one
    case two
}

class ViewController: UIViewController, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let cellReuseIdentifier = "cellId"
    private lazy var dataSource = makeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.register(UITableViewCell.self,forCellReuseIdentifier: cellReuseIdentifier)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.delegate = self
        
        tableView.dataSource = dataSource
        updateDataSource(animated: true)
    }
    
    func updateDataSource(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Movies>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([Movies(name: "Inception")], toSection: .one)
        snapshot.appendItems([Movies(name: "War")], toSection: .one)
        snapshot.appendItems([Movies(name: "Departed")], toSection: .one)
        
        snapshot.appendItems([Movies(name: "Departed")], toSection: .two)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let movie = dataSource.itemIdentifier(for: indexPath) {
            print("selected movie \(movie.name)")
            
            var currentSnapshot = dataSource.snapshot()
            currentSnapshot.deleteItems([movie])
            dataSource.apply(currentSnapshot)
        }
    }
}

extension ViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Section, Movies> {
        let reuseIdentifier = cellReuseIdentifier
        
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, movie in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath)
                
                cell.textLabel?.text = movie.name
                
                return cell
        }
        )
    }
}

struct Movies: Hashable {
    let identifier: UUID = UUID()
    let name: String
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    static func == (lhs: Movies, rhs: Movies) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
