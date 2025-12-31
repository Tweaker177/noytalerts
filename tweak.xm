#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark - Helpers

static void killVC(UIViewController *vc) {
    if (!vc) return;

    if (vc.view) {
        [vc.view removeFromSuperview];
        vc.view.hidden = YES;
    }

    if (vc.presentingViewController) {
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
}

static BOOL isBadYTClass(NSString *name) {
    if (![name containsString:@"YT"]) return NO;

    if ([name containsString:@"Update"] ||
        [name containsString:@"Upgrade"] ||
        [name containsString:@"Alert"] ||
        [name containsString:@"Dialog"]) {
        return YES;
    }

    return NO;
}

#pragma mark - Injection Proof

static BOOL showedInjectionAlert = NO;

__attribute__((constructor))
static void ytnoalerts_init() {
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter]
            addObserverForName:UIApplicationDidFinishLaunchingNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {

            if (showedInjectionAlert) return;
            showedInjectionAlert = YES;

            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *keyWindow = nil;

                for (UIWindow *w in UIApplication.sharedApplication.windows) {
                    if (w.isKeyWindow) {
                        keyWindow = w;
                        break;
                    }
                }

                if (!keyWindow) return;

                UIViewController *vc = keyWindow.rootViewController;
                while (vc.presentedViewController) {
                    vc = vc.presentedViewController;
                }

                UIAlertController *alert =
                    [UIAlertController alertControllerWithTitle:@"ytnoalerts"
                                                        message:@"Injection confirmed"
                                                 preferredStyle:UIAlertControllerStyleAlert];

                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil]];

                [vc presentViewController:alert animated:YES completion:nil];
            });
        }];
    }
}

#pragma mark - Version Spoofing

%hook NSBundle

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleShortVersionString"]) {
        return @"20.15.1";
    }
    if ([key isEqualToString:@"CFBundleVersion"]) {
        return @"20.15.1";
    }
    return %orig;
}

%end

#pragma mark - Global Presentation Intercept

%hook UIViewController

- (void)presentViewController:(UIViewController *)vc
                      animated:(BOOL)animated
                    completion:(void (^)(void))completion {

    NSString *name = NSStringFromClass([vc class]);
    if (isBadYTClass(name)) {
        killVC(vc);
        return;
    }

    %orig;
}

%end

#pragma mark - Known YouTube Controllers

@interface YTUpdateRequiredViewController : UIViewController @end
@interface YTAppUpgradeDialogController : UIViewController @end
@interface YTAlertViewController : UIViewController @end
@interface YTDialogViewController : UIViewController @end

%hook YTUpdateRequiredViewController

- (id)init {
    id r = %orig;
    killVC(r);
    return r;
}

- (id)initWithCoder:(NSCoder *)coder {
    id r = %orig;
    killVC(r);
    return r;
}

- (void)loadView {
    %orig;
    killVC(self);
}

- (void)viewDidLoad {
    %orig;
    killVC(self);
}

- (void)viewWillAppear:(BOOL)animated {
    killVC(self);
}

- (void)viewDidAppear:(BOOL)animated {
    killVC(self);
}

%end

%hook YTAppUpgradeDialogController

- (id)init {
    id r = %orig;
    killVC(r);
    return r;
}

- (id)initWithCoder:(NSCoder *)coder {
    id r = %orig;
    killVC(r);
    return r;
}

- (void)loadView {
    %orig;
    killVC(self);
}

- (void)viewDidLoad {
    %orig;
    killVC(self);
}

- (void)viewWillAppear:(BOOL)animated {
    killVC(self);
}

- (void)viewDidAppear:(BOOL)animated {
    killVC(self);
}

%end

%hook YTAlertViewController

- (id)init {
    id r = %orig;
    killVC(r);
    return r;
}

- (id)initWithCoder:(NSCoder *)coder {
    id r = %orig;
    killVC(r);
    return r;
}

- (void)loadView {
    %orig;
    killVC(self);
}

- (void)viewDidLoad {
    %orig;
    killVC(self);
}

- (void)viewWillAppear:(BOOL)animated {
    killVC(self);
}

- (void)viewDidAppear:(BOOL)animated {
    killVC(self);
}

%end

%hook YTDialogViewController

- (id)init {
    id r = %orig;
    killVC(r);
    return r;
}

- (id)initWithCoder:(NSCoder *)coder {
    id r = %orig;
    killVC(r);
    return r;
}

- (void)loadView {
    %orig;
    killVC(self);
}

- (void)viewDidLoad {
    %orig;
    killVC(self);
}

- (void)viewWillAppear:(BOOL)animated {
    killVC(self);
}

- (void)viewDidAppear:(BOOL)animated {
    killVC(self);
}

%end

#pragma mark - UIView Overlay Kill

%hook UIView

- (void)didMoveToWindow {
    %orig;

    NSString *name = NSStringFromClass([self class]);
    if (isBadYTClass(name)) {
        [self removeFromSuperview];
        self.hidden = YES;
    }
}

%end

#pragma mark - UIWindow Clamp

%hook UIWindow

- (void)setWindowLevel:(UIWindowLevel)level {
    if (level > UIWindowLevelAlert) {
        return;
    }
    %orig;
}

%end


#pragma mark -  TOUCH FIX

%hook UIWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSString *cls = NSStringFromClass([self class]);

    /*
     ONLY affect YouTube private windows
     Just let touches fall through.
    */
    if ([cls hasPrefix:@"YT"] &&
        ![cls containsString:@"UIAlert"] &&
        ![cls isEqualToString:@"UIWindow"]) {

        return nil;
    }

    return %orig;
}

%end
