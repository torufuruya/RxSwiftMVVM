//
//  Model.swift
//  RxSwiftMVVM
//
//  Created by Toru Furuya on 2018/04/15.
//  Copyright © 2018年 toru.furuya. All rights reserved.
//

import Foundation
import RxSwift

struct GithubSearchResult: Codable {
    var items: [GithubRepository]
    var totalCount: Int
}

struct GithubRepository: Codable {
    var fullName: String
    var stargazersCount: Int
}

class Model {

    func search(with keyword: String) -> Observable<GithubSearchResult> {
        let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)")!
        let request = URLRequest(url: url)
        return URLSession.shared.rx
            .data(request: request)
            .map {
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
