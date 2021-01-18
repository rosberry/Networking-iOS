//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Networking

final class SessionTaskServiceMock: SessionTaskService {

    private(set) var passedRequest: URLRequest?

    var dataTask: URLSessionDataTask?
    var uploadTask: URLSessionUploadTask?
    var downloadTask: URLSessionDownloadTask?

    var responseData: Data?
    var responseURL: URL?
    var error: Error?

    private(set) var uploadData: Data?
    private(set) var uploadFileURL: URL?

    override func dataTask(with request: URLRequest, completion: @escaping ResultCompletion<Data>) -> URLSessionDataTask {
        passedRequest = request
        call(completion)
        return dataTask!
    }

    override func uploadTask(with request: URLRequest, data: Data?, completion: @escaping ResultCompletion<Data>) -> URLSessionUploadTask {
        passedRequest = request
        uploadData = data
        call(completion)
        return uploadTask!
    }

    override func uploadTask(with request: URLRequest, fileURL: URL, completion: @escaping ResultCompletion<Data>) -> URLSessionUploadTask {
        passedRequest = request
        uploadFileURL = fileURL
        call(completion)
        return uploadTask!
    }

    override func downloadTask(with request: URLRequest, completion: @escaping ResultCompletion<URL>) -> URLSessionDownloadTask {
        passedRequest = request
        if let responseURL = responseURL {
            completion(.success(responseURL))
        }
        if let error = error {
            completion(.failure(error))
        }
        return downloadTask!
    }

    func clean() {
        passedRequest = nil
        responseData = nil
        error = nil
        dataTask = nil
        uploadTask = nil
        downloadTask = nil
    }

    // MARK: - Private

    private func call(_ completion: ResultCompletion<Data>) {
        if let data = responseData {
            completion(.success(data))
        }
        if let error = error {
            completion(.failure(error))
        }
    }
}
