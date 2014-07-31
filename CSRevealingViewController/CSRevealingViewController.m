//
//  CSRevealingViewController.m
//  CSRevealer
//
//  Created by Lange, Josef on 7/17/14.
//  Copyright (c) 2014 Command Shift Labs. All rights reserved.
//

#import "CSRevealingViewController.h"

#pragma mark - Macros

#define CS_DEFAULT_OVERHANG 100.0
#define CS_TRANSLATION_KEY @"translation"
#define CS_VELOCITY_KEY @"velocity"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark -
@interface CSRevealingViewController ()

#pragma mark Layout Constraint Properties
@property (strong, nonatomic) NSLayoutConstraint *moveableConstraint;
@property (assign, nonatomic) CGFloat revealedConstant;

#pragma mark Revealing Helper Properties
@property (nonatomic, assign) BOOL isRevealed;
@property (readonly, nonatomic) CGFloat flip;
@property (readonly, nonatomic) BOOL directionIsVertical;

#pragma mark Pan State Properties
@property (assign, nonatomic) CGFloat panOrigin;
@property (assign, nonatomic) CGFloat panPresent;

#pragma mark Touch-to-Close Properties
@property (nonatomic, strong) UITapGestureRecognizer *tapToCloseRecognizer;

@end

#pragma mark -
@implementation CSRevealingViewController

#pragma mark Property Synthesis
@synthesize direction = _direction;
@synthesize backViewController = _backViewController;
@synthesize frontViewController = _frontViewController;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isRevealed = NO;
    self.shouldRespondToEdgeTap = NO;
    [self resetGestures];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Setters and Getters

- (void)setIsRevealed:(BOOL)isRevealed {
    _isRevealed = isRevealed;
    if(_isRevealed) {
        self.revealedConstant = [self valueForRevealed];
    } else {
        self.revealedConstant = 0.0;
    }
    [self updateConstraints];

    [[NSNotificationCenter defaultCenter] postNotificationName:CSRevealingViewControllerDidChangeState object:nil];
}

- (CSRevealingSwipeDirection)direction {
    if(!_direction) {
        _direction = CSRevealingSwipeDirectionUp;
    }
    return _direction;
}

- (void)setDirection:(CSRevealingSwipeDirection)direction {
    _direction = direction;
    [self resetConstraints];
}

- (CGFloat)overhang {
    if(!_overhang) {
        _overhang = 150.0f;
    }
    return _overhang;
}

- (void)setRevealedConstant:(CGFloat)revealedConstant {
    _revealedConstant = revealedConstant;
    [self updateConstraints];
}

- (UIViewController *)backViewController {
    if(!_backViewController) {
        _backViewController = [[UIViewController alloc] init];
        _backViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        _backViewController.view.backgroundColor = [UIColor lightGrayColor];
    }
    return _backViewController;
}

- (void)setBackViewController:(UIViewController *)backViewController {
    _backViewController = backViewController;
    _backViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self resetConstraints];
}

- (UIViewController *)frontViewController {
    if(!_frontViewController) {
        _frontViewController = [[UIViewController alloc] init];
        _frontViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        _frontViewController.view.backgroundColor = [UIColor darkGrayColor];

    }
    return _frontViewController;
}

- (void)setFrontViewController:(UIViewController *)frontViewController {
    _frontViewController = frontViewController;
    _frontViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self resetConstraints];
}

#pragma mark - ViewController Management

- (void)reseatChildren {

    for(UIViewController *currentChild in self.childViewControllers) {
        [currentChild removeFromParentViewController];
    }

    for(UIView *currentChildView in self.view.subviews) {
        [currentChildView removeFromSuperview];
    }

    [self addChildViewController:self.backViewController];
    [self addChildViewController:self.frontViewController];
    [self.view addSubview:self.backViewController.view];
    [self.view addSubview:self.frontViewController.view];

    [self resetGestures];
    

}

#pragma mark - Handling Rotation

#pragma mark iOS < 8.0
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        BOOL willBePortrait = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
        BOOL currentlyIsPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
        if(currentlyIsPortrait != willBePortrait) {
            [self viewWillTransitionToSize:CGSizeMake(self.view.bounds.size.height, self.view.bounds.size.width) withTransitionCoordinator:nil];
        }
    }
}

