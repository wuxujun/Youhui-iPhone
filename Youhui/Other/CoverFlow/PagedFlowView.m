//
//  PagedFlowView.m
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "PagedFlowView.h"
#import <QuartzCore/QuartzCore.h>

#define kTagOffset   50

@interface PagedFlowView ()
{
    BOOL    _needRefresh;
}
@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;
@end

@implementation PagedFlowView
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize pageControl;
@synthesize minimumPageAlpha = _minimumPageAlpha;
@synthesize minimumPageScale = _minimumPageScale;
@synthesize orientation;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize defaultImageView=_defaultImageView;


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
-(void)handleTapGesture:(UIGestureRecognizer*)gestureRecognizer{
    NSInteger tappedIndex = 0;
    CGPoint locationInScrollView = [gestureRecognizer locationInView:_scrollView];
    if (CGRectContainsPoint(_scrollView.bounds, locationInScrollView)) {
        tappedIndex = _currentPageIndex;
        if ([self.delegate respondsToSelector:@selector(flowView:didTapPageAtIndex:)]) {
            [self.delegate flowView:self didTapPageAtIndex:tappedIndex];
        }
    }
}

- (void)initialize{
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapRecognizer];
    
    _needsReload = YES;
    _needRefresh=YES;
    _pageSize = self.bounds.size;
    _pageCount = 0;
    _currentPageIndex = 0;
    
    _minimumPageAlpha = 1.0;
    _minimumPageScale = 1.0;
    
    _visibleRange = NSMakeRange(0, 0);
    
    _reusableCells = [[NSMutableArray alloc] initWithCapacity:0];
    _inUseCells = [[NSMutableArray alloc] initWithCapacity:0];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _boxblurImageView=[[UIImageView alloc]initWithFrame:self.bounds];
    [_boxblurImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    _boxblurImageView.backgroundColor=[UIColor clearColor];
    /*由于UIScrollView在滚动之后会调用自己的layoutSubviews以及父View的layoutSubviews
     这里为了避免scrollview滚动带来自己layoutSubviews的调用,所以给scrollView加了一层父View
     */
    _superViewOfScrollView = [[UIView alloc] initWithFrame:self.bounds];
    [_superViewOfScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_superViewOfScrollView setBackgroundColor:[UIColor clearColor]];
    [_superViewOfScrollView addSubview:_boxblurImageView];
    [_superViewOfScrollView addSubview:_scrollView];
    [self addSubview:_superViewOfScrollView];
}

- (void)dealloc{
    _scrollView.delegate = nil;
}

- (void)queueReusableCell:(UIView *)cell{
    if (cell) {
        [_reusableCells addObject:cell];
    }
}


