//
//  ViewModel.swift
//  RxSwiftMVVM
//
//  Created by Toru Furuya on 2018/04/15.
//  Copyright © 2018年 toru.furuya. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {

    // Search results
    let repositories = Variable([GithubRepository]())
    // Loading status
    let isLoading = Variable(false)

    private let disposeBag = DisposeBag()
    private var model: Model!

    init(with model: Model) {
        self.model = model
    }

    func fetchGithubSearchResult(with keyword: String) {
        repositories.value.removeAll()
        isLoading.value = true
        model.search(with: keyword)
            .subscribe(onNext: { result in
                self.repositories.value += result.items
            }, onError: { error in
                print(error.localizedDescription)
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            })
            .disposed(by: disposeBag)
    }
}
