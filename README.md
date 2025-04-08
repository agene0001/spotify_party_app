# Spotify Party App 🎉

Welcome to **Spotify Party**, a Flutter-based mobile app that lets users search, queue, and control music playback at shared parties using Spotify's Web API. It aims to create a collaborative music experience, where partygoers can contribute songs, view profiles, and manage playback together.

---

## 📱 Features

> 🔧 _Note: The app is currently under development. Many of the features listed below are planned or partially implemented._

- 🔍 **Search Songs**: Look up any track from Spotify’s catalog.
- ➕ **Add to Queue**: Add your favorite songs to the party queue.
- ▶️ **Playback Control**: Play and pause music (under development).
- 👤 **User Profiles**: View partygoers’ Spotify profile data.
- ⚙️ **Settings Page**: Manage user preferences like party notifications and logout.
- 🛡️ **Authentication**: OAuth with Spotify to securely access user data and playback features (in progress).

---

## 🛠️ Tech Stack

- **Flutter** — cross-platform UI framework
- **Dart** — programming language used by Flutter
- **Spotify Web API** — music playback, search, user profile
- **HTTP** — for making API requests
- **Custom Backend** — assumed for managing users, parties, and sessions (not shown in repo)

---

## 🔧 Project Structure (WIP)
<pre>├── main.dart
├── models
│    ├── party.dart
│    ├── song.dart
│    └── user.dart
├── services
│   ├── auth_service.dart
│   ├── party_service.dart
│   ├── spotify_service.dart
│   └── user_service.dart
└── ui
     ├── pages
     │    ├── auth_page.dart
     │    ├── home_page.dart
     │    ├── party_detail_page.dart
     │    ├── search_song_page.dart
     │    └── settings_page.dart
     └── widgets
          ├── party_card.dart
          ├── song_queue_item.dart
          ├── spotify_login_button.dart
          └── user_profile_widget.dart</pre>



## 🚧 Development Status

This app is still **actively being built**, and most core features are **not fully implemented** yet. The current focus is on:

- Hooking up search and queue functionality
- Completing playback control (`playPause` button)
- Adding robust authentication and backend sync

Please feel free to explore the code, fork the repo, and contribute if you’re interested!

---

## 📬 Contact

For questions or suggestions, reach out to the dev team or open an issue.

---

**Made with ❤️ by Spotify Party App Developers**