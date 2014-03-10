//
//  SSStackView.m
//  SSStackView
//
//  Created by Stevenson on 3/10/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSStackedPageView.h"

#define OFFSET_TOP 100.f
#define PAGE_PEAK 50.f
#define MINIMUM_ALPHA 0.5f
#define MINIMUM_SCALE 0.9f


@interface SSStackedPageView()

@property (nonatomic) UIScrollView *theScrollView;
@property (nonatomic) NSMutableArray *reusablePages;
@property (nonatomic) UIView *selectedPage;

@end

@implementation SSStackedPageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.delegate) {
        self.pageCount = [self.delegate numberOfPagesForStackView:self];
    }
    
    [self.reusablePages removeAllObjects];
    self.visiblePages = NSMakeRange(0, 0);
    
    for (NSInteger i=0; i < [self.pages count]; i++) {
        [self removePageAtIndex:i];
    }
    [self.pages  removeAllObjects];
    
    for (NSInteger i=0; i<self.pageCount; i++) {
        [self.pages addObject:[NSNull null]];
    }
    
    self.theScrollView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.theScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), MAX(CGRectGetHeight(self.bounds), OFFSET_TOP+self.pageCount * PAGE_PEAK));
    [self addSubview:self.theScrollView];
    
    [self setPageAtOffset:self.theScrollView.contentOffset];
    [self reloadVisiblePages];
}

#pragma mark - setup methods
- (void)setup
{
    self.pageCount = 0;
    
    self.pages = [[NSMutableArray alloc] init];
    self.reusablePages = [[NSMutableArray alloc] init];
    self.visiblePages = NSMakeRange(0, 0);
    
    self.theScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.theScrollView.delegate = self;
    self.theScrollView.backgroundColor = [UIColor clearColor];
    self.theScrollView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - displaying pages
- (void)reloadVisiblePages
{
    CGFloat offset = self.theScrollView.contentOffset.x;
    NSInteger start = self.visiblePages.location;
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    
    for (NSInteger i = start; i < stop; i++) {
        UIView *page = [self.pages objectAtIndex:i];
//        CGFloat yOrigin = CGRectGetMinY(page.frame)+OFFSET_TOP;
//        CGFloat change = (yOrigin >= offset) ? yOrigin-offset : offset-yOrigin;
        
        //nearing off screen animations
        [UIView beginAnimations:@"stackScrolling" context:nil];
        page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
        [UIView commitAnimations];
    }
}

- (void)setPageAtOffset:(CGPoint)offset
{
    if ([self.pages count] > 0 ) {
        CGPoint start = CGPointMake(offset.x - CGRectGetMinX(self.theScrollView.frame), offset.y -(CGRectGetMinY(self.theScrollView.frame)));
        
        CGPoint end = CGPointMake(MAX(0, start.x) + CGRectGetWidth(self.bounds), MAX(OFFSET_TOP, start.y) + CGRectGetHeight(self.bounds));
        
        NSInteger startIndex = 0;
        for (NSInteger i=0; i < [self.pages count]; i++) {
            if (PAGE_PEAK * (i+1) > start.y) {
                startIndex = i;
                break;
            }
        }
        
        NSInteger endIndex = 0;
        for (NSInteger i=0; i < [self.pages count]; i++) {
            if ((PAGE_PEAK * (i+1) < end.y && PAGE_PEAK * (i + 2) >= end.y ) || i+2 == [self.pages count]) {
                endIndex = i + 1;
                break;
            }
        }
        
        startIndex = MAX(startIndex - 1, 0);
        endIndex = MAX(endIndex + 1, [self.pages count] - 1);
        CGFloat pagedLength = endIndex - startIndex + 1;
        
        if (self.visiblePages.location != startIndex || self.visiblePages.length != pagedLength) {
            _visiblePages.location = startIndex;
            _visiblePages.length = pagedLength;
            
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i ++) {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < [self.pages count]; i ++) {
                [self setPageAtIndex:i];
            }
        }
    }
}

- (void)setPageAtIndex:(NSInteger)index
{
    if (index >= 0 && index < [self.pages count]) {
        UIView *page = [self.pages objectAtIndex:index];
        if ((!page || (NSObject*)page == [NSNull null]) && self.delegate) {
            page = [self.delegate stackView:self pageForIndex:index];
            [self.pages replaceObjectAtIndex:index withObject:page];
            page.frame = CGRectMake(0.f, index * PAGE_PEAK, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        }
        
        if (![page superview]) {
            [self.theScrollView addSubview:page];
        }
    }
}

#pragma mark - reuse methods
- (void)enqueueReusablePage:(UIView*)page
{
    [self.reusablePages addObject:page];
}

- (UIView*)dequeueReusablePage
{
    UIView *page = [self.reusablePages lastObject];
    if (page && (NSObject*)page != [NSNull null]) {
        [self.reusablePages removeLastObject];
        return page;
    }
    return nil;
}

- (void)removePageAtIndex:(NSInteger)index
{
    UIView *page = [self.pages objectAtIndex:index];
    if (page && (NSObject*)page != [NSNull null]) {
        page.layer.transform = CATransform3DIdentity;
        [page removeFromSuperview];
        [self enqueueReusablePage:page];
        [self.pages replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

#pragma mark - gesture recognizer
- (void)tapped:(UIGestureRecognizer*)sender
{
    for (int i=0; i < [self.pages count]; i++) {
        UIView *page = [self.pages objectAtIndex:i];
        CGPoint tappedPoint = [sender locationInView:[page superview]];
        CGRect pageTouchFrame = page.frame;
        if ( i+1 < [self.pages count]) {
            pageTouchFrame.size.height = PAGE_PEAK;
        }
        if (CGRectContainsPoint(pageTouchFrame, tappedPoint)) {
            [self.delegate stackView:self selectedPageAtIndex:i];
            break;
        }
    }
}

@end
