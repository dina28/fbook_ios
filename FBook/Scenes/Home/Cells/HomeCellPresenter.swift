//
//  HomeCellPresenter.swift
//  FBook
//
//  Created by Ban Nguyen Ngoc on 9/8/17.
//  Copyright (c) 2017 Framgia. All rights reserved.
//

import UIKit

protocol HomeCellView: class {
    func displayConfigurator(_ configurator: HomeCellConfigurator?)
    func refreshBooks()
}

protocol HomeCellPresenterDelegate: class {
    func didSelectBook(_ book: Book)
}

protocol HomeCellPresenter {
    func loadCell()
    func configure(collectionView: UICollectionView)
}

class HomeCellPresenterImplementation: NSObject {

    fileprivate weak var view: HomeCellView?
    fileprivate let books: [Book]
    fileprivate weak var delegate: HomeCellPresenterDelegate?

    init(view: HomeCellView?, books: [Book], delegate: HomeCellPresenterDelegate?) {
        self.view = view
        self.books = books
        self.delegate = delegate
    }

    fileprivate func configBookCell(bookCellView: BookCellView, atIndex index: Int) {
        let configurator = BookCellConfiguratorImplementation(book: books[index])
        bookCellView.displayConfigurator(configurator)
    }
}

extension HomeCellPresenterImplementation: HomeCellPresenter {

    func configure(collectionView: UICollectionView) {
        collectionView.registerNibCell(type: BookCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func loadCell() {
        view?.refreshBooks()
    }

}

extension HomeCellPresenterImplementation: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: collectionView.frame.size.height - 20.0)
    }

}

extension HomeCellPresenterImplementation: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableNibCell(type: BookCollectionViewCell.self,
                atIndex: indexPath) else {
            return UICollectionViewCell()
        }
        configBookCell(bookCellView: cell, atIndex: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectBook(books[indexPath.row])
    }

}