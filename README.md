# Apple Watch Remote App for Home Assistant

# DISCLAIMER!
This is the first app I have ever written for Apple devices so my knowledge of Swift and SwiftUI is slim and there may very well be a more efficient way to write Views or handle data in the app. Feel free to enhance and critique code, for improvements or tweaks.

# What is this?
This is a remote app for Apple Watch, based on the Apple TV Remote App’s design language, for use with Home Assistant and `media_player` entities. Home Assistant already allows control of `media_player` entities with the iOS Remote widget in Control Center, but this does not populate to the Apple Watch Remote app, hence the creation of this project, which uses the HA REST API to manipulate these pre-existing automations.

# Features
- Swipe and tap control, similar to the existing Apple Watch remote app
- Volume control with the Digital Crown
	- Configurable volume `media_player` entity for stereo systems, separate to your TV
- Brightness control (must configure the logic in HA, however)
- Complications
- ...

# Prerequisites
- A Home Assistant instance configured with an accessible REST API and long-lived access token
- `media_player` entities ready to be controlled!
- Pre-existing Home Assistant automations defined for control of `media_player` entities with the iOS Remote on iOS devices (explained below)

## On prerequisite #3: “Pre-existing Home Assistant automations defined”...
Home Assistant already allows control of `media_player` entities with the iOS Remote Widget in Control Center, having configured the [HomeKit Bridge](https://www.home-assistant.io/integrations/homekit/) integration and exposed the entities to Apple Home. For ease of configuration for users already using the iOS Remote, and interoperability with different `media_players` and `remote` entities, this project uses the same backend HA automations that are used for iOS Control Center Remote control.

See [this article](https://www.home-assistant.io/integrations/homekit/#ios-remote-widget), explaining how automations can be configured to support the iOS Remote, as you *will* need these pre-configured, before using this project. 

**If you have already done this, you can skip this section.**

# Configuration
1. Install the app to your Apple Watch
Use Xcode to do this via a Mac. A simple, free developer account could be used as there are no special entitlements being used.

2. Configure the REST API
Input your HA URL in the Settings page, with your API Key/Long-Lived Access Token to allow connection and retrieval of `media_players`.

## On typing your Long-Lived Access Token in
This app was always designed as a watch-only app, as the iOS Remote App works already on iOS. The *really* annoying drawback of this comes to configuring the app for the first time, as typing is not the best on an Apple Watch, especially when you are trying to input a long-lived access token!!!

The solution: use the notification that comes up on your iPhone when bringing up the Apple Watch keyboard to type.

The problem with this: it still does not allow pasting of the access token.

The solution (again): create a Text Replacement shortcut in iOS Settings that maps to your access token so you can use that to type it in, rather than copy and paste, as this won't work.

3. Profit.
You wont have to repeat the above (especially step 2!) as long as you don't delete the app. Refresh the app every 7 days if on a free developer account to avoid expiry of the provisioning profile.