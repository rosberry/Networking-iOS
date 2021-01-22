//
//  Copyright © 2020 Rosberry. All rights reserved.
//
import UIKit
import Networking

final class ExampleViewController: UIViewController {

    private let jokesService: JokesService = JokesServiceImp.shared

    private lazy var jokeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private lazy var fetchJokeButton: UIButton = {
        let view = UIButton()
        view.setTitle("Fetch joke", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(fetchJokeButtonPressed), for: .touchUpInside)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        return view
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var presentButton: UIButton = {
        let button = UIButton()
        button.setTitle("Saving Djamshytky?", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: #selector(presentButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(fetchJokeButton)
        view.addSubview(jokeLabel)
        view.addSubview(activityIndicatorView)
        view.addSubview(presentButton)
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fetchJokeButton.sizeToFit()
        fetchJokeButton.center = .init(x: view.center.x,
                                       y: view.center.y - fetchJokeButton.frame.size.height - 16)
        jokeLabel.center = view.center
        jokeLabel.bounds = .init(origin: .zero, size: jokeLabel.sizeThatFits(view.bounds.size))

        presentButton.sizeToFit()
        presentButton.center = .init(x: view.center.x,
                                     y: 100)

        activityIndicatorView.sizeToFit()
        activityIndicatorView.center = view.center
    }

    @objc private func presentButtonPressed() {
        let multipartViewController = MultipartViewController()
        present(multipartViewController, animated: true)
    }

    @objc private func fetchJokeButtonPressed() {
        jokeLabel.isHidden = true
        activityIndicatorView.startAnimating()
        jokesService.loadRandomJoke(category: "IT") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(joke):
                    self?.jokeLabel.text = "\(joke.setup) - \(joke.punchline)"
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                    self?.jokeLabel.isHidden = false
                    self?.activityIndicatorView.stopAnimating()
                case let .failure(error):
                    guard (error as? GeneralRequestError) != GeneralRequestError.cancelled else {
                        return
                    }
                    print(error.localizedDescription)
                    self?.jokeLabel.text = error.localizedDescription
                    self?.jokeLabel.isHidden = false
                    self?.activityIndicatorView.stopAnimating()
                }
            }
        }
    }
}
