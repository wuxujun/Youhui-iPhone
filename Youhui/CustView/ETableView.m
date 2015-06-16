//
//  ETableView.m
//  Youhui
//
//  Created by xujunwu on 15/4/1.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "ETableView.h"
#import "ETableViewCell.h"
#import "ETableViewCellIndicator.h"
#import <objc/runtime.h>

static NSString * const kIsExpandedKey = @"isExpanded";
static NSString * const kSubrowsKey = @"subrowsCount";
CGFloat const kDefaultCellHeight = 44.0f;

#pragma mark - ETableView

@interface ETableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSMutableDictionary *expandableCells;


- (NSInteger)numberOfExpandedSubrowsInSection:(NSInteger)section;

- (NSIndexPath *)correspondingIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)setExpanded:(BOOL)isExpanded forCellAtIndexPath:(NSIndexPath *)indexPath;

- (IBAction)expandableButtonTouched:(id)sender event:(id)event;

- (NSInteger)numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ETableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _shouldExpandOnlyOneCell = NO;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _shouldExpandOnlyOneCell = NO;
    }
    
    return self;
}

- (void)setETableViewDelegate:(id<ETableViewDelegate>)ETableViewDelegate
{
    self.dataSource = self;
    self.delegate = self;
    
    [self setSeparatorColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
    
    if (ETableViewDelegate)
        _ETableViewDelegate = ETableViewDelegate;
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    [super setSeparatorColor:separatorColor];
    [ETableViewCellIndicator setIndicatorColor:separatorColor];
}

- (NSMutableDictionary *)expandableCells
{
    if (!_expandableCells)
    {
        _expandableCells = [NSMutableDictionary dictionary];
        
        NSInteger numberOfSections = [self.ETableViewDelegate numberOfSectionsInTableView:self];
        for (NSInteger section = 0; section < numberOfSections; section++)
        {
            NSInteger numberOfRowsInSection = [self.ETableViewDelegate tableView:self
                                                             numberOfRowsInSection:section];
            
            NSMutableArray *rows = [NSMutableArray array];
            for (NSInteger row = 0; row < numberOfRowsInSection; row++)
            {
                NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                NSInteger numberOfSubrows = [self.ETableViewDelegate tableView:self
                                                      numberOfSubRowsAtIndexPath:rowIndexPath];
                BOOL isExpandedInitially = NO;
                if ([self.ETableViewDelegate respondsToSelector:@selector(tableView:shouldExpandSubRowsOfCellAtIndexPath:)])
                {
                    isExpandedInitially = [self.ETableViewDelegate tableView:self shouldExpandSubRowsOfCellAtIndexPath:rowIndexPath];
                }
                
                NSMutableDictionary *rowInfo = [NSMutableDictionary dictionaryWithObjects:@[@(isExpandedInitially), @(numberOfSubrows)]
                                                                                  forKeys:@[kIsExpandedKey, kSubrowsKey]];
                
                [rows addObject:rowInfo];
            }
            
            [_expandableCells setObject:rows forKey:@(section)];
        }
    }
    
    return _expandableCells;
}

- (void)refreshData
{
    self.expandableCells = nil;
    
    [super reloadData];
}

- (void)refreshDataWithScrollingToIndexPath:(NSIndexPath *)indexPath
{
    [self refreshData];
    
    if (indexPath.section < [self numberOfSections] && indexPath.row < [self numberOfRowsInSection:indexPath.section])
    {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - UITableViewDataSource

#pragma mark - Required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_ETableViewDelegate tableView:tableView numberOfRowsInSection:section] + [self numberOfExpandedSubrowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
    if ([correspondingIndexPath subRow] == 0)
    {
        ETableViewCell *expandableCell = (ETableViewCell *)[_ETableViewDelegate tableView:tableView cellForRowAtIndexPath:correspondingIndexPath];
        if ([expandableCell respondsToSelector:@selector(setSeparatorInset:)])
        {
            expandableCell.separatorInset = UIEdgeInsetsZero;
        }
        
        BOOL isExpanded = [self.expandableCells[@(correspondingIndexPath.section)][correspondingIndexPath.row][kIsExpandedKey] boolValue];
        
        if (expandableCell.isExpandable)
        {
            expandableCell.expanded = isExpanded;
            
            UIButton *expandableButton = (UIButton *)expandableCell.accessoryView;
            [expandableButton addTarget:tableView
                                 action:@selector(expandableButtonTouched:event:)
                       forControlEvents:UIControlEventTouchUpInside];
            
            if (isExpanded)
            {
                expandableCell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
            }
            else
            {
                if ([expandableCell containsIndicatorView])
                {
                    [expandableCell removeIndicatorView];
                }
            }
        }
        else
        {
            expandableCell.expanded = NO;
            expandableCell.accessoryView = nil;
            [expandableCell removeIndicatorView];
        }
        
        return expandableCell;
    }
    else
    {
        UITableViewCell *cell = [_ETableViewDelegate tableView:(ETableView *)tableView cellForSubRowAtIndexPath:correspondingIndexPath];
        cell.backgroundColor = [self separatorColor];
        cell.backgroundView = nil;
        cell.indentationLevel = 2;
        
        return cell;
    }
}

#pragma mark - Optional

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_ETableViewDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [_ETableViewDelegate numberOfSectionsInTableView:tableView];
    }
    
    return 1;
}

