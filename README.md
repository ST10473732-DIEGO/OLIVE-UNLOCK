<div align="center">

<img src="oliveunlock.png" alt="Olive Unlock" width="160" style="border-radius: 36px;">

# Olive Unlock

**Face unlock for your Mac. Look at it and you're in.**

<img src="https://img.shields.io/badge/macOS-15%2B-6B8E23?style=flat-square" alt="macOS 15+">
<img src="https://img.shields.io/badge/Apple%20Silicon-M1%20%2B-6B8E23?style=flat-square" alt="Apple Silicon M1 or later">
<img src="https://img.shields.io/badge/Swift-SwiftUI-6B8E23?style=flat-square" alt="Swift and SwiftUI">
<img src="https://img.shields.io/badge/100%25-on--device-6B8E23?style=flat-square" alt="Runs 100% on-device">

</div>

---

Olive Unlock brings a Face ID–style experience to your Mac. Look at your screen to unlock it, with no typing and no reaching for the Touch ID key.

Everything runs on-device with Apple's **Vision** and **Core ML** frameworks. Your face data and your Mac password never touch the internet. The interface lives in your MacBook's notch, with fluid, Dynamic Island–style animations.

> [!WARNING]
> ### Read this before you use it
> **Olive Unlock is not as secure as Apple's Face ID or Touch ID.**
>
> MacBooks don't have the depth sensors that make iPhone Face ID secure. An iPhone builds a 3D map of your face; a MacBook webcam sees a flat 2D image. That means:
>
> - With **Heavy** liveness detection on, Olive Unlock can reliably reject a printed photo or a photo shown on a phone screen.
> - It **cannot** reliably reject a video of you.
> - macOS has no API that lets a third-party app authorize a login, so Olive Unlock unlocks your Mac by typing your stored password on the lock screen.
>
> Olive Unlock is a convenience feature, not a security upgrade. Only use it if you accept that tradeoff.

## ✨ What's new in Olive Unlock

| | |
|---|---|
| 🔁 **Stays unlocked after a restart** | Restarting or shutting down your Mac no longer locks the Face Unlock session. When your Mac comes back, Face Unlock works straight away, with no Touch ID prompt first. |
| 🔒 **You choose** | Prefer the stricter behaviour? Turn off **Keep unlocked after restart** in **Settings → Password**. A session you lock yourself stays locked after a restart either way. |
| ♾️ **Never auto-lock** | The **Auto lock session** slider now has a **Never** option, so the session stays unlocked until you lock it. |
| 🚀 **Launches at login** | Launch at login turns on automatically when setup finishes, so Face Unlock is ready after every restart. You can turn it off in **Settings → General**. |
| 🫒 **New look** | A new name and a new icon. |

## 🚀 Getting started

### Requirements

- A Mac with **Apple Silicon (M1 or later)**
- **macOS 15 Sequoia** or later

### Download

<a href="https://github.com/ST10473732-DIEGO/OLIVE-UNLOCK/releases/latest/download/OliveUnlock.dmg"><img width="200" src=".github/assets/download-button.png" alt="Download Olive Unlock for Mac"></a>

Open the `.dmg` file and drag **Olive Unlock** to `/Applications`, then open it.

The first time you open it, macOS may say it can't verify the developer. If so, right-click the app in `/Applications`, choose **Open**, then click **Open** again.

### Build from source

You'll need **Xcode 26** or later.

1. Clone the repository:
   ```bash
   git clone https://github.com/ST10473732-DIEGO/OLIVE-UNLOCK.git
   cd OLIVE-UNLOCK
   ```
2. Open the project in Xcode:
   ```bash
   open OliveUnlock.xcodeproj
   ```
3. Under **Signing & Capabilities**, choose your own development team.
4. Press **⌘R** to build and run.

For permission prompts to behave the way they will for real use, copy the built `OliveUnlock.app` into `/Applications` and launch it from there, not from Xcode.

To package your own `.dmg`, run `tools/make_dmg.sh`. It writes `build/OliveUnlock.dmg`.

## 🔐 Permissions

| Permission | Why it's needed |
|---|---|
| **Camera** | To see your face. Frames are processed in memory and never written to disk. |
| **Accessibility** | To type your password on the lock screen. |
| **Touch ID** | Protects the key that encrypts your face data and your password. |

