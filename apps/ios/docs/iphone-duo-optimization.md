# iPhone Duo optimization

Apple guidance checked on **2026-10-07**. The deployment minimum remains iOS 26.0; native Duo behavior is built with the iOS 27.1 SDK.

## Changes

- Retained native adaptive tabs, navigation stacks, scrolling content, and the bounded reading widths introduced in the iPad pass. Drafts and review state remain outside size-dependent branches.
- Review filters use native compact presentation adaptation instead of forcing a fixed popover. The preferred 320 × 420 size can shrink, long deck/tag labels wrap, and a translated native Done action provides explicit dismissal. The toolbar retains the named glass deck selector requested during physical iPad review.
- Editor Cancel/Save use native cancellation and confirmation placements, preserving Escape and Command-S. AI New supplies a native symbol/title label.
- Frequent Review, AI, editor attachment, and Progress controls have 44-point touch targets. AI attachment removal includes contextual accessibility information using existing translations.
- At accessibility text sizes, revealed review ratings form a full-width vertical list within the main scroll view. The previous fixed two-row accessory consumed nearly the whole outer Duo window at AX5, leaving insufficient room to read the answer. Show Answer remains fixed before reveal; default-size rating layouts are retained.
- iPhone landscape orientations are enabled and declared consistently in the plist and build configuration. Inner Duo layouts must adapt regardless of ordinary-phone orientation restrictions.
- Transient banners follow the local SwiftUI safe area instead of restoring only a manually calculated top inset.

