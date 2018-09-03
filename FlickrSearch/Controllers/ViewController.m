//
//  ViewController.m
//  FlickrSearch
//
//  Created by Indicode on 9/1/18.
//  Copyright © 2018 Laalsa. All rights reserved.
//

#import "ViewController.h"
#import "flickrCollectionViewCell.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *flickrSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *flickrCollectionView;

@property(nonatomic, strong)NSMutableArray *arrPhotos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _arrPhotos = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self btnSearchClicked:searchBar.text];
}

- (void)btnSearchClicked:(NSString*)strSearch{
    
    NSString * encodedString = [[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&                                                                                format=json&nojsoncallback=1&safe_search=1&text=%@", strSearch] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:encodedString]];
    
    //create the Method "GET"
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          if(httpResponse.statusCode == 200)
                                          {
                                              [self.arrPhotos removeAllObjects];
                                              NSError *parseError = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                              NSLog(@"The response is - %@",responseDictionary);
                                              [self.arrPhotos addObjectsFromArray:responseDictionary[@"photos"][@"photo"]];
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self.flickrCollectionView reloadData];
                                              });
                                          }
                                          else
                                          {
                                              NSLog(@"Error %@",[error localizedDescription]);
                                          }
                                      }];
    [dataTask resume];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    flickrCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flickrCellID" forIndexPath:indexPath];
    
    dispatch_queue_t queue = dispatch_queue_create("photoList", NULL);
    
    // Start getting the data in the background
    dispatch_async(queue, ^{
        
        NSDictionary *dictData = self.arrPhotos[indexPath.item];
        
        NSString *strImageUrl = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@.jpg",dictData[@"farm"],dictData[@"server"],dictData[@"id"],dictData[@"secret"]];
        
        
//        NSData* photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:object.photoURL]];
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strImageUrl]]];
        
        // Once we get the data, update the UI on the main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.flickrImageView.image = image;
        });
    });
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        return CGSizeMake(collectionView.bounds.size.width / 6.2, collectionView.bounds.size.height / 8);
    }
    return CGSizeMake(collectionView.bounds.size.width / 3.2, collectionView.bounds.size.height / 6);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _arrPhotos.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
