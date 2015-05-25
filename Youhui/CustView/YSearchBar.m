//
//  YSearchBar.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "YSearchBar.h"
#import "UIView+Addition.h"
#import "NSString+Addition.h"

@interface YSearchBar()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField * textField;
@property (strong, nonatomic) UIButton * cancelButton;
@property (strong, nonatomic) UIImageView *searchIcon;
@property (strong, nonatomic) UIActivityIndicatorView * activityIndicatorView;
@property (strong, nonatomic) UIImageView *inputBackgroundView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (assign, nonatomic) YSearchBarState state;

@end

@implementation YSearchBar

- (id)initWithType:(YSearchBarType)type
{
    self = [self init];
    if (self) {
        self.searchBarType = type;
        return self;
    }
    return nil;
}

- (id)init
{
//    self = [[NSBundle mainBundle] loadNibNamed:@"YSearchBar" owner:self options:nil][0];
    self=[super init];
    if (self) {
        [self initializeFields];
        self.searchBarType = YSearchBarTypeWithCancelButton;
        self.state = YSearchBarFinish;
        return self;
    }
    return nil;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self initializeFields];
        self.searchBarType=YSearchBarTypeWithCancelButton;
        self.state=YSearchBarFinish;
        return self;
    }
    return nil;
}

-(void)initializeFields
{
    self.backgroundImageView=[[UIImageView alloc]init];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"ic_nav_bg"]];
    
    [self addSubview:self.backgroundImageView];
    
    self.inputBackgroundView=[[UIImageView alloc]init];
    [self.inputBackgroundView setImage:[[UIImage imageNamed:@"Home_Search_Inputbg"] stretchableImageWithLeftCapWidth:50 topCapHeight:0]];
    
    [self addSubview:self.inputBackgroundView];
    
    self.searchIcon=[[UIImageView alloc] init];
    [self.searchIcon setImage:[UIImage imageNamed:@"Home_Icon"]];
    [self addSubview:self.searchIcon];
    
    self.textField=[[UITextField alloc]init];
    [self.textField setFont:[UIFont systemFontOfSize:14.0]];
    [self.textField setDelegate:self];
    [self.textField setReturnKeyType:UIReturnKeySearch];
    
    [self addSubview:self.textField];
    
    self.activityIndicatorView=[[UIActivityIndicatorView alloc] init];
    [self addSubview:self.activityIndicatorView];
    
    self.cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel_Btn"] forState:UIControlStateNormal];
    [self.cancelButton setFont:[UIFont systemFontOfSize:13.0f]];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    [self reAdjustLayout];
}

- (void)setPlacehoder:(NSString *)placehoder
{
    _placehoder = placehoder;
    _textField.placeholder = placehoder;
    _textField.font=[UIFont systemFontOfSize:13.0f];
}

- (void)setText:(NSString *)text
{
    _textField.text = text;
}

- (NSString *)text
{
    return _textField.text;
}

- (void)setBackground:(UIImage *)background
{
    _background = background;
    self.backgroundImageView.image = background;
}

- (void)cancelButtonClicked:(UIButton *)cancelBtn
{
    [self.textField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.textField.width += 70;
        self.inputBackgroundView.width += 70;
        self.cancelButton.left += 70;
    } completion:^(BOOL finished) {
    }];
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

- (void)cancelEditing
{
    [self.textField resignFirstResponder];
}

- (void)beginEditting
{
    [self.textField becomeFirstResponder];
    self.state = YSearchBarStateSearch;
}

- (void)showCancelButton
{
    if (self.cancelButton.left > self.frame.size.width) {
        self.searchBarType = YSearchBarStateSearch;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.textField.width -= 70;
            self.inputBackgroundView.width -= 70;
            self.cancelButton.left -= 70;
        }];
    }
}

#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Todo
    if (self.cancelButton.left > self.frame.size.width) {
        self.searchBarType = YSearchBarStateSearch;
        
        [UIView animateWithDuration:0.3 animations:^{
            textField.width -= 70;
            self.inputBackgroundView.width -= 70;
            self.cancelButton.left -= 70;
        } completion:^(BOOL finished) {
        }];
        if ([self.delegate respondsToSelector:@selector(ySearchBarTextDidBeginEditing:)]) {
            [self.delegate ySearchBarTextDidBeginEditing:self];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text == nil || textField.text.length == 0) {
        return NO;
    }
    
    [textField resignFirstResponder];
    self.searchString = [textField.text trimmedWhitespaceString];
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:searchString:)]) {
        [self.delegate searchBarSearchButtonClicked:self searchString:self.searchString];
    }
    
    return YES;
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [self.backgroundImageView setFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    [self.inputBackgroundView setFrame:CGRectMake(5, 5, self.frame.size.width-10, 34)];
    [self.textField setFrame:CGRectMake(45, 5, self.frame.size.width-65, 34)];
    [self.searchIcon setFrame:CGRectMake(19, 13, 18, 18)];
    [self.activityIndicatorView setFrame:CGRectMake(0, 0, 0, 0)];
    [self.cancelButton setFrame:CGRectMake(self.frame.size.width+5, 5, 60, 34)];
}


@end
