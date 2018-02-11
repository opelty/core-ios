//
//  HomeViewController.swift
//  blacklist
//
//  Created by Mateo Olaya Bernal on 2/2/18.
//  Copyright © 2018 Opelty's Open Source Projects. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, ViewControllerProtocol {
    typealias P = HomePresenter
    typealias R = HomeRouter

    var presenter: HomePresenter!
    var router: HomeRouter?

    fileprivate var tableViewTopConstraintConstant: CGFloat = 0.0

    // IBOutlets
    @IBOutlet weak var lendingAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gradientContainerView: UIView!
    @IBOutlet weak var tableViewHeaderView: UIView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var maximumUpcomingHuggingConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Let's configure the presenter

        configure { (context) -> (presenter: HomePresenter, router: HomeRouter?) in
            let presenter = HomePresenter()
            let router = HomeRouter(viewController: context)

            return (presenter: presenter, router: router)
        }

        configure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Add a bounce effect to the first cell
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if let tableView = self?.tableView, tableView.visibleCells.count > 0 {
                if let cell = self?.tableView.visibleCells.first as? UpcomingTableViewCell {
                    cell.bounce()
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }

    override func viewDidLayoutSubviews() {
        // Let's create the gradient layer
        let gradient = CAGradientLayer()
        gradient.frame = gradientContainerView.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.9, 1.0]

        gradientContainerView.layer.mask = gradient

        super.viewDidLayoutSubviews()
    }

    func configure() {
        configureTableView()

        self.automaticallyAdjustsScrollViewInsets = false
    }
}

// MARK: - TableView DataSource

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func configureTableView() {
        // Let's configure the tableView
        let upcomingTableViewCellNib = UINib(nibName: UpcomingTableViewCell.identifier, bundle: nil)
        tableView.register(upcomingTableViewCellNib, forCellReuseIdentifier: UpcomingTableViewCell.identifier)

        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension

        tableViewTopConstraintConstant = tableViewTopConstraint.constant

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UpcomingTableViewCell.identifier,
            for: indexPath
        ) as! UpcomingTableViewCell

        cell.registerHandler { [weak self] (cell, action) in
            self?.didPerform(action: action, in: cell)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? UpcomingTableViewCell {
            cell.colapse()

            // TODO: Go to the detail view, sending the cell context
            router?.loanDetails(with: 2)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? UpcomingTableViewCell {
            cell.colapse()
        }
    }

}

// MARK: - Actions Handler

extension HomeViewController {
    func didPerform(action: UpcomingTableViewCell.UpcomingAction, in cell: UpcomingTableViewCell) {
        switch action {
        case .phone:
            // TODO: get the phone number from the model

            presenter.call(to: "+573206532663")
            break
        case .check:
            router?.loanDetails(with: 2)
            break
        }
    }
}

// MARK: - ScrollView Delegate

extension HomeViewController {
    fileprivate func performMovement(for scrollView: UIScrollView, restartLayout: Bool) {
        guard !restartLayout else {
            tableViewTopConstraint.constant = tableViewTopConstraintConstant
            tableViewHeaderView.alpha = 1.0

            return
        }

        let y = tableViewTopConstraintConstant - scrollView.contentOffset.y
        let alpha = y / tableViewTopConstraintConstant

        tableViewTopConstraint.constant = y > 0 ? y : 0
        tableViewHeaderView.alpha = alpha.percentage
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isBouncing {
            performMovement(for: scrollView, restartLayout: false)
        } else {
            performMovement(for: scrollView, restartLayout: true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !scrollView.isBouncing {
            performMovement(for: scrollView, restartLayout: false)
        } else {
            performMovement(for: scrollView, restartLayout: true)
        }
    }
}

// MARK: - IBActions

// MARK: - View interface

extension HomeViewController: HomeView {
    func go(to: String, sender: Any?) {

    }

    func doSomethingUI() {
        print("Hello World says presenter to the UI")
    }
}
