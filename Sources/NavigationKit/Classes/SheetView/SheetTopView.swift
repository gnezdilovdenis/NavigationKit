//
//  SheetTopView.swift
//  
//
//  Created by Polina Osina on 20.08.2021.
//

import UIKit
import DesignKit

final class SheetTopView: UIView {

    private enum Metrics {

        static let indicatorSize: CGSize = .init(width: 52, height: 6)
        static let indicatorCornerRadius: CGFloat = indicatorSize.height / 2

        static let cornerRadius: CGFloat = 16
        static let topOffset: CGFloat = 8
    }

    // MARK: Public properties

    // MARK: Internal properties

    // MARK: Private properties

    private let indicator: UIView = .init().apply {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Color.Background.popup.color
        $0.layer.cornerRadius = Metrics.indicatorCornerRadius
        $0.setSize(Metrics.indicatorSize)
        $0.isAccessibilityElement = true
        $0.accessibilityIdentifier = "slider"
    }

    // MARK: Init & Override

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private methods

private extension SheetTopView {

    func setup() {
        backgroundColor = .white
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = Metrics.cornerRadius
    }

    func makeConstraints() {
        addSubview(indicator)
        indicator.pinToSuperview(edges: [
            .top(Metrics.topOffset),
            .centerX
        ])
    }
}
