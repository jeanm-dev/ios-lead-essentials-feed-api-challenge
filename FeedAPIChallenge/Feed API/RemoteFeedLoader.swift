//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                if response.statusCode == 200, let feedItems = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(feedItems.items))
                } else {
                    completion(.failure(Error.invalidData))
                }
            }
        }
    }
}

struct Root: Decodable {
    let items: [FeedImage]
}
