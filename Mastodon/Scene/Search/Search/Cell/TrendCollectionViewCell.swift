//
//  TrendCollectionViewCell.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-18.
//

import UIKit
import Combine
import MetaTextKit
import MastodonAsset
import MastodonUI

final class TrendCollectionViewCell: UICollectionViewCell {
    
    var _disposeBag = Set<AnyCancellable>()
    
    let trendView = TrendView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension TrendCollectionViewCell {
    
    private func _init() {
        ThemeService.shared.currentTheme
            .map { $0.secondarySystemGroupedBackgroundColor }
            .sink { [weak self] backgroundColor in
                guard let self = self else { return }
                self.backgroundColor = backgroundColor
                self.setNeedsUpdateConfiguration()
            }
            .store(in: &_disposeBag)
        
        trendView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trendView)
        NSLayoutConstraint.activate([
            trendView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trendView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trendView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trendView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColorTransformer = .init { _ in
            if state.isHighlighted || state.isSelected {
                return ThemeService.shared.currentTheme.value.tableViewCellSelectionBackgroundColor
            }
            return ThemeService.shared.currentTheme.value.secondarySystemGroupedBackgroundColor
        }
        self.backgroundConfiguration = backgroundConfiguration
    }
    
}

