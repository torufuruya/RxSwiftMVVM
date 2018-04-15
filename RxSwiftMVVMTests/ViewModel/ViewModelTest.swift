//
//  ViewModelTest.swift
//  RxSwiftMVVMTests
//
//  Created by Toru Furuya on 2018/04/15.
//  Copyright © 2018年 toru.furuya. All rights reserved.
//

import XCTest
import RxSwift
@testable import RxSwiftMVVM

class ViewModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchGithubSearchResult() {
        let viewModel = ViewModel(with: MockModel())
        viewModel.fetchGithubSearchResult(with: "RxSwift")
        XCTAssert(viewModel.repositories.value.count == 3)
        XCTAssert(viewModel.isLoading.value == false)
    }

    class MockModel: Model {
        override func search(with keyword: String) -> Observable<GithubSearchResult> {
            return Observable<GithubSearchResult>.create { observer -> Disposable in
                let items = [
                    GithubRepository(fullName: "Name 1", stargazersCount: 10),
                    GithubRepository(fullName: "Name 2", stargazersCount: 20),
                    GithubRepository(fullName: "Name 3", stargazersCount: 30)
                ]
                let result = GithubSearchResult(items: items, totalCount: items.count)
                observer.onNext(result)
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }
}
