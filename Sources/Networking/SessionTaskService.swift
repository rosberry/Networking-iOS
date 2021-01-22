//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

open class SessionTaskService {

    public let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Data

    @discardableResult
    open func dataTask(with request: URLRequest, completion: @escaping ResultCompletion<Data>) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.handle(data, error: error, urlResponse: response, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func dataTask(with request: URLRequest, success: @escaping Success<Data>, failure: Failure? = nil) -> URLSessionDataTask {
        dataTask(with: request) { result in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure?(error)
            }
        }
    }

    // MARK: - Upload

    @discardableResult
    open func uploadTask(with request: URLRequest, fileURL: URL, completion: @escaping ResultCompletion<Data>) -> URLSessionUploadTask {
        let task = session.uploadTask(with: request, fromFile: fileURL) { [weak self] data, response, error in
            self?.handle(data, error: error, urlResponse: response, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func uploadTask(with request: URLRequest,
                           fileURL: URL,
                           success: @escaping Success<Data>,
                           failure: Failure? = nil) -> URLSessionUploadTask {
        uploadTask(with: request, fileURL: fileURL) { result in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure?(error)
            }
        }
    }

    @discardableResult
    open func uploadTask(with request: URLRequest, data: Data?, completion: @escaping ResultCompletion<Data>) -> URLSessionUploadTask {
        let task = session.uploadTask(with: request, from: data) { [weak self] data, response, error in
            self?.handle(data, error: error, urlResponse: response, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func uploadTask(with request: URLRequest,
                           data: Data?,
                           success: @escaping Success<Data>,
                           failure: Failure? = nil) -> URLSessionUploadTask {
        uploadTask(with: request, data: data) { result in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure?(error)
            }
        }
    }

    // MARK: - Download

    @discardableResult
    open func downloadTask(with request: URLRequest, completion: @escaping ResultCompletion<URL>) -> URLSessionDownloadTask {
        let task = session.downloadTask(with: request) { [weak self] url, response, error in
            self?.handle(url, error: error, urlResponse: response, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func downloadTask(with request: URLRequest, success: @escaping Success<URL>, failure: Failure? = nil) -> URLSessionDownloadTask {
        downloadTask(with: request) { result in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure?(error)
            }
        }
    }

    @discardableResult
    open func downloadTask(withResumeData resumeData: Data, completion: @escaping ResultCompletion<URL>) -> URLSessionDownloadTask {
        let task = session.downloadTask(withResumeData: resumeData) { [weak self] url, response, error in
            self?.handle(url, error: error, urlResponse: response, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    open func downloadTask(withResumeData resumeData: Data,
                           success: @escaping Success<URL>,
                           failure: Failure? = nil) -> URLSessionDownloadTask {
        downloadTask(withResumeData: resumeData) { result in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let error):
                failure?(error)
            }
        }
    }

    // MARK: - Private

    private func handle<Response>(_ response: Response?,
                                  error: Swift.Error?,
                                  urlResponse: URLResponse?,
                                  completion: @escaping (ResultCompletion<Response>)) {
        let error = error ?? self.error(from: urlResponse)
        if let errors = error {
            completion(.failure(errors))
        }
        else if let response = response {
            completion(.success(response))
        }
        else {
            completion(.failure(NetworkingError.noData))
        }
    }

    private func error(from response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }

        switch response.statusCode {
        case 400..<600:
            return NetworkingError.responseValidationFailed(responseCode: response.statusCode)
        default:
            return nil
        }
    }
}
