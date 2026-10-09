# iPad layout and local review

Apple guidance checked on 2026-10-07. The app retains its iOS/iPadOS 26 minimum deployment target; this work was built with Xcode 27.

## Layout decisions

- The five destinations use native `Tab` declarations and `sidebarAdaptable`, keeping the same navigation stacks and selection when navigation adapts.
- Study content, review actions, AI transcripts/composer, and Progress use bounded, centered reading widths. Forms and text editors retain native scrolling and keyboard avoidance.
- Review ratings use one row when at least 600 points are available; smaller windows use the existing two-column arrangement. At accessibility text sizes, ratings instead form one full-width column below the answer inside the study scroll view, leaving the answer readable before scrolling to actions. Show Answer remains fixed before reveal. Rating labels can wrap and buttons have a 44-point minimum height.
- Cards metadata can stack vertically. Settings values use `LabeledContent`. Calendar cells fit the available columns; accessibility sizes can scroll the calendar horizontally.
- Card editors support Command-S to save and Escape to cancel. Global creation shortcuts are deliberately absent so they cannot replace an active draft.

Use local container space rather than device model or orientation as a layout decision. An iPad can have a narrow or short window. The app already declares all iPad orientations, indirect input, and a scene lifecycle without requiring fullscreen.

This change does not redesign the existing shared-store multiwindow architecture. Multiple independent study sessions need separate navigation and review ownership before being advertised as supported. Center Stage camera framing does not apply to the current still-photo attachment picker; Stage Manager and window resizing do apply.

## Apple references