- (void)refreshVisibleCellAppearance{
    
    if (_minimumPageAlpha == 1.0 && _minimumPageScale == 1.0) {
        return;//无需更新
    }
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:{
            CGFloat offset = _scrollView.contentOffset.x;
            
            for (int i = _visibleRange.location; i < _visibleRange.location + _visibleRange.length; i++) {
                UIView *cell = [_inUseCells objectAtIndex:i];
                CGFloat origin = cell.frame.origin.x;
                CGFloat delta = fabs(origin - offset);
                
                CGRect originCellFrame=CGRectMake(_pageSize.width*i, 0, _pageSize.width, _pageSize.height);
                if (delta < _pageSize.width) {
                    cell.alpha = 1 - (delta / _pageSize.width) * (1 - _minimumPageAlpha);
                    CGFloat inset =(_pageSize.width* (1 - _minimumPageScale))*(delta/_pageSize.width)/2.0;
                    cell.frame =UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(inset, inset, inset, inset));
                    
                } else {
                    CGFloat inset = _pageSize.width * (1 - _minimumPageScale) / 2.0 ;
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(inset, inset, inset, inset));
                }
            }
            break;
        }
        case PagedFlowViewOrientationVertical:{
            CGFloat offset = _scrollView.contentOffset.y;
            
            for (int i = _visibleRange.location; i < _visibleRange.location + _visibleRange.length; i++) {
                UIView *cell = [_inUseCells objectAtIndex:i];
                CGFloat origin = cell.frame.origin.y;
                CGFloat delta = fabs(origin - offset);
                
                CGRect originCellFrame = CGRectMake(0, _pageSize.height * i, _pageSize.width, _pageSize.height);//如果没有缩小效果的情况下的本该的Frame
                
                if (delta < _pageSize.height) {
                    cell.alpha = 1 - (delta / _pageSize.height) * (1 - _minimumPageAlpha);
                    
                    CGFloat inset = (_pageSize.height * (1 - _minimumPageScale)) * (delta / _pageSize.height)/2.0;
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(inset, inset, inset, inset));
                } else {
                    cell.alpha = _minimumPageAlpha;
                    CGFloat inset = _pageSize.height * (1 - _minimumPageScale) / 2.0 ;
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(inset, inset, inset, inset));
                }
            }
        }
        default:
            break;
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (_needsReload) {
        //如果需要重新加载数据，则需要清空相关数据全部重新加载
        [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        //重置pageCount
        if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInFlowView:)]) {
            _pageCount = [_dataSource numberOfPagesInFlowView:self];
        }
        
        //重置pageWidth
        if (_dataSource && [_dataSource respondsToSelector:@selector(sizeForPageInFlowView:)]) {
            _pageSize = [_dataSource sizeForPageInFlowView:self];
        }
        
        [_reusableCells removeAllObjects];
        [_inUseCells removeAllObjects];
        _visibleRange = NSMakeRange(0, 0);
        
        if (_pageCount==0&&_defaultImageView) {
            self.defaultImageView.frame=CGRectMake(0, 0, _pageSize.width, _pageSize.height);
            [_scrollView addSubview:self.defaultImageView];
        }
        
        // 重置_scrollView的contentSize
        NSInteger  offset = 1;
        _scrollView.scrollEnabled = YES;
        if (_pageCount <= 1) {
            offset = 0;
            _scrollView.scrollEnabled = NO;
        }
        
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal://横向
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width *3,_pageSize.height);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                _scrollView.contentOffset=CGPointMake(_pageSize.width*offset, 0);
                
                break;
            case PagedFlowViewOrientationVertical:{
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width ,_pageSize.height * 3);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                _scrollView.contentOffset=CGPointMake(0, _pageSize.height*offset);
                break;
            }
            default:
                break;
        }
    }
    if (_delegate&&_pageCount>0) {
        [_delegate didReloadBlurData:_boxblurImageView cellForPageAtIndex:0];
    }
    [self loadRequiredItems];
    
    [self refreshVisibleCellAppearance];//更新各个可见Cell的显示外貌
    
}

-(void)loadRequiredItems
{
    if (_pageCount==0) {
        return;
    }
    if (_pageCount == 1) {
        UIView  *cell = [_dataSource flowView:self cellForPageAtIndex:0];
        cell.tag = 0 + kTagOffset;
        cell.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
        if (cell){
            [_inUseCells addObject:cell];
            [_scrollView addSubview:cell];
        }
        return;
    }
    
    [self initVisibleCellAppearance];
    [self initReuseCell];
    
}

- (void)initVisibleCellAppearance
{
    _visibleRange = NSMakeRange(0, 3);
    
    NSInteger  index = 0;
    index = (_currentPageIndex == 0)?_pageCount-1:_currentPageIndex-1;
    UIView  *cell = [_dataSource flowView:self cellForPageAtIndex:index];
    cell.tag = index + kTagOffset;
    cell.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
    if (cell){
        [_inUseCells addObject:cell];
        [_scrollView addSubview:cell];
    }
    
    index = _currentPageIndex;
    UIView  *cell1 = [_dataSource flowView:self cellForPageAtIndex:index];
    cell1.tag = index + kTagOffset;
    cell1.frame = CGRectMake(_pageSize.width, 0, _pageSize.width, _pageSize.height);
    if (cell1){
        [_inUseCells addObject:cell1];
        [_scrollView addSubview:cell1];
    }
    
    index = (_currentPageIndex == _pageCount-1)?0:_currentPageIndex+1;
    UIView  *cell2 = [_dataSource flowView:self cellForPageAtIndex:index];
    cell2.tag = index + kTagOffset;
    cell2.frame = CGRectMake(_pageSize.width*2, 0, _pageSize.width, _pageSize.height);
    if (cell2){
        [_inUseCells addObject:cell2];
        [_scrollView addSubview:cell2];
    }
    
}

