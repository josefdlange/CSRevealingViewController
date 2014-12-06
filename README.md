CSRevealingViewController
=========================

## CSRevealingViewController

A custom ViewController which embeds two more `UIViewController` objects, presenting one in front of the other. The top ViewController may be dragged in a developer-determined direction to reveal the bottom ViewController.

## Usage

Usage is pretty straightforward. Direct IB integration is forthcoming, but for the time being, this pattern is what you're looking for:

Add the dependency to your `Podfile`:

```ruby
platform :ios
pod 'CSRevealingViewController'
...
```

Run `pod install` to install the dependencies.

In your storyboard, set your root ViewController's custom class to `CSRevealingViewController`, and instantiate the ViewControllers you want to be embedded within it. Make sure to give those two sane identifiers that you remember.

Then, in your AppDelegate:

```objc
#import <CSRevealingViewController/CSRevealingViewController.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Get the root ViewController, cast into what it really is. Also grab its storyboard, we'll need that.
    CSRevealingViewController *rVC = (CSRevealingViewController *)self.window.rootViewController;
    UIStoryboard *mainStoryboard = rVC.storyboard;

    // Set up the revealing behavior.
    rVC.overhang = 50.0f;   // "Overhang" that the top VC shows when revealing the bottom VC.
    rVC.direction = CSRevealingSwipeDirectionUp;    // Which direction you want to swipe to reveal.
    rVC.shouldRespondToEdgeTap = YES;   // Do you want to respond to tapping the "overhang" edge of the top VC to make it reveal?

    // Retrieve and set the top and bottom ViewControllers.
    // Note the typecast to UIViewController <CSRevealingViewControllerChild>
    // All the methods in this protocol are optional, though I cannot make
    // the protocol itself optional. Nonetheless, all the protocol methods
    // are optional, so you don't need to change your VCs unless you want to
    // take advantage of the protocol... which has shouldX and willX messages
    // that can be received by children.
    UIViewController<CSRevealingViewControllerChild> *back = (UIViewController<CSRevealingViewControllerChild> *)[mainStoryboard instantiateViewControllerWithIdentifier:@"BackRootVC"];
    UIViewController<CSRevealingViewControllerChild> *front = (UIViewController<CSRevealingViewControllerChild> *)[mainStoryboard instantiateViewControllerWithIdentifier:@"FrontRootVC"];
    rVC.backViewController = back;
    rVC.frontViewController = front;

    return YES;
}



```
