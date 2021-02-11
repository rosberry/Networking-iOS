//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public typealias ResultCompletion<Response> = (Result<Response, Error>) -> Void
public typealias Success<Response> = (Response) -> Void
public typealias Failure = (Error) -> Void

public enum NetworkingError: Swift.Error, Equatable {
    case noData
    case wrongURL
    case responseValidationFailed(responseCode: Int)
}

public protocol ErrorHandler {
    func handle<E: Endpoint>(error: inout Error, endpoint: E)
}

open class RequestService {

    public enum UploadTask {
        case file(URL)
        case data(Data?)
    }

    public var errorHandlers: [ErrorHandler]

    public let sessionTaskService: SessionTaskService
    public let requestFactory: RequestFactory
    public let decoder: JSONDecoder

    // Dictionary of tasks where key is Endpoint and value is URLSessionTask
    public var tasks: [AnyHashable: URLSessionTask] = [:]

    public init(sessionTaskService: SessionTaskService = .init(),
                requestFactory: RequestFactory = .init(),
                decoder: JSONDecoder = .init(),
                errorHandlers: [ErrorHandler] = [GeneralErrorHandler()]) {
        self.sessionTaskService = sessionTaskService
        self.requestFactory = requestFactory
        self.decoder = decoder
        self.errorHandlers = errorHandlers
    }

    // MARK: - Decoding

    @discardableResult
    public func request<Response: Decodable, E: Endpoint>(_ endpoint: E,
                                                          queue: DispatchQueue = .main,
                                                          completion: @escaping ResultCompletion<Response>) -> URLSessionDataTask? {
        request(endpoint) { [weak self, unowned decoder] result in
            let decodeResult: Result<Response, Error> = decoder.decodeResult(result)
            self?.handleResult(decodeResult, endpoint: endpoint, queue: queue, success: { response in
                completion(.success(response))
            }, failure: { error in
                completion(.failure(error))
            })
        }
    }

    @discardableResult
    public func request<Response: Decodable, E: Endpoint>(_ endpoint: E,
                                                          queue: DispatchQueue = .main,
                                                          success: @escaping Success<Response>,
                                                          failure: Failure? = nil) -> URLSessionDataTask? {
        request(endpoint, queue: queue) { [weak self] (result: Result<Response, Error>) in
            self?.handleResult(result, endpoint: endpoint, queue: queue, success: success, failure: failure)
        }
    }

    @discardableResult
    public func uploadRequest<Response: Decodable, E: Endpoint>(_ endpoint: E,
                                                                task: UploadTask,
                                                                queue: DispatchQueue = .main,
                                                                completion: @escaping ResultCompletion<Response>) -> URLSessionUploadTask? {
        uploadRequest(endpoint, task: task) { [weak self, unowned decoder] result in
            let decodeResult: Result<Response, Error> = decoder.decodeResult(result)
            self?.handleResult(decodeResult, endpoint: endpoint, queue: queue, success: { response in
                completion(.success(response))
            }, failure: { error in
                completion(.failure(error))
            })
        }
    }

    @discardableResult
    public func uploadRequest<Response: Decodable, E: Endpoint>(_ endpoint: E,
                                                                task: UploadTask,
                                                                queue: DispatchQueue = .main,
                                                                success: @escaping Success<Response>,
                                                                failure: Failure? = nil) -> URLSessionUploadTask? {
        uploadRequest(endpoint, task: task, queue: queue) { [weak self] (result: Result<Response, Error>) in
            self?.handleResult(result, endpoint: endpoint, queue: queue, success: success, failure: failure)
        }
    }

    // MARK: - Requests

    @discardableResult
    public func request<E: Endpoint>(_ endpoint: E, completion: @escaping ResultCompletion<Data>) -> URLSessionDataTask? {
        do {
            let request = try requestFactory.makeRequest(endpoint: endpoint)
            let task = sessionTaskService.dataTask(with: request, completion: completion)
            cancelTaskIfNeeded(for: endpoint)
            tasks[endpoint] = task
            return task
        }
        catch {
            completion(.failure(error))
            return nil
        }
    }

