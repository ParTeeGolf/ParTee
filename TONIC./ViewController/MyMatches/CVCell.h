//
//  CVCell.h
//  CollectionViewExample
//
//  Created by Tim on 9/5/12.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblUserName;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewUser;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewCup;

@end
