//
//  NowPlayingVC.swift
//  The10-Shreef
//
//  Created by Shreef Hagazi  on 2/12/19.
//  Copyright © 2019 Shreef Hagazi . All rights reserved.
//

import UIKit
import TMDBSwift
import YouTubePlayer
import AnimatedCollectionViewLayout

class NowPlayingVC: UIViewController {
    @IBOutlet weak var video:           YouTubePlayerView!
    @IBOutlet weak var collectionView:  ScrollingPagesView!
    @IBOutlet weak var reviewView:      UITextView!

    var videos:     [VideosMDB] = []
    var nowPlaying: [MovieMDB]  = []
    let interactor              = Interactor()
    var reuseIdentifier         = "poster"

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.title = "In Theaters"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.backgroundColor = UIColor.red.cgColor
        self.collectionView.dataSource  = self
        self.collectionView.delegate    = self

        let nib = UINib(nibName: "PosterCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)

        fetchMovies { (client, movies) in
            self.collectionView.reloadData()
        }

    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        snapToNearestCell(collectionView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestCell(collectionView)
    }

    func snapToNearestCell(_ collectionView: UICollectionView) {
        for i in 0..<collectionView.numberOfItems(inSection: 0) {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemWithSpaceWidth  = layout.itemSize.width + layout.minimumLineSpacing
                let itemWidth           = layout.itemSize.width
                if collectionView.contentOffset.x < CGFloat(i) * itemWithSpaceWidth + (itemWidth / 2) {
                    let indexPath = IndexPath(item: i, section: 0)
                    UIView.animate(withDuration: 0.2) {
                        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    }
                    break
                }
            }
        }
    }

    func fetchMovies(completionHandler: @escaping ((ClientReturn?, [MovieMDB]?) -> Void)){
        interactor.fetchNowPlaying { (client, movies) in
            if let movies = movies {
                for i in 0...9 {
                    self.nowPlaying.append(movies[i])
                }
            }
            completionHandler(client, movies)
        }
    }

}


extension NowPlayingVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.nowPlaying.count > 10 {
            return 10
        }
        else {
            return self.nowPlaying.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PosterCell
//        let title = nowPlaying[indexPath.row].title
        //        cell.configure(with: UIImage
        cell.clipsToBounds = false
        cell.backgroundColor = .blue
        return cell

    }
}

