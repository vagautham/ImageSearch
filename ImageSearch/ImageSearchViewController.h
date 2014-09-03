//
//  ViewController.h
//  ImageSearch
//
//  Created by VA Gautham  on 30-6-14.
//  Copyright (c) 2014 Gautham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSearchViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UIScrollViewDelegate>

@property(nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic) IBOutlet UITableView *historyTableView;
@property(nonatomic) NSMutableArray *historyArray;

@property(nonatomic) IBOutlet UICollectionView *resultCollectionView;
@property(nonatomic) NSMutableArray *googleReponseArray;
@property(nonatomic) NSMutableArray *googleImageArray;
@property(nonatomic) IBOutlet UILabel *noPicslbl;

@property(nonatomic) int page;

-(IBAction)loadMoreImages:(id)sender;
@end