The reusable `iphone-duo-optimization` skill stores the dated guidance and QA procedure. Key sources: [Duo HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo), [preparation overview](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo), [adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/), and [native bars](https://developer.apple.com/videos/play/tech-talks/111462/).

## Local tooling and verification

Xcode 27.1 RC (27A9275) is isolated under `/private/tmp/nibomo-duo-toolchain/Xcode.app`; commands select it through `DEVELOPER_DIR`. The installed Xcode and global command-line-tool selection remain unchanged. The arm64 iOS 27.1 runtime is 24A94232. A dedicated **Nibomo iPhone Duo** simulator uses device type `iPhone-Duo` and model `iPhone19,4`.

`LiveSmokeIPhoneDuoTests` has a coordinated native display-transition smoke and a separate ordinary-phone largest-text regression. Drive Device Hub's actual Closed/Open controls at the printed checkpoints; device rotation and synthetic geometry changes do not replace a Duo display handoff. The smoke checks exact unsaved text, save, revealed-answer continuity, ratings, and unchanged filter selection after dismissal/reopening. Use local disposable fixtures and no AI requests.

The initial coordinated display-transition smoke passed in 251.536 seconds: an exact unsaved multiline draft survived opening from a 466 × 678-point outer scene to a 669 × 951-point inner scene; the same answer stayed revealed after closing; all four ratings remained reachable; unchanged filter selection survived dismissal and reopening. Final shared-source fold checks are pending.

An earlier outer-display AX5 smoke passed in **152.655 seconds**, recorded in `tmp/duo-accessibility-confirmed.xcresult`. It checks exact multiline draft persistence/save, the editor and native Back control above the software keyboard, the entire revealed answer within the visible scroll viewport, all four fully readable rating labels and reachable touch targets, a successful Good rating, Progress, AI entry without a network request, and nested Settings. Selected active-display screenshots confirm the answer and inline ratings are readable. Rating backgrounds can extend slightly beyond the native scroll-indicator track; assertions require the complete labels and at least a 44 × 44-point visible usable touch area.

The ordinary iPhone 18 Pro manual-review regression passed in **30.699 seconds**, recorded in `tmp/duo-ordinary-iphone-final.xcresult`. These two results precede the subsequent physical-iPad feedback fixes for the floating keyboard and leading AI pane; those source revisions require focused revalidation.

The later final native fold run, `tmp/duo-native-final.xcresult`, was deliberately interrupted at its Open checkpoint because both chats' native UI control sessions returned Apple ScreenCaptureKit error −3811. A partial-fold baseline, `tmp/duo-partial-baseline.xcresult`, subsequently timed out at the same native-control dependency when capture recovered briefly and then failed again. Neither run verifies folding or establishes an app defect. The partial-fold and landscape cases remain pending until native fold controls can be operated.

The largest-text diagnostic exposed a harness assumption: Duo's native `BackButton` sits in the vertical toolbar outside `NavigationBar`. Its screenshot and accessibility frame establish that it remained visible above the keyboard. The lookup now targets that actual visible native button first. This diagnostic failure did not establish an app navigation defect.

After a Duo display transition, `XCUIScreen.main` can remain bound to the inactive display and yield a black image. The smoke captures the app scene and every enumerated screen; inspect content and dimensions before selecting evidence. Screen-array indices are not simulator display IDs. Never use a black or cropped capture as proof of the app's layout.

The later inner-landscape checks caught an actual inspector placement defect: attaching the right pane outside the entire tab container let it cover Duo's native vertical navigation. The inspector now attaches to the content inside each host's existing NavigationStack, following [Apple's inspector placement guidance](https://developer.apple.com/videos/play/wwdc2023/10161/). Host bindings ignore outgoing-tab dismissal callbacks. A focused pre-header check passed in **37.070 seconds** (`tmp/duo-inspector-content-anchor.xcresult`) with all five destinations reachable, but post-switch screenshot inspection showed missing pane content and toolbar bleed. Close-button existence alone was insufficient proof. The strengthened test requires visible consent content after Cards → Review; the companion header now stays within its pane instead of supplying parent navigation preferences. Final verification of this revision is pending.

The next inner-landscape AX5 run (`tmp/duo-native-inspector-accessibility.xcresult`) successfully edited and saved the exact draft, then failed strict readability for the Hard rating. Six identical SpringBoard-root drags did not move Review. Their x-coordinate exceeded the inactive outer display's width despite matching the inner scene. The harness now anchors gestures to the actual Review ScrollView; the full-label and visible 44-point touch-area requirements remain unchanged. This diagnosis requires a successful rerun before closing the rating check.

Physical Duo hardware, camera accessories, Pencil, and independent concurrent study windows are outside the verified scope. App approval remains required before opening a PR.

## Apple resizability audit

Audited app-owned Swift sources on October 7, 2026 using Xcode 27.1's bundled `app-resizability` skill and its screen, orientation, scene lifecycle, safe-area, and idiom references. Dependency sources and test fixtures were excluded.

The launch screen is declared in `Config/Info.plist` and generated through `Config/Base.xcconfig`. iPad supports all four orientations. `UIRequiresFullScreen` is absent from the plist, configuration files, and project settings. These prerequisites already support resizability.

Paths below are relative to `apps/ios/Flashcards/Flashcards/`.

| Detected source | Disposition |
| --- | --- |
| `TransientBannerSupport.swift`, `GlobalTransientBannerHost` | Fixed: removed manual `GeometryProxy.safeAreaInsets.top` padding and blanket `ignoresSafeArea()`. The overlay now follows its own SwiftUI safe area, including asymmetric side controls. Retained design margins, dismissal gesture, hit testing, transition, and animation. |
| `Settings/Account/AccountDeletionProgressView.swift` | Retained: `ignoresSafeArea()` applies only to the background fill; readable and interactive content remains inset. |
| `App/FlashcardsApp.swift` | Retained: native `WindowGroup` and `scenePhase` already provide SwiftUI scene lifecycle. The UIKit scene-delegate migration does not apply. |
| `App/Navigation/DockedKeyboardObserver.swift`, `RootTabView` | Physical iPad feedback introduced a native `UIKeyboardLayoutGuide` probe with `followsUndockedKeyboard = false`. Floating keyboards do not create a bottom inset; docked keyboards retain SwiftUI avoidance. The invisible measurement background spans its own scene. No screen-global bounds or keyboard-notification frame heuristics are used. The final outer-display AX5 regression passed with docked editing above the keyboard; native display-transition editing is checked separately. |
| `Review/Notifications/ReviewNotificationsAppDelegate.swift` | Retained: the delegate initializes notification handling and observes deliberately process-wide analytics events. It creates no windows and contains no app-delegate UI lifecycle methods to migrate. Application-state reads supply diagnostics. |
| `App/AppLifecycleSupport.swift` | Retained: shared application calls manage process background task budgets, not display geometry. |
| `Review/Notifications/Diagnostics/ReviewNotificationDiagnosticsSupport.swift` | Retained: application state is diagnostic metadata, not a layout input. |
| `Settings/ThisDeviceSettingsView.swift` | Retained: `UIDevice` supplies hardware/device metadata, not layout or available-space decisions. |
| `App/Navigation/TabSidebarVisibilityReader.swift` | The later iPad feedback adds an iPad-only leading-chat option. Actual `tabBarPlacement` is read inside Tab content; `.topBar` permits that option and `.sidebar`, nil, and other placements retain the inspector. The iPad idiom check scopes this requested feature, while regular width and measured window bounds determine usable layout. Duo retains the native inspector and the stable detail TabView. This revision requires the final native transition checks. |
| `Settings/AccessPermissionSupport.swift` | Retained: shared application calls open system Settings; they do not query scene geometry. |
| `AI/Views/AIChatView.swift`, `dismissComposerFocus` | Retained in this audit: the responder action concerns keyboard dismissal, outside the skill's geometry migration targets. |

No `UIScreen.main`, layout-related interface-orientation checks, deprecated layout guides, manual keyboard-frame avoidance, stored safe-area insets, or paired horizontal inset assumptions remained in the audited app source. The later leading-chat feature uses the explicitly scoped iPad eligibility check described above. Existing readable-width limits and padding are design margins, not substitutes for system insets.