/*
 *  Uncomment the implementations of the required methods.
 */

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
//        return [_ETableViewDelegate tableView:tableView titleForHeaderInSection:section];
//
//    return nil;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:titleForFooterInSection:)])
//        return [_ETableViewDelegate tableView:tableView titleForFooterInSection:section];
//
//    return nil;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView canEditRowAtIndexPath:indexPath];
//
//    return NO;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView canMoveRowAtIndexPath:indexPath];
//
//    return NO;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
//        [_ETableViewDelegate sectionIndexTitlesForTableView:tableView];
//
//    return nil;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)])
//        [_ETableViewDelegate tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
//
//    return 0;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
//        [_ETableViewDelegate tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
//}

#pragma mark - UITableViewDelegate

#pragma mark - Optional

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ETableViewCell *cell = (ETableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(isExpandable)])
    {
        if (cell.isExpandable)
        {
            cell.expanded = !cell.isExpanded;
            
            NSIndexPath *_indexPath = indexPath;
            NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            if (cell.isExpanded && _shouldExpandOnlyOneCell)
            {
                _indexPath = correspondingIndexPath;
                [self collapseCurrentlyExpandedIndexPaths];
            }
            
            if (_indexPath)
            {
                NSInteger numberOfSubRows = [self numberOfSubRowsAtIndexPath:correspondingIndexPath];
                
                NSMutableArray *expandedIndexPaths = [NSMutableArray array];
                NSInteger row = _indexPath.row;
                NSInteger section = _indexPath.section;
                
                for (NSInteger index = 1; index <= numberOfSubRows; index++)
                {
                    NSIndexPath *expIndexPath = [NSIndexPath indexPathForRow:row+index inSection:section];
                    [expandedIndexPaths addObject:expIndexPath];
                }
                
                if (cell.isExpanded)
                {
                    [self setExpanded:YES forCellAtIndexPath:correspondingIndexPath];
                    [self insertRowsAtIndexPaths:expandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
                else
                {
                    [self setExpanded:NO forCellAtIndexPath:correspondingIndexPath];
                    [self deleteRowsAtIndexPaths:expandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
                
                [cell accessoryViewAnimation];
            }
        }
        
        if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            
            if (correspondingIndexPath.subRow == 0)
            {
                [_ETableViewDelegate tableView:tableView didSelectRowAtIndexPath:correspondingIndexPath];
            }
            else
            {
                [_ETableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
            }
        }
    }
    else
    {
        if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didSelectSubRowAtIndexPath:)])
        {
            NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
            
            [_ETableViewDelegate tableView:self didSelectSubRowAtIndexPath:correspondingIndexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
        [_ETableViewDelegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

/*
 *  Uncomment the implementations of the required methods.
 */

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)])
//        [_ETableViewDelegate tableView:tableView willDisplayHeaderView:view forSection:section];
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)])
//        [_ETableViewDelegate tableView:tableView willDisplayFooterView:view forSection:section];
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)])
//        [_ETableViewDelegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
//}
//
//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)])
//        [_ETableViewDelegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *correspondingIndexPath = [self correspondingIndexPathForRowAtIndexPath:indexPath];
    if ([correspondingIndexPath subRow] == 0)
    {
        if ([_ETableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
        {
            return [_ETableViewDelegate tableView:tableView heightForRowAtIndexPath:correspondingIndexPath];
        }
        
        return kDefaultCellHeight;
    }
    else
    {
        if ([_ETableViewDelegate respondsToSelector:@selector(tableView:heightForSubRowAtIndexPath:)])
        {
            return [_ETableViewDelegate tableView:self heightForSubRowAtIndexPath:correspondingIndexPath];
        }
        
        return kDefaultCellHeight;
    }
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
//        [_ETableViewDelegate tableView:tableView heightForHeaderInSection:section];
//
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)])
//        [_ETableViewDelegate tableView:tableView heightForFooterInSection:section];
//
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
//
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)])
//        [_ETableViewDelegate tableView:tableView estimatedHeightForHeaderInSection:section];
//
//    return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)])
//        [_ETableViewDelegate tableView:tableView estimatedHeightForFooterInSection:section];
//
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
//        [_ETableViewDelegate tableView:tableView viewForHeaderInSection:section];
//
//    return nil;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)])
//        [_ETableViewDelegate tableView:tableView viewForFooterInSection:section];
//
//    return nil;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
//
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView willSelectRowAtIndexPath:indexPath];
//
//    return nil;
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
//
//    return nil;
//}
//
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
//
//    return UITableViewCellEditingStyleNone;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
//
//    return nil;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
//
//    return NO;
//}
//
//- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
//}
//
//- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
//}
//
//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
//        [_ETableViewDelegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
//
//    return nil;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
//
//    return 0;
//}
//
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)])
//        [_ETableViewDelegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
//
//    return NO;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)])
//        [_ETableViewDelegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
//
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if ([_ETableViewDelegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)])
//        [_ETableViewDelegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
//}

