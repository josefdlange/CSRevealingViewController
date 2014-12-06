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

@protocol CSRevealingViewControllerChild

@optional
-(void)willReveal;
-(void)willUnreveal;
-(BOOL)shouldReveal;
-(BOOL)shouldUnreveal;

@end

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
/** Whether or not we should listen to pan gestures at all. */
@property (nonatomic, assign) BOOL shouldRespondToPanGesture;

#pragma mark State Properties
/** Front and back ViewControllers should not be frequently changed. If you need to change the content of one or the other frequently, I suggest a NavigationController. */

/** The back ViewController. */
@property (nonatomic, strong) UIViewController<CSRevealingViewControllerChild> *backViewController;
/** The front ViewController */
@property (nonatomic, strong) UIViewController<CSRevealingViewControllerChild> *frontViewController;

#pragma mark - Controlling the RevealingViewController
/** Reveal the bottom ViewController. */
- (void)revealAnimated:(BOOL)animated;

/** Return the top ViewController to above of the back ViewController, obscuring it. */
- (void)unrevealAnimated:(BOOL)animated;

@end