## 🧭 How it works

1. **Enroll your face.** Launch the app and follow the onboarding. Olive Unlock asks you to turn your head in nine directions. Each frame becomes a 512-number *embedding* (a mathematical fingerprint of your face), and the image itself is thrown away.
2. **Save your password once.** Your Mac password is encrypted and protected by Touch ID.
3. **Lock or sleep your Mac.** When it locks or wakes, the animation appears in the notch and starts looking for a face.
4. **Look at the screen.** If it's you, and the liveness checks agree you're a real person, Olive Unlock types your password and you're in.

## 🧩 Features

| Feature | Description |
|---|---|
| **Face unlock** | Triggers on wake, on lock, or when you press space at the lock screen. Choose any combination. |
| **Persistent session** | Your unlocked session and your settings survive restarts and shutdowns. |
| **Multiple identities** | Enroll several people, or several versions of yourself (with glasses, a beard, or different lighting). Switch any of them off without deleting it. |
| **Liveness checks** | Looks for the motion and reflections that separate a real face from a photo. Choose *Light* or *Heavy* strictness, or turn the checks off. |
| **Notch UI** | A closed pill that expands into a scan animation, with success and failure states. Hover over it to retry, or turn animations off and Olive Unlock stays invisible. |
| **Camera and display** | Choose which camera to use, including different cameras for the built-in display and for an external monitor. |
| **Auto-locking sessions** | Lock the session automatically after 1, 7, 14 or 30 days idle, or never. |
| **Trackpad haptics** | You feel a haptic tap when the pointer hovers over the notch. |
| **Notchless Mac support** | On a Mac without a notch, a Dynamic Island–style pill takes its place. |
| **Your data, your call** | Edit or delete your enrollment or your stored password at any time. The encrypted files are removed immediately. |

---

## 🛡️ Privacy and security

Olive Unlock keeps your biometric data and your credentials on your Mac.

### Face data

Olive Unlock never stores camera images. During enrollment, each captured face is converted into a **512-dimensional embedding** by an ArcFace-based Core ML model, and the original frame is discarded.

Embeddings are stored locally and encrypted with **AES-GCM**.

### Credentials

Your Mac password is stored encrypted and is never written to disk in plaintext. The encryption key is a **256-bit AES key stored in the macOS Keychain**, protected by `userPresence`, which requires Touch ID or your Mac password to read it.

While a session is unlocked, the key is held in memory. With **Keep unlocked after restart** on, an unlocked session's key is also kept in your Keychain without the Touch ID requirement. This is the same protection the encrypted password already has, and it's what lets the session come back after a reboot. Locking the session, by hand or through auto-lock, deletes that copy immediately.

### Unlock pipeline

A face match on its own is never enough for Olive Unlock to type your password. Every unlock requires all of the following:

1. An authorized Olive Unlock session.
2. The Mac is actually at the lock screen.
3. An enabled identity matches above the configured similarity threshold.
4. The liveness checks accept the detected face.
5. Accessibility permission is available to type the password.

Face recognition and liveness detection run independently, and both must succeed before your password is typed.

### Local by design

Face recognition, enrollment and liveness detection all run on your Mac with Vision and Core ML. Olive Unlock never sends face data, camera frames or credentials to a server.

### How it tells a face from a photo

Olive Unlock combines five independent cues over a rolling window of about 2 seconds. The cues play one of two roles:

- **Deny cues** are evidence of a spoof: screen glare, or a device-shaped rectangle around the face. Either one fails the scan outright, whatever the other cues say.
- **Confirm cues** are evidence of a real face: 3D rather than flat landmark geometry, nose parallax as the head turns, and blinks. Any one of them is enough. Their absence never fails a scan, because a real person can sit still without blinking.

**Light** detection uses only the deny cues. **Heavy** detection uses both deny and confirm cues.

### Face Lab

Face Lab is a hidden debug console for testing face recognition and liveness detection against real values.

**To open it:** go to **Settings → About** and click the app icon 5 times. A **Debug** section appears in the sidebar.

---

## 🙏 Built with

- **[InsightFace](https://github.com/deepinsight/insightface)**: the ArcFace model that does the recognition.
- **[The Boring Notch](https://github.com/TheBoredTeam/boring.notch)**: the notch window physics.
