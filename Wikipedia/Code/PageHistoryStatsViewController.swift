import UIKit

class PageHistoryStatsViewController: UIViewController {
    private let pageTitle: String
    private let locale: Locale
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pageTitleLabel: UILabel!
    @IBOutlet private weak var statsLabel: UILabel!

    @IBOutlet private weak var sparklineView: WMFSparklineView!
    private lazy var visibleSparklineViewWidthConstraint = sparklineView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.4)
    private lazy var hiddenSparklineViewWidthConstraint = sparklineView.widthAnchor.constraint(equalToConstant: 0)

    @IBOutlet private weak var separator: UIView!

    @IBOutlet private weak var detailedStatsContainerView: UIView!
    private lazy var detailedStatsViewController = PageHistoryDetailedStatsViewController()

    var editCountsGroupedByType: EditCountsGroupedByType? {
        didSet {
            detailedStatsViewController.editCountsGroupedByType = editCountsGroupedByType
        }
    }

    var timeseriesOfEditsCounts: [NSNumber] = [] {
        didSet {
            if timeseriesOfEditsCounts.isEmpty != sparklineView.isHidden {
                setSparklineViewHidden(timeseriesOfEditsCounts.isEmpty)
            }
            setViewHidden(sparklineView, hidden: timeseriesOfEditsCounts.isEmpty)
            sparklineView.dataValues = timeseriesOfEditsCounts
            sparklineView.updateMinAndMaxFromDataValues()
        }
    }

    var theme = Theme.standard

    private var isFirstLayoutPass = true

    required init(pageTitle: String, locale: Locale = Locale.current) {
        self.pageTitle = pageTitle
        self.locale = locale
        super.init(nibName: "PageHistoryStatsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setSparklineViewHidden(_ hidden: Bool) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.sparklineView.isHidden = hidden
            self.visibleSparklineViewWidthConstraint.isActive = !hidden
            self.hiddenSparklineViewWidthConstraint.isActive = hidden
            self.sparklineView.alpha = hidden ? 0 : 1
            self.view.setNeedsLayout()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        statsLabel.isHidden = true
        setSparklineViewHidden(false)

        titleLabel.text = WMFLocalizedString("page-history-revision-history-title", value: "Revision history", comment: "Title for revision history view").uppercased(with: locale)
        pageTitleLabel.text = pageTitle

        sparklineView.dataValues = [NSNumber.init(value: 1), NSNumber.init(value: 2), NSNumber.init(value: 3)]
        sparklineView.showsVerticalGridlines = true
        sparklineView.updateMinAndMaxFromDataValues()

        wmf_add(childController: detailedStatsViewController, andConstrainToEdgesOfContainerView: detailedStatsContainerView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard isFirstLayoutPass else {
            return
        }
        titleLabel.font = UIFont.wmf_font(.semiboldSubheadline, compatibleWithTraitCollection: traitCollection)
        pageTitleLabel.font = UIFont.wmf_font(.boldTitle1, compatibleWithTraitCollection: traitCollection)
        statsLabel.font = UIFont.wmf_font(.subheadline, compatibleWithTraitCollection: traitCollection)

        isFirstLayoutPass = false
    }
}

extension PageHistoryStatsViewController: Themeable {
    func apply(theme: Theme) {
        guard viewIfLoaded != nil else {
            self.theme = theme
            return
        }
        view.backgroundColor = theme.colors.paperBackground
        titleLabel.textColor = theme.colors.secondaryText
        pageTitleLabel.textColor = theme.colors.primaryText
        statsLabel.textColor = theme.colors.accent
        separator.backgroundColor = theme.colors.border
        detailedStatsViewController.apply(theme: theme)
    }
}
