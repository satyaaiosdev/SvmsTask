//
//  ViewController.swift
//  SvmsTask
//
//  Created by Satyaa Akana on 03/11/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tblView:UITableView!
    
    let cellIdentifier = "TableViewCell"
    var viewModel = SiteViewModel()
    var isLoading: Bool = false
    var pageNo: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        getSiteItems(paginate: true)
    }
    
    func registerNib() {
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tblView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
    
    func getSiteItems(pageNo: Int = 1, paginate: Bool = false) {
        if paginate {
            isLoading = true
        }
        let model = SiteRequestModel(page: pageNo)
        viewModel.getSites(model: model) { done, msg in
            DispatchQueue.main.async {
                self.tblView.tableFooterView = UIView()
                if done {
                    if paginate {
                        sleep(2)
                        self.isLoading = false
                    }
                    self.pageNo += 1
                    self.tblView.reloadData()
                }else{
                    print(msg ?? "")
                }
            }
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TableViewCell
        cell.configure(item: viewModel.items[indexPath.row])
        return cell
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard !isLoading else { return }
        if position > (self.tblView.contentSize.height - 100 - scrollView.frame.size.height) {
            tblView.tableFooterView = FooterSpinner()
            self.getSiteItems(pageNo: pageNo)
        }
    }
}

extension UIViewController {
    func FooterSpinner() -> UIView{
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: 40))
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.color = .orange
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        footerView.backgroundColor = .black.withAlphaComponent(0.4)
        return footerView
    }
}