- (void)initReuseCell
{
    if (_pageCount == 2) {
        NSInteger  index = (_currentPageIndex==0)?0:1;
        UIView  *cell1 = [_dataSource flowView:self cellForPageAtIndex:index];
        cell1.tag = index + kTagOffset;
        cell1.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
        if (cell1){
            [_reusableCells addObject:cell1];
        }
        
        index = (_currentPageIndex==0)?0:1;
        UIView  *cell2 =  [_dataSource flowView:self cellForPageAtIndex:index];
        cell2.tag = index + kTagOffset;
        cell2.frame = CGRectMake(_pageSize.width*2, 0, _pageSize.width, _pageSize.height);
        if (cell2){
            [_reusableCells addObject:cell2];
        }
    }else if (_pageCount >2){
        NSInteger  i = 0;
        if (_currentPageIndex == 0) {
            i  = _pageCount-2;
        }else if ((_currentPageIndex-1 == 0)) {
            i  = _pageCount-1;
        }else{
            i = _currentPageIndex-2;
        }
        
        UIView  *cell1 = [_dataSource flowView:self cellForPageAtIndex:i];
        cell1.tag = i + kTagOffset;
        cell1.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
        if (cell1){
            [_reusableCells insertObject:cell1 atIndex:0];
        }
        
        NSInteger  index = 0;
        if (_currentPageIndex == _pageCount-1) {
            index = 1;
        }else if ((_currentPageIndex+1 == _pageCount-1)) {
            index = 0;
        }else{
            index = _currentPageIndex +2;
        }
        
        UIView  *cell2 = [_dataSource flowView:self cellForPageAtIndex:index];
        cell2.tag = index + kTagOffset;
        cell2.frame = CGRectMake(_pageSize.width*2, 0, _pageSize.width, _pageSize.height);
        if (cell2){
            [_reusableCells addObject:cell2];
        }
    }
    
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView API

- (void)reloadData
{
    _needsReload = YES;
    
    [self setNeedsLayout];
}


- (UIView *)dequeueReusableCell{
    return nil;
    
    UIView *cell = [_reusableCells lastObject];
    if (cell)
    {
        [_reusableCells removeLastObject];
    }
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x;
        newPoint.y = point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y;
        if ([_scrollView pointInside:newPoint withEvent:event]) {
            return [_scrollView hitTest:newPoint withEvent:event];
        }
        
        return _scrollView;
    }
    
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollView Delegate

- (UIView *)cellForItemAtCurrentIndex:(NSInteger)currentIndex
{
    UIView  *cell = nil;
    if ([_inUseCells count] == 1) {
        cell = [_inUseCells objectAtIndex:0];
    }else if ([_inUseCells count]>1){
        cell = [_inUseCells objectAtIndex:1];
    }
    return cell;
}


- (void)reloadDataForScrollView:(PagedDirectionE)direction
{
    if (direction == PagedDirectionPrevious) {
        
        UIView  *oldItem = [_inUseCells objectAtIndex:0];
        [_inUseCells removeObjectIdenticalTo:oldItem];
        
        for (NSInteger  i=0; i<[_inUseCells count]; i++) {
            UIView  *v = [_inUseCells objectAtIndex:i];
            v.frame = CGRectMake(_pageSize.width*i, 0, _pageSize.width, _pageSize.height);
        }
        
        UIView *newItem = [_reusableCells lastObject];
        [_reusableCells removeObjectIdenticalTo:newItem];
        [_scrollView addSubview:newItem];
        [_inUseCells addObject:newItem];
        
        oldItem.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
        [_reusableCells insertObject:oldItem atIndex:0];
        [oldItem removeFromSuperview];
        
        UIView  *reuseCell = [_reusableCells lastObject];
        
        NSInteger  index = 0;
        if (_currentPageIndex == _pageCount-1) {
            index = 1;
        }else if ((_currentPageIndex+1 == _pageCount-1)) {
            index = 0;
        }else{
            index = _currentPageIndex +2;
        }
        reuseCell.tag = index + kTagOffset;
        reuseCell.frame = CGRectMake(_pageSize.width*2, 0, _pageSize.width, _pageSize.height);
        [_delegate didReloadData:reuseCell cellForPageAtIndex:index];
        [_delegate didReloadBlurData:_boxblurImageView cellForPageAtIndex:index];
    }else if(direction == PagedDirectionDown){
        
        UIView  *oldItem = [_inUseCells lastObject];
        [_inUseCells removeObjectIdenticalTo:oldItem];
        
        for (NSInteger  i=0; i<[_inUseCells count]; i++) {
            UIView  *v = [_inUseCells objectAtIndex:i];
            v.frame = CGRectMake(_pageSize.width*(i+1), 0, _pageSize.width, _pageSize.height);
        }
        
        UIView *newItem = [_reusableCells objectAtIndex:0];
        [_reusableCells removeObjectIdenticalTo:newItem];
        [_scrollView addSubview:newItem];
        [_inUseCells insertObject:newItem atIndex:0];
        
        oldItem.frame = CGRectMake(_pageSize.width*2, 0, _pageSize.width, _pageSize.height);
        [_reusableCells addObject:oldItem];
        [oldItem removeFromSuperview];
        
        UIView  *reuseCell = [_reusableCells objectAtIndex:0];
        NSInteger  i = 0;
        if (_currentPageIndex == 0) {
            i  = _pageCount-2;
        }else if ((_currentPageIndex-1 == 0)) {
            i  = _pageCount-1;
        }else{
            i = _currentPageIndex-2;
        }
        reuseCell.tag = i + kTagOffset;
        reuseCell.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
        [_delegate didReloadData:reuseCell cellForPageAtIndex:i];
        [_delegate didReloadBlurData:_boxblurImageView cellForPageAtIndex:i];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_pageCount<=1) {
        return;
    }
    [self refreshVisibleCellAppearance];
}


- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value < 0) value = _pageCount-1;                   // value＝1为第一张，value = 0为前面一张
    if(value >= _pageCount) value = 0;
    
    return value;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //如果有PageControl，计算出当前页码，并对pageControl进行更新
    
    int x=scrollView.contentOffset.x;
    int y=scrollView.contentOffset.y;
    

    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:
        {
            if (x>=(2*_scrollView.bounds.size.width)) {
                _currentPageIndex=[self validPageValue:_currentPageIndex+1];
                [self reloadDataForScrollView:PagedDirectionPrevious];
            }
            if (x<=0) {
                _currentPageIndex=[self validPageValue:_currentPageIndex-1];
                [self reloadDataForScrollView:PagedDirectionDown];
            }
        }
            break;
        case PagedFlowViewOrientationVertical:
        {
            if (y>=2*(_scrollView.bounds.size.height)) {
                _currentPageIndex=[self validPageValue:_currentPageIndex-1];
                [self reloadDataForScrollView:PagedDirectionPrevious];
            }
            if (y<=0) {
                _currentPageIndex=[self validPageValue:_currentPageIndex-1];
                [self reloadDataForScrollView:PagedDirectionDown];
            }
        }
            break;
        default:
            break;
    }
    
    if (pageControl && [pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        [pageControl setCurrentPage:_currentPageIndex];
    }
    
    if ([_delegate respondsToSelector:@selector(flowView:didScrollToPageAtIndex:)]) {
        [_delegate flowView:self didScrollToPageAtIndex:_currentPageIndex];
    }
    
    if (_orientation==PagedFlowViewOrientationHorizontal) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0) animated:NO];
    }
    if (_orientation==PagedFlowViewOrientationVertical) {
        [_scrollView setContentOffset:CGPointMake(0, _scrollView.bounds.size.height) animated:NO];
    }
    
}

