//
//  ViewController.swift
//  RxSwiftMVVM
//
//  Created by Toru Furuya on 2018/04/15.
//  Copyright © 2018年 toru.furuya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let disposeBag = DisposeBag()
    private let viewModel = ViewModel(with: Model())

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    func bind() {
        // Observe search result and update UI
        viewModel.repositories.asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
                cell.textLabel?.text = element.fullName
                cell.detailTextLabel?.text = "\(element.stargazersCount)"
            }
            .disposed(by: disposeBag)

        // Observe loading status and update UI
        viewModel.isLoading.asDriver()
            .drive(onNext: { isLoading in
                self.activityIndicator.isHidden = !isLoading
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)

        // Observe user input action and trigger searching
        searchBar.rx.text.orEmpty.asDriver()
            .skip(1)
            .debounce(0.3)
            .distinctUntilChanged()
            .drive(onNext: { keyword in
                self.viewModel.fetchGithubSearchResult(with: keyword)
            })
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = viewModel.repositories.value[indexPath.row]
        let alert = UIAlertController(
            title: "Tapped",
            message: repository.fullName,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
