//
//  AwesomeProject
//

import Foundation

struct InternalError: LocalizedError {
    var errorDescription: String?
}

class RequestSender: IRequestSender {
    private let queue = DispatchQueue(label: "com.app.queue", attributes: .concurrent)
    private var internalTasks: [UUID: URLSessionDataTask] = [:]
    private var tasks: [UUID: URLSessionDataTask] {
        get {
            var result = [UUID: URLSessionDataTask]()
            queue.sync { result = self.internalTasks }
            return result
        }
        set {
            queue.async(flags: .barrier) { self.internalTasks = newValue }
        }
    }

    let session = URLSession.shared

    func send<Parser>(requestConfig config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void) {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.failure(InternalError(errorDescription: "url string can't be parsed to URL")))
            return
        }

        let id = config.request.uniqId

        let task = session.dataTask(with: urlRequest) { (data: Data?, _: URLResponse?, error: Error?) in
            self.addTask(nil, id: id)
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let data = data,
                let parsedModel: Parser.Model = config.parser.parse(data: data) else {
                completionHandler(.failure(InternalError(errorDescription: "received data can't be parsed")))
                return
            }
            
            completionHandler(.success(parsedModel))
        }

        addTask(task, id: id)
        task.resume()
    }

    func cancel(id: UUID) {
        guard internalTasks[id]?.state == .running else {
            return
        }
        internalTasks[id]?.cancel()
        addTask(nil, id: id)
    }

    private func addTask(_ task: URLSessionDataTask?, id: UUID) {
        queue.async(flags: .barrier) { self.internalTasks[id] = task }
    }
}
