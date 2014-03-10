//
//  SSStackView.h
//  SSStackView
//
//  Created by Stevenson on 3/10/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SSStackViewDelegate;

@interface SSStackedPageView : UIView<UIScrollViewDelegate>

@property (nonatomic) id<SSStackViewDelegate> delegate;
@property (nonatomic) NSInteger pageCount;
@property (nonatomic) NSMutableArray *pages;
@property (nonatomic) NSRange visiblePages;

- (UIView*)dequeueReusablePage;

@end

@protocol SSStackViewDelegate


- (UIView*)stackView:(SSStackedPageView *)stackView pageForIndex:(NSInteger)index;

- (NSInteger)numberOfPagesForStackView:(SSStackedPageView *)stackView;

- (void)stackView:(SSStackedPageView *)stackView selectedPageAtIndex:(NSInteger) index;

@end