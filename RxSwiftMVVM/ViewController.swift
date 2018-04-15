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

    let disposeBag = DisposeBag()

    let repositories = Variable([GithubRepository]())
    let isLoading = Variable(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    func bind() {
        repositories.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
                cell.textLabel?.text = element.fullName
                cell.detailTextLabel?.text = "\(element.stargazersCount)"
            }.disposed(by: disposeBag)

        isLoading.asDriver()
            .drive(onNext: { isLoading in
                self.activityIndicator.isHidden = !isLoading
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)

        searchBar.rx.text.orEmpty.asDriver()
            .skip(1)
            .debounce(0.3)
            .distinctUntilChanged()
            .drive(onNext: { keyword in
                self.repositories.value.removeAll()
                self.search(with: keyword)
            }, onCompleted: {
            }).disposed(by: disposeBag)
    }

    func search(with keyword: String) {
        isLoading.value = true
        fetchGithubSearchResult(with: keyword)
            .subscribe(onNext: { result in
                self.repositories.value += result.items
            }, onError: { error in
                print(error.localizedDescription)
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            }).disposed(by: disposeBag)
    }

    func fetchGithubSearchResult(with keyword: String) -> Observable<GithubSearchResult> {
        let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request).map {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode(GithubSearchResult.self, from: $0)
            } catch {
                print(error.localizedDescription)
            }
            return GithubSearchResult(items: [], totalCount: 0)
        }
    }
}


struct GithubSearchResult: Codable {
    var items: [GithubRepository]
    var totalCount: Int
}

struct GithubRepository: Codable {
    var fullName: String
    var stargazersCount: Int
}