#pragma mark iOS >= 8.0
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if(self.isRevealed) {
        self.revealedConstant = [self valueForRevealedWithSize:size];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Constraint Modification

- (void)updateConstraints {
    self.moveableConstraint.constant = self.revealedConstant;
    [self.view layoutIfNeeded];
}

- (void)resetConstraints {

    [self reseatChildren];

    NSArray *directions = @[@"H", @"V"];
    UIView *subview;
    NSString *direction;
    NSString *visualConstraints;
    NSArray *constraints;
    NSDictionary *views;

    // Set up equal widths through some constraints here.
    for(subview in self.view.subviews) {
        for(direction in directions) {
            visualConstraints = [NSString stringWithFormat:@"%@:[subview(==parentView)]", direction];
            views = @{ @"subview": subview, @"parentView": self.view };
            constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualConstraints options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
            [self.view addConstraints:constraints];
        }
    }

    NSLayoutConstraint *verticalCenter = [NSLayoutConstraint constraintWithItem:self.frontViewController.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    NSLayoutConstraint *horizontalCenter = [NSLayoutConstraint constraintWithItem:self.frontViewController.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0.0f];


    NSLayoutConstraint *backVerticalCenter = [NSLayoutConstraint constraintWithItem:self.backViewController.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    NSLayoutConstraint *backHorizontalCenter = [NSLayoutConstraint constraintWithItem:self.backViewController.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0.0f];

    [self.view addConstraints:@[verticalCenter, horizontalCenter, backVerticalCenter, backHorizontalCenter]];

    if([self directionIsVertical]) {
        self.moveableConstraint = verticalCenter;
    } else {
        self.moveableConstraint = horizontalCenter;
    }

    [self.view layoutIfNeeded];

}

#pragma mark - Gesture Recognition
- (void)resetGestures {
    [self addPanGesture];
    [self addTapGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    NSDictionary *filteredResults = [self orientRecognizer:recognizer];
    NSNumber *translation = [filteredResults objectForKey:CS_TRANSLATION_KEY];
    NSNumber *velocity = [filteredResults objectForKey:CS_VELOCITY_KEY];

    if(recognizer.state == UIGestureRecognizerStateBegan) {
        self.panOrigin = self.revealedConstant;
    }

    CGFloat translatedFromOrigin = self.panOrigin + translation.doubleValue;

    if([self newConstantIsValid:translatedFromOrigin]) {
        self.revealedConstant = translatedFromOrigin;
    }

    if(recognizer.state == UIGestureRecognizerStateEnded) {
        BOOL shouldFollowSwipe = (abs(velocity.doubleValue) > 500);
        BOOL swipeIsRevealing = (velocity.doubleValue * self.flip > 0);
        BOOL shouldReveal = (shouldFollowSwipe==swipeIsRevealing);
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            self.isRevealed = shouldReveal;
        } completion:nil];
    }
}

- (NSDictionary *)orientRecognizer:(UIPanGestureRecognizer *)recognizer {
    NSNumber *translation;
    NSNumber *velocity;
    if(self.directionIsVertical) {
        translation = [NSNumber numberWithDouble:[recognizer translationInView:self.view].y];
        velocity = [NSNumber numberWithDouble:[recognizer velocityInView:self.view].y];
    } else {
        translation = [NSNumber numberWithDouble:[recognizer translationInView:self.view].x];
        velocity = [NSNumber numberWithDouble:[recognizer velocityInView:self.view].x];
    }

    return @{ CS_TRANSLATION_KEY: translation, CS_VELOCITY_KEY: velocity };
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint pointTouched = [recognizer locationInView:self.frontViewController.view];
    if([self touchIsValid:pointTouched] && self.shouldRespondToEdgeTap) {
        if(self.isRevealed) {
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.isRevealed = NO;
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.isRevealed = YES;
            }];
        }
    }
}

- (BOOL)touchIsValid:(CGPoint)point {
    CGRect frontBounds = self.frontViewController.view.bounds;
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    if(self.directionIsVertical) {
        w = frontBounds.size.width;
        h = self.overhang;
        x = 0.0f;
        y = 0.0f;
        if(self.direction == CSRevealingSwipeDirectionUp) {
            y = frontBounds.size.height - self.overhang;
        }
    } else {
        w = self.overhang;
        h = frontBounds.size.height;
        x = 0.0f;
        y = 0.0f;
        if(self.direction == CSRevealingSwipeDirectionLeft) {
            x = frontBounds.size.width - self.overhang;
        }
    }
    CGRect validTouchRegion = CGRectMake(x, y, w, h);
    return CGRectContainsPoint(validTouchRegion, point);
}

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.frontViewController.view addGestureRecognizer:pan];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.frontViewController.view addGestureRecognizer:tap];
}

#pragma mark - External Messaging

- (void)revealAnimated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.3f animations:^(void) {
            self.isRevealed = YES;
        }];
    } else {
        self.isRevealed = YES;
    }
}

- (void)unrevealAnimated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.3f animations:^(void) {
            self.isRevealed = NO;
        }];
    } else {
        self.isRevealed = NO;
    }
}

#pragma mark - Utility Methods
- (BOOL)directionIsVertical {
    return (self.direction == CSRevealingSwipeDirectionUp || self.direction == CSRevealingSwipeDirectionDown);
}

- (CGFloat)flip {
    CGFloat flipValue = (self.direction == CSRevealingSwipeDirectionDown || self.direction == CSRevealingSwipeDirectionRight) ? 1.0 : -1.0;
    return flipValue;
}

- (CGFloat)valueForRevealedWithSize:(CGSize)size {
    if(self.directionIsVertical) {
        return ((size.height) - self.overhang) * self.flip;
    } else {
        return ((size.width) - self.overhang) * self.flip;
    }
}

- (CGFloat)valueForRevealed {
    return [self valueForRevealedWithSize:self.view.bounds.size];
}

- (BOOL)newConstantIsValid:(CGFloat)newConstant {
    CGFloat base = 0.0;
    CGFloat extreme = [self valueForRevealed];
    BOOL valid = ( (base <= newConstant && newConstant <= extreme)  || (extreme <= newConstant && newConstant <= base) );
    return valid;
}

@end
