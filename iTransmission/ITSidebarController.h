//
//  ITSidebarController.h
//  iTransmission
//
//  Created by Mike Chen on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kITSidebarSlidingAnimationDuration 0.2f

@class ITSidebar;
@class ITSidebarContainerView;

typedef enum _ITSidebarControllerState 
{
    ITSidebarHidden = 1,
    ITSidebarShown = 2,
    ITSidebarSlidingRight = 3,
    ITSidebarSlidingLeft = 4,
} ITSidebarControllerState;

@interface ITSidebarController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) ITSidebarControllerState state;
@property (strong, nonatomic, readonly) ITSidebar *sidebar;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) NSArray *sidebarItems;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic, readonly) ITSidebarContainerView *containerView;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *containerTouchRecognizer;

- (void)fillContentView;
- (void)slideContainerViewToRightAnimated:(BOOL)animated;
- (void)slideContainerViewToLeftAnimated:(BOOL)animated;
- (void)toggleStateAnimated:(BOOL)animated;
- (void)_delayedViewTransition:(UIView*)oldView;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)swipedLeft;
- (void)swipedRight;
- (void)containerViewTouched;

@end
