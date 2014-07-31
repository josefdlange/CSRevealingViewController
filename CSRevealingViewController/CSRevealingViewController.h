//
//  CSRevealingViewController.h
//  CSRevealer
//
//  Created by Lange, Josef on 7/17/14.
//  Copyright (c) 2014 Command Shift Labs. All rights reserved.
//

#define CSRevealingViewControllerDidChangeState @"CSRevealingViewControllerDidChangeState"

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CSRevealingSwipeDirectionUp,
    CSRevealingSwipeDirectionDown,
    CSRevealingSwipeDirectionLeft,
    CSRevealingSwipeDirectionRight
} CSRevealingSwipeDirection;

@interface CSRevealingViewController : UIViewController

#pragma mark Interaction Properties
/** Whether or not the back ViewController is revealed. */
@property (nonatomic, readonly) BOOL isRevealed;
/** How much of the front ViewController should remain on-screen when back is "revealed". */
@property (nonatomic, assign) CGFloat overhang;
/** Direction of swipe that reveals the back ViewController. */
@property (nonatomic, assign) CSRevealingSwipeDirection direction;
/** Whether or not tapping the front VC will re-cover the back VC. */
@property (nonatomic, assign) BOOL shouldRespondToEdgeTap;

#pragma mark State Properties
/** Front and back ViewControllers should not be frequently changed. If you need to change the content of one or the other frequently, I suggest a NavigationController. */

/** The back ViewController. */
@property (nonatomic, strong) UIViewController *backViewController;
/** The front ViewController */
@property (nonatomic, strong) UIViewController *frontViewController;

#pragma mark - Controlling the RevealingViewController
/** Reveal the bottom ViewController. */
- (void)revealAnimated:(BOOL)animated;

/** Return the top ViewController to above of the back ViewController, obscuring it. */
- (void)unrevealAnimated:(BOOL)animated;

@end