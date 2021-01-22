//
//  Created by Evgeny Schwarzkopf on 21.01.2021.
//

import Foundation
import UIKit
import Networking

final class MultipartViewController: UIViewController {

    private let multipartFormService: MultipartFormService = MultipartFormServiceImp()

    private lazy var requestButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save Djamshytky", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: #selector(requestButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "djamshytka")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(requestButton)
        view.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        requestButton.sizeToFit()
        requestButton.center = .init(x: view.center.x,
                                     y: 100)

        imageView.frame.size = .init(width: 200, height: 200)
        imageView.center = .init(x: view.center.x,
                                 y: 250)
    }

    @objc private func requestButtonPressed() {
        guard let image = imageView.image else {
            return
        }

        multipartFormService.upload(image) { data in
            do {
                let user = try JSONSerialization.jsonObject(with: data)
                print(user)
            }
            catch let error {
                print(error.localizedDescription.debugDescription)
            }
        } failure: { error in
            print(error.localizedDescription)
        }
    }
}
