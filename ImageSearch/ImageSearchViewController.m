//
//  ViewController.m
//  ImageSearch
//
//  Created by VA Gautham  on 30-6-14.
//  Copyright (c) 2014 Gautham. All rights reserved.
//

#import "ImageSearchViewController.h"
#import "ImagePreviewCell.h"
#import "PageNumberView.h"
#import "Toast+UIView.h"

@interface ImageSearchViewController ()

@end

#define UserDefaults_historyArray @"UserDefaults_historyArray"
#define Key_Index @"Key_index"
#define Key_Image @"Key_image"

@implementation ImageSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setting up the array for images and search history
    self.googleReponseArray = [[NSMutableArray alloc] init];
    [self.googleReponseArray removeAllObjects];
    
    self.googleImageArray = [[NSMutableArray alloc] init];
    [self.googleImageArray removeAllObjects];
    
    [self.historyTableView setHidden:TRUE];
    [self.resultCollectionView setHidden:TRUE];
    
    self.historyArray = [[NSMutableArray alloc] init];
    [self.historyArray removeAllObjects];
    [self.historyArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaults_historyArray]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GoogleAPI
//Google Search API to fetch image and store it in a list
- (void)getGoogleImagesForQuery:(NSString*)query withPage:(int)page
{
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    /*
     The image count during search is limited to 60 images
     since a custom URL is used to do the operations.
     Each page has a maximim of 8 images, more images can be
     seen evey time the used scrolls down or taps on the
     load more images button
     */
    
    int firstImageNumber = page * 8;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q=%@&start=%i",query, firstImageNumber]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil error:nil];
    NSError *error;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:
                                 responseData options:NSJSONReadingMutableContainers error:&error];
    if(![[responseDic objectForKey:@"responseData"] isKindOfClass:[NSNull class]])
    {
        NSArray *resultArray = [[responseDic objectForKey:@"responseData"]
                                objectForKey:@"results"];
        // NSString *trimmedString = ;
        for(int i=0;i<[resultArray count];i++)
        {
            NSDictionary *dict = [resultArray objectAtIndex:i];
            NSString *URLString = [dict valueForKey:@"url"];
            [self.googleReponseArray addObject:URLString];
        }
        
        self.page = page + 1;
        
        [self.resultCollectionView setHidden:FALSE];
        [self.resultCollectionView reloadData];
        
    }
    else
    {
        [self.view makeToast:@"Could not load more images"];
    }
}

#pragma mark - Interfacebuilder Action
-(IBAction)loadMoreImages:(id)sender
{
    [self getGoogleImagesForQuery:self.searchBar.text withPage:self.page];
    [self.resultCollectionView scrollRectToVisible:CGRectMake(0, self.resultCollectionView.contentSize.height - self.resultCollectionView.bounds.size.height, self.resultCollectionView.bounds.size.width, self.resultCollectionView.bounds.size.height) animated:YES];
}

#pragma mark - UISearchBar methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.resultCollectionView setHidden:TRUE];
    [self.historyTableView setHidden:FALSE];
    [self.historyTableView reloadData];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.historyTableView setHidden:TRUE];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![self.historyArray containsObject:self.searchBar.text])
    {
        [self.historyArray insertObject:self.searchBar.text atIndex:0];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.historyArray forKey:UserDefaults_historyArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.historyArray removeAllObjects];
        [self.historyArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaults_historyArray]];
    }
    [searchBar resignFirstResponder];
    [self.googleReponseArray removeAllObjects];
    [self.googleImageArray removeAllObjects];
    [self.resultCollectionView reloadData];
    self.page = 1;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 0)];
    [self.resultCollectionView deleteSections:indexSet];
    [self getGoogleImagesForQuery:self.searchBar.text withPage:self.page];
}

#pragma mark - UITableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.historyArray count] > 0)
        return [self.historyArray count];
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([self.historyArray count] == 0)
    {
        [cell.textLabel setText:@"No Search History Available"];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    }
    else
    {
        [cell.textLabel setText:[self.historyArray objectAtIndex:indexPath.row]];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.historyArray count] > 0)
    {
        [self.searchBar setText:[self.historyArray objectAtIndex:indexPath.row]];
        [self.searchBar resignFirstResponder];
        [self.googleReponseArray removeAllObjects];
        [self.googleImageArray removeAllObjects];
        [self.resultCollectionView reloadData];
        self.page = 1;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 0)];
        [self.resultCollectionView deleteSections:indexSet];
        [self getGoogleImagesForQuery:self.searchBar.text withPage:self.page];
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    NSUInteger sections = 1;
    if (self.googleReponseArray.count > 8)
        sections = ceil(self.googleReponseArray.count/8);
    
    return sections;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    
    if (self.googleReponseArray.count > 0)
    {
        if (self.googleReponseArray.count < 8)
            rows = self.googleReponseArray.count;
        else
            rows = 8;
        self.noPicslbl.hidden = TRUE;
    }
    else
    {
        self.noPicslbl.hidden = FALSE;
        rows = 0;
    }
    
    return rows;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PageNumberView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PGView" forIndexPath:indexPath];
        NSString *title = [[NSString alloc]initWithFormat:@"Page #%i", indexPath.section + 1];
        headerView.pageNumberLabel.text = title;
        reusableview = headerView;
    }
    
    return reusableview;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImagePreviewCell *myCell = [collectionView
                                dequeueReusableCellWithReuseIdentifier:@"IPVCell"
                                forIndexPath:indexPath];
    
    myCell.imageView.image = nil;
    [myCell.loadingImageIndicator setHidden:FALSE];
    myCell.imageView.layer.borderWidth = 1;
    myCell.imageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSInteger objectLocaion = section*8 + row;
    UIImage *cellImage = [self getImageAtLocation:[NSString stringWithFormat:@"%d",objectLocaion]];
    
    
    if (!cellImage)
    {
        NSString *urlString = [self.googleReponseArray objectAtIndex:objectLocaion];
        NSLog(@"Object Location & URL : %ld - %@",(long)objectLocaion, urlString);
        [self downloadImageWithURL:[NSURL URLWithString:urlString] atIndex:objectLocaion completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                UIImage *cellImage = [[UIImage alloc] initWithData:data];
                myCell.imageView.image = cellImage;
                [myCell.loadingImageIndicator setHidden:TRUE];
                
                for (NSMutableDictionary *dict in self.googleImageArray)
                {
                    NSString *loc = [dict valueForKey:Key_Index];
                    if ([loc isEqualToString:[NSString stringWithFormat:@"%d",objectLocaion]])
                        [dict setValue:cellImage forKey:Key_Image];
                }
            }
        }];
    }
    else
    {
        myCell.imageView.image = cellImage;
        [myCell.loadingImageIndicator setHidden:TRUE];
    }
    return myCell;
}

-(UIImage *)getImageAtLocation:(NSString *)location
{
    for (NSMutableDictionary *dict in self.googleImageArray)
    {
        NSString *loc = [dict valueForKey:Key_Index];
        if ([loc isEqualToString:location])
        {
            UIImage *image = [dict valueForKey:Key_Image];
            return image;
        }
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:location forKey:Key_Index];
    [self.googleImageArray addObject:dict];
    
    return nil;
}

- (void)downloadImageWithURL:(NSURL *)url atIndex:(NSInteger)index completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, nil);
        }
    }];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height)
    {
        [self getGoogleImagesForQuery:self.searchBar.text withPage:self.page];
    }
}
@end
