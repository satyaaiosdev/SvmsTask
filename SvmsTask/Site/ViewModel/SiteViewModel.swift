//
//  SiteViewModel.swift
//  SvmsTask
//
//  Created by Satyaa Akana on 03/11/22.
//

import Foundation

protocol SiteViewModelImpl: ObservableObject {
    func getSites(model: SiteRequestModel, completion: @escaping ((Bool, String?) -> Void))
}

final class SiteViewModel: SiteViewModelImpl {
    
    @Published private(set) var items: [Item] = [Item]()
    
    func getSites(model: SiteRequestModel, completion: @escaping ((Bool, String?) -> Void)) {
        APIServiceImpl.shared.fetch(request: SiteRequest(params: model.asDictionary).asURLRequest()) { (result: Result<SiteResponseModel, NetworkRequestError>) in
            switch result {
            case .success(let success):
                if let items = success.items {
                    self.items.append(contentsOf: items)
                    completion(true, "Data found")
                }else{
                    completion(false, "Data not found")
                }
            case .failure(let error):
                
                completion(false, error.localizedString)
            }
        }
    }
}
    
