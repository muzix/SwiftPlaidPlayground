import Foundation

enum JobApplyError: Error {
  case unknown
  case invalidRequest
  case invalidResponseData
  case statusCode(code: Int)
}

struct InterviewRequest: Encodable {
  let name: String
  let email: String
  let resume: String?
  let phone: String?
  let github: String?
  let twitter: String?
  let website: String?
  let location: String?
  let favoriteCandy: String?
  let superpower: String?

  enum CodingKeys: String, CodingKey {
    case name
    case email
    case resume
    case phone
    case github
    case twitter
    case website
    case location
    case favoriteCandy = "favorite_candy"
    case superpower
  }
}

typealias CompletionType = ((Result<String, Error>) -> Void)

func post<T: Encodable>(model: T, to api: String, completion: CompletionType?) {
  let encoder = JSONEncoder()
  guard let jsonData = try? encoder.encode(model) else {
    completion?(.failure(JobApplyError.invalidRequest))
    return
  }

  // debug
  let jsonText = String(data: jsonData, encoding: .utf8)
  print("Request data: \(jsonText)")

  var request = URLRequest(url: URL(string: api)!)
  request.httpMethod = "POST"
  request.httpBody = jsonData
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  request.addValue("application/json", forHTTPHeaderField: "Accept")

  let session = URLSession.shared
  let task = session.dataTask(with: request) { (data, response, error) in
    guard let data = data,
      let response = response as? HTTPURLResponse,
      error == nil else {
        completion?(.failure(error ?? JobApplyError.unknown))
        return
    }

    guard (200...299) ~= response.statusCode else {
      completion?(.failure(JobApplyError.statusCode(code: response.statusCode)))
      return
    }

    guard let responseText = String(data: data, encoding: .utf8) else {
      completion?(.failure(JobApplyError.invalidResponseData))
      return
    }

    completion?(.success(responseText))
  }

  task.resume()
}

func apply(completion: CompletionType?) {
  let request = InterviewRequest(name: "name",
                                 email: "email",
                                 resume: nil,
                                 phone: nil,
                                 github: nil,
                                 twitter: nil,
                                 website: nil,
                                 location: nil,
                                 favoriteCandy: "chocolate",
                                 superpower: nil)

  post(model: request, to: "http://api_url.com", completion: completion)
}

apply() { result in
  switch result {
  case .success(let response):
    print("Result: \(response)")
  case .failure(let error):
    print(error.localizedDescription)
  }
}




