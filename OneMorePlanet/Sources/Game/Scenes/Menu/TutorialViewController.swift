//
//  TutorialViewController.swift
//  OneMorePlanet
//
//  Created by Ana Paula Kessler  on 09/02/22.
//

import UIKit

class TutorialViewController: UIViewController {
    
    private lazy var titleStackView: UIStackView = {
        let title = UILabel()
        title.text = "HOW TO PLAY"
        title.font = UIFont(name: Fonts.AldoTheApache.regular.name, size: 35)
        title.textColor = UIColor.white
        title.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [title])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .top
        stack.spacing = LayoutMetrics.titleStackViewSpacing
        
        return stack
    }()
    
    private lazy var tutorial1: UIStackView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.tutorial1))
        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 15)
        label.text = "HOLD ANYWHERE"
        label.textColor = .white
        label.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            label
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        
        return stack
    }()
    
    private lazy var tutorial2: UIStackView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.tutorial2))
        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 15)
        label.text = "USE THE GRAVITATIONAL ORBITS"
        label.textColor = .white
        label.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            label
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        
        return stack
    }()
    
    private lazy var tutorial3: UIStackView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.tutorial3))
        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 15)
        label.text = "DON'T HIT THE PLANET DIRECTLY"
        label.textColor = .white
        label.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            label
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        
        return stack
    }()
    
    private lazy var checkButton: UIButton = {
        let symbol = UIImage(systemName: "checkmark.circle.fill")
        let button = UIButton()
        button.setImage(symbol, for: .normal)
        let configuration = UIImage.SymbolConfiguration(pointSize: 38.0, weight: .medium)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupHierarchy()
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        let constraints = [
            titleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            tutorial1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorial1.topAnchor.constraint(equalTo: titleStackView.bottomAnchor,
                                           constant: 20),
            
            tutorial2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorial2.topAnchor.constraint(equalTo: tutorial1.bottomAnchor,
                                           constant: LayoutMetrics.distanceBetweenImages),
            
            tutorial3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorial3.topAnchor.constraint(equalTo: tutorial2.bottomAnchor,
                                           constant: LayoutMetrics.distanceBetweenImages),
            
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -20),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(asset: Assets.Colors.spaceBackground)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        
    }
    
    private func setupHierarchy() {
        view.addSubview(tutorial1)
        view.addSubview(tutorial2)
        view.addSubview(tutorial3)
        view.addSubview(titleStackView)
        view.addSubview(checkButton)
    }
    
    private enum LayoutMetrics {
        static let titleFontSize: CGFloat = 35
        static let titleStackViewSpacing: CGFloat = 30
        static let distanceBetweenImages: CGFloat = 20
        
    }
    
    @objc private func checkButtonTapped() {
        print("volta pro menu")
    }
    
}