#pragma mark - ETableViewUtils

- (NSInteger)numberOfExpandedSubrowsInSection:(NSInteger)section
{
    NSInteger totalExpandedSubrows = 0;
    
    NSArray *rows = self.expandableCells[@(section)];
    for (id row in rows)
    {
        if ([row[kIsExpandedKey] boolValue] == YES)
        {
            totalExpandedSubrows += [row[kSubrowsKey] integerValue];
        }
    }
    
    return totalExpandedSubrows;
}

- (IBAction)expandableButtonTouched:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:currentTouchPosition];
    
    if (indexPath)
        [self tableView:self accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (NSInteger)numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [_ETableViewDelegate tableView:self numberOfSubRowsAtIndexPath:indexPath];
}

- (NSIndexPath *)correspondingIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block NSIndexPath *correspondingIndexPath = nil;
    __block NSInteger expandedSubrows = 0;
    
    NSArray *rows = self.expandableCells[@(indexPath.section)];
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
        NSInteger numberOfSubrows = 0;
        if (isExpanded)
        {
            numberOfSubrows = [obj[kSubrowsKey] integerValue];
        }
        
        NSInteger subrow = indexPath.row - expandedSubrows - idx;
        if (subrow > numberOfSubrows)
        {
            expandedSubrows += numberOfSubrows;
        }
        else
        {
            correspondingIndexPath = [NSIndexPath indexPathForSubRow:subrow
                                                               inRow:idx
                                                           inSection:indexPath.section];
            
            *stop = YES;
        }
    }];
    
    return correspondingIndexPath;
}

- (void)setExpanded:(BOOL)isExpanded forCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *cellInfo = self.expandableCells[@(indexPath.section)][indexPath.row];
    [cellInfo setObject:@(isExpanded) forKey:kIsExpandedKey];
}

- (void)collapseCurrentlyExpandedIndexPaths
{
    NSMutableArray *totalExpandedIndexPaths = [NSMutableArray array];
    NSMutableArray *totalExpandableIndexPaths = [NSMutableArray array];
    
    [self.expandableCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        __block NSInteger totalExpandedSubrows = 0;
        
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSInteger currentRow = idx + totalExpandedSubrows;
            
            BOOL isExpanded = [obj[kIsExpandedKey] boolValue];
            if (isExpanded)
            {
                NSInteger expandedSubrows = [obj[kSubrowsKey] integerValue];
                for (NSInteger index = 1; index <= expandedSubrows; index++)
                {
                    NSIndexPath *expandedIndexPath = [NSIndexPath indexPathForRow:currentRow + index
                                                                        inSection:[key integerValue]];
                    [totalExpandedIndexPaths addObject:expandedIndexPath];
                }
                
                [obj setObject:@(NO) forKey:kIsExpandedKey];
                totalExpandedSubrows += expandedSubrows;
                
                [totalExpandableIndexPaths addObject:[NSIndexPath indexPathForRow:currentRow inSection:[key integerValue]]];
            }
        }];
    }];
    
    for (NSIndexPath *indexPath in totalExpandableIndexPaths)
    {
        ETableViewCell *cell = (ETableViewCell *)[self cellForRowAtIndexPath:indexPath];
        cell.expanded = NO;
        [cell accessoryViewAnimation];
    }
    
    [self deleteRowsAtIndexPaths:totalExpandedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
}

@end

#pragma mark - NSIndexPath (ETableView)

static void *SubRowObjectKey;

@implementation NSIndexPath (ETableView)

@dynamic subRow;

- (NSInteger)subRow
{
    id subRowObj = objc_getAssociatedObject(self, SubRowObjectKey);
    return [subRowObj integerValue];
}

- (void)setSubRow:(NSInteger)subRow
{
    id subRowObj = [NSNumber numberWithInteger:subRow];
    objc_setAssociatedObject(self, SubRowObjectKey, subRowObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSIndexPath *)indexPathForSubRow:(NSInteger)subrow inRow:(NSInteger)row inSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    indexPath.subRow = subrow;
    
    return indexPath;
}

@end