-(void)scrollToNextPage
{
    UIView *newItem = [_reusableCells lastObject];
    newItem.frame = CGRectMake(_pageSize.width*3, 0, _pageSize.width, _pageSize.height);
    [_reusableCells removeObjectIdenticalTo:newItem];
    [_scrollView addSubview:newItem];
    [_inUseCells addObject:newItem];
    
    UIView  *oldItem = [_inUseCells objectAtIndex:0];
    
    _currentPageIndex = [self validPageValue:_currentPageIndex+1];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         for (NSInteger  i=0; i<[_inUseCells count]; i++) {
                             UIView  *v = [_inUseCells objectAtIndex:i];
                             v.frame = CGRectMake(_pageSize.width*(i-1), 0, _pageSize.width, _pageSize.height);
                         }
                         [_inUseCells removeObjectAtIndex:0];
                         [self refreshVisibleCellAppearance];
                         
                     } completion:^(BOOL finished) {
                         
                         oldItem.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                         [_reusableCells insertObject:oldItem atIndex:0];
                         [oldItem removeFromSuperview];
                         
                         UIView  *reuseCell = [_reusableCells lastObject];
                         
                         NSInteger  index = 0;
                         if (_currentPageIndex == _pageCount-1) {
                             index = 1;
                         }else if ((_currentPageIndex+1 == _pageCount-1)) {
                             index = 0;
                         }else{
                             index = _currentPageIndex +2;
                         }
                         reuseCell.tag = index + kTagOffset;
                         reuseCell.frame = CGRectMake(_pageSize.width*2, 0, _pageSize.width, _pageSize.height);
                         [_delegate didReloadData:reuseCell cellForPageAtIndex:index];
                         [_delegate didReloadBlurData:_boxblurImageView cellForPageAtIndex:index];
                         
                     }];
}

@end