    @discardableResult
    public func request<E: Endpoint>(_ endpoint: E,
                                     queue: DispatchQueue = .main,
                                     success: @escaping Success<Data>,
                                     failure: Failure? = nil) -> URLSessionDataTask? {
        request(endpoint) { [weak self] result in
            self?.handleResult(result, endpoint: endpoint, queue: queue, success: success, failure: failure)
        }
    }

    @discardableResult
    public func uploadRequest<E: Endpoint>(_ endpoint: E,
                                           task: UploadTask,
                                           completion: @escaping ResultCompletion<Data>) -> URLSessionUploadTask? {
        do {
            let request = try requestFactory.makeRequest(endpoint: endpoint)
            let dataTask: URLSessionUploadTask
            switch task {
            case .file(let url):
                dataTask = sessionTaskService.uploadTask(with: request, fileURL: url, completion: completion)
            case .data(let data):
                dataTask = sessionTaskService.uploadTask(with: request, data: data, completion: completion)
            }
            cancelTaskIfNeeded(for: endpoint)
            tasks[endpoint] = dataTask
            return dataTask
        }
        catch {
            completion(.failure(error))
        }
        return nil
    }

    @discardableResult
    public func uploadRequest<E: Endpoint>(_ endpoint: E,
                                           task: UploadTask,
                                           queue: DispatchQueue = .main,
                                           success: @escaping Success<Data>,
                                           failure: Failure? = nil) -> URLSessionDataTask? {
        uploadRequest(endpoint, task: task) { [weak self] result in
            self?.handleResult(result, endpoint: endpoint, queue: queue, success: success, failure: failure)
        }
    }

    @discardableResult
    public func downloadRequest<E: Endpoint>(_ endpoint: E, completion: @escaping ResultCompletion<URL>) -> URLSessionDownloadTask? {
        do {
            let request = try requestFactory.makeRequest(endpoint: endpoint)
            let task = sessionTaskService.downloadTask(with: request, completion: completion)
            cancelTaskIfNeeded(for: endpoint)
            tasks[endpoint] = task
            return task
        }
        catch {
            completion(.failure(error))
            return nil
        }
    }

    @discardableResult
    public func downloadRequest<E: Endpoint>(_ endpoint: E,
                                             queue: DispatchQueue = .main,
                                             success: @escaping Success<URL>,
                                             failure: Failure? = nil) -> URLSessionDownloadTask? {
        downloadRequest(endpoint) { [weak self] result in
            self?.handleResult(result, endpoint: endpoint, queue: queue, success: success, failure: failure)
        }
    }

    private func handleResult<Response: Decodable, E: Endpoint>(_ result: Result<Response, Error>,
                                                                endpoint: E,
                                                                queue: DispatchQueue = .main,
                                                                success: @escaping (Success<Response>),
                                                                failure: Failure?) {
        queue.async {
            switch result {
            case let .success(response):
                success(response)
            case var .failure(error):
                self.handle(&error, for: endpoint)
                failure?(error)
            }
        }
    }

    private func handleResult<Response: Decodable, E: Endpoint>(_ result: Result<Response, Error>,
                                                                endpoint: E,
                                                                queue: DispatchQueue = .main,
                                                                completion: @escaping (ResultCompletion<Response>)) {
        queue.async {
            switch result {
            case let .success(response):
                completion(.success(response))
            case var .failure(error):
                self.handle(&error, for: endpoint)
                completion(.failure(error))
            }
        }
    }

    private func handle<E: Endpoint>(_ error: inout Error, for endpoint: E) {
        errorHandlers.forEach { errorHandler in
            errorHandler.handle(error: &error, endpoint: endpoint)
        }
    }

    private func cancelTaskIfNeeded<E: Endpoint>(for endpoint: E) {
        guard endpoint.automaticTaskCancelling else {
            return
        }
        tasks[endpoint]?.cancel()
        tasks[endpoint] = nil
    }
}
