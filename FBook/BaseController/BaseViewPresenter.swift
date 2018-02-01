//
//  BaseViewPresenter.swift
//  FBook
//
//  Created by Ban Nguyen Ngoc on 9/12/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import UIKit

protocol BaseView: class {
}

protocol BasePresenter {
    func dismiss()
}

class BasePresenterImplementation {

    fileprivate weak var view: BaseView?
    fileprivate let router: BaseViewRouter?

    init(view: BaseView?, router: BaseViewRouter?) {
        self.view = view
        self.router = router
    }

}

extension BasePresenterImplementation: BasePresenter {
    func dismiss() {
        router?.dismiss()
    }
}
