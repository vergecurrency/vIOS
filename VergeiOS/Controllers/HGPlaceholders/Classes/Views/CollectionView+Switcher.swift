import UIKit

// MARK: - PlaceholdersSwitcher implementation for CollectionView
extension CollectionView: PlaceholdersSwitcher {

    // Generic helper to switch to a placeholder safely
    private func switchToPlaceholder(_ dataSourceProvider: () -> PlaceholderDataSourceDelegate?, errorText: String) {
        guard let dataSource = dataSourceProvider() else {
            assertionFailure(errorText)
            return
        }
        self.switchTo(dataSource: dataSource as? UICollectionViewDataSource, delegate: (dataSource as! UICollectionViewDelegate))
    }

    // MARK: - Protocol methods
    public func showLoadingPlaceholder() {
        switchToPlaceholder({ placeholdersProvider.loadingDataSource() },
                            errorText: ErrorText.loadingPlaceholder.text)
    }

    public func showNoResultsPlaceholder() {
        switchToPlaceholder({ placeholdersProvider.noResultsDataSource() },
                            errorText: ErrorText.noResultPlaceholder.text)
    }

    public func showErrorPlaceholder() {
        switchToPlaceholder({ placeholdersProvider.errorDataSource() },
                            errorText: ErrorText.errorPlaceholder.text)
    }

    public func showNoConnectionPlaceholder() {
        switchToPlaceholder({ placeholdersProvider.noConnectionDataSource() },
                            errorText: ErrorText.noConnectionPlaceholder.text)
    }

    public func showCustomPlaceholder(with key: PlaceholderKey) {
        switchToPlaceholder({ placeholdersProvider.dataSourceAndDelegate(with: key) },
                            errorText: ErrorText.customPlaceholder(key: key.value).text)
    }

    public func showDefault() {
        self.switchTo(dataSource: defaultDataSource, delegate: defaultDelegate)
    }
}


