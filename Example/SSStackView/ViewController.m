//
//  ViewController.m
//  SSStackView
//
//  Created by Stevenson on 3/9/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "ViewController.h"
#import "SSStackedPageView.h"
#import "UIColor+CatColors.h"

@interface ViewController () <SSStackedViewDelegate>

@property (nonatomic) IBOutlet SSStackedPageView *stackView;
@property (nonatomic) NSMutableArray *views;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stackView.delegate = self;
    self.stackView.pagesHaveShadows = YES;
    self.views = [[NSMutableArray alloc] init];
    for (int i=0;i<25;i++) {
        UIView *thisView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 100.f)];
        [self.views addObject:thisView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)stackView:(SSStackedPageView *)stackView pageForIndex:(NSInteger)index
{
    UIView *thisView = [stackView dequeueReusablePage];
    if (!thisView) {
        thisView = [self.views objectAtIndex:index];
        thisView.backgroundColor = [UIColor getRandomColor];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (NSInteger)numberOfPagesForStackView:(SSStackedPageView *)stackView
{
    return [self.views count];
}

- (void)stackView:(SSStackedPageView *)stackView selectedPageAtIndex:(NSInteger) index selected:(BOOL)selected
{
    NSLog(@"%@ page: %i",selected ? @"selected" : @"deselected", (int)index);
}


@end
