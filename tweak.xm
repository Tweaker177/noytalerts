#import <UIKit/UIKit.h>

// --- Improvements to your Version Spoofing ---
// Some YT versions check the version via YTDeviceInfo rather than NSBundle directly.
%hook YTDeviceInfo
- (NSString *)appVersion {
    return @"20.15.1";
}
%end

%hook YTVersionUtils
+ (BOOL)isUpgradeRequired { return NO; }
+ (BOOL)isUpgradeRecommended { return NO; }
+ (NSString *)appVersion { return @"20.15.1"; }
%end

// --- Killing the Presenter Logic (The "Brain" of the alert) ---
%hook YTUpgradePresenter
- (void)showUpgrade { /* Block entirely */ }
- (void)showForceUpgrade { /* Block entirely */ }
- (void)prepareUpgradeForced:(BOOL)arg1 { /* Block entirely */ }
- (BOOL)isUpgradeRequired { return NO; }
%end

// --- Fixing the Frozen UI / Touch Issues ---
%hook UIApplication
- (void)beginIgnoringInteractionEvents {
    // YouTube calls this when showing the update alert to freeze the background.
    // We prevent it from ever locking the UI.
    return;
}
%end

%hook UIWindow
- (void)makeKeyAndVisible {
    // If a window is being made key (top priority) and it's an alert window, block it.
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"YTAlertWindow"] || [className containsString:@"YTActionSheetWindow"]) {
        return; 
    }
    %orig;
}

- (void)setUserInteractionEnabled:(BOOL)enabled {
    // If something tries to disable touch on the main window, force it to stay ON.
    if (!enabled && [NSStringFromClass([self class]) isEqualToString:@"UIWindow"]) {
        %orig(YES);
        return;
    }
    %orig;
}
%end

@interface YTBackdropView : UIView @end

// --- The "Dimming View" Killer ---
// YouTube often uses a backdrop view that isn't a VC.
%hook YTBackdropView
- (void)didMoveToWindow {
    %orig;
    [self removeFromSuperview];
}
%end

@interface YTBaseAlertViewController : UIViewController @end

// --- Clean dismissal hook ---
%hook YTBaseAlertViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    // Instead of just killing it, we force the app to think it was dismissed normally
    [self dismissViewControllerAnimated:NO completion:^{
        // Force the app to resume touches just in case
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}
%end