- [Layout](https://developer.apple.com/design/human-interface-guidelines/layout), [tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars), and [multitasking](https://developer.apple.com/design/human-interface-guidelines/multitasking).
- [Elevate the design of your iPad app](https://developer.apple.com/videos/play/wwdc2025/208/) and [WWDC26 iPadOS guide](https://developer.apple.com/wwdc26/guides/ipados/).
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility), [keyboards](https://developer.apple.com/design/human-interface-guidelines/keyboards), and [pointing devices](https://developer.apple.com/design/human-interface-guidelines/pointing-devices).

The reusable personal `ipad-app-optimization` skill contains a dated synthesis, additional source links, and a simulator QA matrix.

## Simulator checks

`LiveSmokeIPadTests` exercises a real app with local fixtures. Keyboard and draft checks may accept local simulator AI consent to reach the composer; they send no AI prompts. The earlier entry-surface-only checks leave consent untouched. Its screenshots are retained as XCTest attachments.

- 13-inch iPad Pro: edit a card with the keyboard, retain the unsaved draft through rotation, save, reveal/rate, preserve nested Settings navigation, visit Progress, and open the AI handoff entry.
- iPad mini at the largest accessibility text size: open/edit/save, reveal and reach ratings in landscape, and reach nested Settings.
- Window resize smoke: shrink and restore an active iPad window with an unsaved card draft, then reveal a card and verify all four ratings in a narrow, short window. Assert actual scene geometry changes; rotation alone does not validate window resizing.
- iPhone regression: run an existing local smoke on the same installed runtime.

Run only the focused methods needed for the change. See the iOS README and local setup guide for the normal command pattern. Simulator Keychain fixtures require signing; `CODE_SIGNING_ALLOWED=NO` can fail with `errSecMissingEntitlement`. Local simulator builds can use `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-` without a device provisioning profile.

If a synced Documents folder attaches Finder metadata to generated bundles and codesign fails with `resource fork, Finder information, or similar detritus not allowed`, use an unsynced local temporary DerivedData path for this run. Keep the package checkout cache and source files in place. This is an exception to the usual repo-local DerivedData recommendation.

Physical-device follow-up remains useful for Apple Pencil/Scribble, external displays, hardware keyboard/trackpad, VoiceOver, and camera behavior.

## Physical iPad preview

The local preview requires iPadOS 26 or later. Use the separate bundle ID `com.flashcards-open-source-app.app.ipadpreview` and display name **Nibomo iPad Preview** so the production install is preserved. The app's Keychain service names derive from its bundle ID, keeping preview credentials separate too. No special provisioning entitlements were found.

Connect and unlock the iPad, trust the Mac, and pair it in Xcode/Device Hub. Pairing exposes **Settings → Privacy & Security → Developer Mode**; enable it on the device, restart, and confirm. See Apple's [Developer Mode guide](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device) and [device run instructions](https://help.apple.com/xcode/mac/current/en.lproj/dev5a825a1ca.html).

Physical builds require an Apple Development certificate and a provisioning profile for the selected device/team. Distribution certificates used for App Store publishing do not replace development signing. App Store Connect membership alone may not grant [Certificates, Identifiers & Profiles access](https://developer.apple.com/help/account/access/roles). Keep team identifiers and signing overrides local; do not change repository release settings or revoke existing certificates.

Use a separate unsynced DerivedData path for the device preview. Launch normally for manual testing; do not pass smoke-test reset scenarios to an existing production install. Start with guest cards, then check portrait/landscape, a small floating window, unsaved edits, reveal/rating, and any available hardware keyboard, trackpad, Pencil, or VoiceOver.

The separate preview was development-signed, installed, and launched on Alex’s iPad Pro 11-inch (4th generation), running iPadOS 27.2 beta, on 2026-10-07 using Xcode 27. The owner enabled Developer Mode. The signed application identifier, profile coverage of the exact device, and strict signature validation were checked before installation. Signing overrides and DerivedData stayed local; the production bundle and its data were not targeted. The owner signed in and supplied physical-device UI feedback. Simulator results below do not establish physical input behavior.

## Verified results — 2026-10-07

Local simulator builds and all four repository pre-merge checks passed. Simulator apps were signed locally with an ad hoc identity; no device provisioning or production signing settings changed.

| Simulator / runtime | Result | Coverage |
| --- | --- | --- |
| iPad Pro 13-inch (M5), iPadOS 27.0 | Passed | Rotation with unsaved text, save, reveal/rate, nested Settings, Progress, AI handoff entry. |
| iPad Pro 13-inch (M5), iPadOS 27.0 | Passed | Real floating window at 375 × 486 points, exact draft retention through shrink/restore, readable revealed answer above the native bottom inset, all four ratings, and wide sidebar layout. |
| iPad mini (A17 Pro), iPadOS 27.0 | Passed | Largest accessibility text, portrait/landscape editor and review, all ratings reachable, sidebar overflow navigation, nested Settings, and corrected inline Review title. |
| iPhone 18 Pro, iOS 27.0 | Passed | Existing manual card review and guest navigation smoke methods. |

The floating-window check uses default text size; the mini accessibility check uses fullscreen windows. The iPadOS 26 runtime and physical input/accessibility tools were not exercised. Independent concurrent study windows retain the existing shared-store limitation described above.

Review screenshots are local ignored artifacts under `tmp/ipad-review/`. Final result bundles are `tmp/ipad-pro-sidebar-smoke.xcresult`, `tmp/ipad-pro-window-verified.xcresult`, `tmp/ipad-mini-title-final.xcresult`, `tmp/ipad-iphone-regression.xcresult` (manual review passed; its original navigation failure was fixed), and `tmp/ipad-iphone-settings-final.xcresult`.

The app is left running in Device Hub's **Nibomo iPad Pro 13-inch** simulator with a disposable local study card. App approval is pending; no PR has been opened.

## Connected-device feedback revision — 2026-10-07

The physical screenshots exposed excessive Cards row height and icon-only metadata. Card rows now request their intrinsic vertical size, and tag/due labels explicitly display both title and icon. Metadata still stacks when it does not fit horizontally.

Review again shows the selected deck name with a chevron in the native glass toolbar button. Its bounded intrinsic width prevents the title collapsing to the chevron, including with the AI pane open.

An optional native inspector opens the existing AI chat beside Cards or Review in regular-width layouts; the system adapts it to a sheet in compact windows. Use the conversation button in the primary toolbar and the pane’s Close button. Cards and Review retain their existing view hierarchy. Card handoffs use the pane when it is open and the AI tab otherwise. The same AI store retains the conversation, unsent composer text, and attachments across presentation changes. This adds no concurrent chat session.

Only the active AI presentation may consume view-local events or deferred card requests; disappearing panes are excluded by placement and owning-tab checks. Dictation atomically claims a matching completion ID before insertion, rejecting duplicate/stale callbacks. Shared chat activity reflects either visible presentation, so a disappearing view cannot suspend another visible owner. Physical dictation and camera/Pencil interaction remain manual checks.

The new pane controls are translated into every supported app locale. The trailing presentation uses Apple’s [adaptive inspector](https://developer.apple.com/videos/play/wwdc2023/10161/). The optional leading presentation is described below.

The focused `testIPadCompactCardRowsAndAICompanionPreserveReview` smoke passed on the 13-inch iPad Pro / iPadOS 27.0 after the row fix and again after the AI ownership safeguard. It checks compact rows, simultaneous usable Cards and AI entry, a card handoff retaining Cards, and a revealed answer surviving pane open/close followed by rating. It leaves AI provider consent untouched and sends no prompts. The final smoke, including readable deck-button width both with and without the pane, also passed (63 seconds). Final result bundle: `/private/tmp/nibomo-ipad-companion-title.xcresult`. All four repository checks passed. The final development-signed preview was updated on the same physical iPad without resetting its container or credentials; normal launch and the new preview process were verified. A full physical landscape capture shows the named glass selector, Review card, and a ready AI composer alongside, with the owner’s existing study badges and card data present. No fixture/reset arguments or AI prompts were used on the device.

The broader rotation/editor run was cancelled after simulator text-entry animation waits while the row rendering was revised; it is not recorded as a pass for this revision. Earlier rotation/resize results above apply to the earlier build. The revised pane’s compact-window adaptation, unsent AI draft transfer, hardware dictation, keyboard/trackpad, Scribble, and VoiceOver require further hands-on validation. No PR has been opened; app approval is pending.

Final simulator review captures: `tmp/ipad-review/compact-cards.png`, `cards-ai-companion.png`, and `review-ai-companion.png`. XCTest’s screen capture used portrait-sized output during landscape; inspect full physical captures or live UI for actual device framing.

Physical updated capture: `tmp/ipad-review/connected-updated-preview.png` (2388 × 1668). The owner’s testdrive and approval remain pending.


## Floating keyboard and companion toolbar revision — 2026-10-07

The owner chose the native `bubble.left.and.bubble.right` symbol from three proposed options. Cards and Review place this control last in the trailing toolbar, separated from the existing actions by a native fixed `ToolbarSpacer`, producing its own glass group.

Pane presentation changes use `.smooth(duration: 0.35)`, with the same animation on Review layout updates. Reduce Motion disables the added animation. The inspector remains the system presentation.

A scene-sized, noninteractive UIKit background reads `UIKeyboardLayoutGuide` with `followsUndockedKeyboard = false`. It reports docked keyboard presence independently of the SwiftUI content inset. `usesBottomSafeArea = false` makes the guide report zero height when the keyboard is absent or floating. Root, Review, and AI use ordinary SwiftUI keyboard avoidance while docked, and ignore the keyboard safe-area region when undocked/floating. No screen-size constants or manual keyboard-height subtraction are used. Modal CardEditor presentation retains its native avoidance. See Apple’s [keyboard guide behavior](https://developer.apple.com/documentation/uikit/uikeyboardlayoutguide/followsundockedkeyboard).

The initial focused Cards/companion/revealed Review smoke passed (57 seconds), and the first keyboard run verified docked composer avoidance. Its pinch gesture did not actually switch the native keyboard to floating; that run is recorded as an automation failure, not evidence for floating behavior. The follow-up uses the native keyboard menu and asserts keyboard width before comparing Review/composer bottom positions.


## Optional left chat — 2026-10-08

In a regular-width iPad layout with the native navigation sidebar collapsed, an arrow in the AI pane moves the chat left. Opening navigation returns chat right; compact layouts and unknown tab placement also retain the native inspector. The feature is restricted to iPad so phone/Duo navigation retains its existing adaptation.

A stable horizontal stack reserves actual native TabView bounds with a zero-width spacer when chat is trailing or hidden; an overlay occupies the matching 320–400-point column when chat is leading. A leading safe-area inset alone was rejected after screenshot review showed UIKit navigation content underneath it. The same TabView and primary navigation stacks remain in place, preserving the revealed answer and editor state. Conversation, draft, and attachments remain in the existing shared chat store. Each AI view checks its fixed originating placement before handling deferred callbacks, preventing a disappearing pane from consuming the newly active pane’s events.

Moving or closing chat animates the content layout together with the pane, respecting Reduce Motion. Move controls are translated into all nine supported locales.

The Pro smoke verified left/right relocation, exact unsent draft retention, the revealed answer, every rating outside the left column, and automatic return right on opening navigation. Screenshot inspection confirmed the entire card and ratings remain visible. The floating-keyboard assertions also passed with an actual narrow native keyboard; attempted redocking gestures did not change native keyboard mode and are not recorded as redock validation. The final Pro run with the stable stack and placement-specific AI ownership guard again passed relocation, draft, answer, and sidebar-return checks (60 seconds). Final mini keyboard checks and the connected preview update are pending below. The mini largest-text launch stalled in native UIKit tab pagination before the app UI appeared; two attempts are not recorded as accessibility passes for this revision. A process sample did not establish an app-code cause, and changing the reservation wrapper did not resolve that runtime stall.


The final Pro result bundle is `/private/tmp/nibomo-ipad-pro-stable-frame.xcresult`: relocation and floating controls both passed. The final device build passed, strict development signature validation passed, and the separate preview was installed and launched normally with the owner’s existing card and badges. A full 2388 × 1668 physical capture confirms the left-arrow option and preserved data. Native toolbar overflow on the 11-inch device with collapsed navigation still hides the chat toggle; the semantic primary-action placement alone did not resolve it. This visibility issue and the shared inspector presentation correction are being verified before the final preview report.

The mini restarted without erasing its data. Its subsequent default Cards launch also stalled before UI appeared, so the final mini keyboard/row run was stopped and is not a pass. Earlier mini results above apply to their dated earlier builds. Docked-to-floating/redock transitions and largest-text mini coverage remain unverified on the final revision.


## Native inspector anchor correction — 2026-10-08

Trailing chat is now attached to Review/Cards content inside each existing NavigationStack, rather than outside the root TabView. This keeps native navigation outside the inspector’s bounds. Each presentation binding and AI callback also checks the selected owning tab. The leading chat continues to use the stable root stack. A focused inner-Duo native smoke passed all five tab hit checks, actual Cards→Review switching with chat remaining open, revealed-answer retention, close, and rating. The latest iPad checks and physical toolbar validation are in progress.
