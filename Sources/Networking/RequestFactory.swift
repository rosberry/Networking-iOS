//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

open class RequestFactory {

    public let encoder: JSONEncoder

    public init(encoder: JSONEncoder = .init()) {
        self.encoder = encoder
    }

    open func makeRequest<E: Endpoint>(endpoint: E) throws -> URLRequest {
        let endpointURL = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false)
        var body: Data = .init()

        guard let url = components?.url else {
            throw NetworkingError.wrongURL
        }

        var request = URLRequest(url: url)

        for parameter in endpoint.parameters {
            switch parameter {
            case .json(let json):
                let encodable = AnyEncodable(value: json)
                body.append(try encoder.encode(encodable))
            case .url(let values):
                components?.queryItems = values.map { key, value in
                    URLQueryItem(name: key, value: value.description)
                }
            case .data(let data):
                body.append(data)
            case let .multipartFormData(values):
                let boundary = UUID().uuidString
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                body = buildMultipartFormData(boundary: boundary, parameters: values)
            }
        }

        request.httpMethod = endpoint.method.rawValue
        request.httpBody = body

        for header in endpoint.headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }

    private func buildMultipartFormData(boundary: String, parameters: [String: Any]) -> Data {
        var data = Data()

        for (key, value) in parameters {
            if let stringConvertibleValue = value as? CustomStringConvertible {
                data.appendString(convertFormField(named: key,
                                                   value: stringConvertibleValue.description,
                                                   using: boundary))
            }
            else {
                if let multipartFormInformation = value as? MultipartFormDataWrapper {
                    let stringTimestamp = String(Date().timeIntervalSince1970)
                    let formFileData = convertFileData(fieldName: key,
                                                       fileName: stringTimestamp + "." + multipartFormInformation.contentType,
                                                       mimeType: multipartFormInformation.contentType,
                                                       fileData: multipartFormInformation.data,
                                                       using: boundary)
                    data.append(formFileData)
                }
            }
        }
        return data
    }

    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        var data = Data()

        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        append(data)
    }
}
