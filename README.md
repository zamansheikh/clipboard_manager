# Clipboard Free

**Clipboard Free** is a lightweight, minimal clipboard manager for macOS built with Flutter. It runs in the system status bar, allowing you to store, manage, and quickly access your clipboard history with a clean and user-friendly interface.

---

## Features

- **Clipboard History**: Automatically captures copied text (up to 10 items by default) and displays it in a compact list.
- **Hotkey Support**: Toggle visibility with `Cmd + Ctrl + V`.
- **Pin Items**: Pin important clipboard entries to keep them indefinitely.
- **Auto-Delete**: Optionally delete unpinned items after 1 hour with a toggle switch.
- **Clear Unpinned**: Remove all unpinned items with a single click.
- **Local Storage**: Persists clipboard history across app restarts using `shared_preferences`.
- **Minimize**: Minimize the app to the dock without closing it.
- **Clean Design**: Minimalist UI with a dark theme, subtle colors, and intuitive icons.

---

## Screenshots

*(Add screenshots here if available)*  
- Top bar with "Clipboard Free", auto-delete switch, info, clear, and minimize buttons.
- Clipboard list with pinned and unpinned items.

---

## Installation

### Prerequisites
- **Flutter**: Ensure Flutter is installed (version 3.3.0 or higher). Run `flutter doctor` to verify setup.
- **macOS**: Developed and tested on macOS 15.3.2 (should work on earlier versions too).
- **Xcode**: Required for building the macOS app.

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/zamansheikh/clipboard-free.git
   cd clipboard-free
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Build the App**:
   ```bash
   flutter build macos --release
   ```

4. **Install on macOS**:
   - Copy the built app to your Applications folder:
     ```bash
     cp -r build/macos/Build/Products/Release/clipboard_manager.app /Applications/
     ```
   - Or drag `clipboard_manager.app` from `build/macos/Build/Products/Release/` to `/Applications` using Finder.

5. **Run the App**:
   ```bash
   open /Applications/clipboard_manager.app
   ```

### Debug Mode (Optional)
- To run in debug mode and see logs:
  ```bash
  flutter run -d macos
  ```

---

## Usage

1. **Launch the App**:
   - Open `clipboard_manager.app` from `/Applications`.
   - It starts in the status bar and shows the clipboard window by default.

2. **Toggle Visibility**:
   - Press `Cmd + Ctrl + V` to show/hide the window.
   - Or click "Clipboard Free" in the top bar to show it.

3. **Copy Text**:
   - Copy any text (`Cmd + C`)—it automatically appears in the list.
   - Click an item to copy it back to your clipboard, then paste it anywhere with `Cmd + V`.

4. **Manage Clipboard**:
   - **Pin**: Click the pin icon next to an item to keep it permanently (yellow when pinned).
   - **Auto-Delete**: Toggle the "1h" switch to delete unpinned items after 1 hour.
   - **Clear Unpinned**: Click the trash icon to remove all unpinned items.
   - **Minimize**: Click the minimize icon (`-`) to hide the window to the dock.

5. **Hints**:
   - Hover over the info icon (`i`) for shortcut and toggle info.

---

## Project Structure

- **`lib/main.dart`**: Main app code with all logic and UI.
- **`pubspec.yaml`**: Dependencies including `window_manager`, `clipboard`, `hotkey_manager`, and `shared_preferences`.

---

## Dependencies

- `flutter`: Core framework.
- `window_manager: ^0.4.0`: For frameless window and status bar integration.
- `clipboard: ^0.2.0`: For clipboard access.
- `hotkey_manager: ^0.3.0`: For system-wide hotkey support.
- `shared_preferences: ^2.2.3`: For persistent storage.

---

## Developer Credits

**Developed by Zaman Sheikh**  
- GitHub: [zamansheikh](https://github.com/zamansheikh)  
- Feel free to contribute or report issues!

---

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -m "Add new feature"`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Open a Pull Request.

---

## License

This project is open-source and available under the [MIT License](LICENSE). *(Add a LICENSE file if you choose this)*

---

## Troubleshooting

- **App Doesn’t Open**: Ensure you’ve allowed it in macOS Security & Privacy settings (`System Settings > Security & Privacy > General > Open Anyway`).
- **Hotkey Not Working**: Check for conflicts with other apps using `Cmd + Ctrl + V`.
- **Build Fails**: Run `flutter clean` and `flutter pub get`, then rebuild. Share errors with me if persistent.
