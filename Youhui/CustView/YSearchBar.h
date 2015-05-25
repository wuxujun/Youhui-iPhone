//
//  YSearchBar.h
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExtention.h"

typedef enum{
    YSearchBarStateSearch,
    YSearchBarStateSearching,
    YSearchBarFinish
}YSearchBarState;

typedef enum{
    YSearchBarTypeWithCancelButton = 1,
    YSearchBarTypeWithoutCancelButton//Default
}YSearchBarType;

@class YSearchBar;

@protocol YSearchBarDelegate <NSObject>

@optional
//Editing Text
- (void)ySearchBar:(YSearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)ySearchBarTextDidBeginEditing:(YSearchBar *)searchBar;
- (void)ySearchBarTextDidEndEditing:(YSearchBar *)searchBar;


//Clicking Buttons
- (void)searchBarCancelButtonClicked:(YSearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(YSearchBar *)searchBar searchString:(NSString *)searchString;

@end

@interface YSearchBar : UIViewExtention

@property (weak, nonatomic) id<YSearchBarDelegate> delegate;
@property (assign, nonatomic) YSearchBarType searchBarType;
@property (strong, nonatomic) NSString * placehoder;
@property (strong, nonatomic) UIImage * background;
@property (strong, nonatomic) NSString * searchString;
@property (strong, nonatomic) NSString * text;

- (id)initWithType:(YSearchBarType)type;
-(id)initWithFrame:(CGRect)frame;

- (IBAction)cancelButtonClicked:(UIButton *)cancelBtn;

- (void)cancelEditing;
- (void)beginEditting;

- (void)showCancelButton;

@end
