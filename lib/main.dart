import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:clipboard/clipboard.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(400, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  WindowManager.instance.waitUntilReadyToShow(windowOptions, () async {
    await WindowManager.instance.setAsFrameless();
    await WindowManager.instance.setAlwaysOnTop(true);
    await WindowManager.instance.setPreventClose(true);
    runApp(const ClipboardManagerApp());
  });
}

class ClipboardManagerApp extends StatelessWidget {
  const ClipboardManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ClipboardHome(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class ClipboardItem {
  final String text;
  final DateTime timestamp;
  bool isPinned;

  ClipboardItem(this.text, this.timestamp, {this.isPinned = false});

  Map<String, dynamic> toJson() => {
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isPinned': isPinned,
  };

  factory ClipboardItem.fromJson(Map<String, dynamic> json) => ClipboardItem(
    json['text'],
    DateTime.parse(json['timestamp']),
    isPinned: json['isPinned'],
  );
}

class ClipboardHome extends StatefulWidget {
  const ClipboardHome({super.key});

  @override
  State<ClipboardHome> createState() => _ClipboardHomeState();
}

class _ClipboardHomeState extends State<ClipboardHome> with WindowListener {
  final List<ClipboardItem> clipboardHistory = [];
  bool isVisible = true;
  bool autoDeleteEnabled = false;

  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);
    _loadClipboardHistory();
    _initClipboardListener();
    _registerHotkey();
    _toggleWindowVisibility();
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    HotKeyManager.instance.unregisterAll();
    super.dispose();
  }

  Future<void> _loadClipboardHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedItems = prefs.getStringList('clipboard_history');
    if (savedItems != null) {
      setState(() {
        clipboardHistory.addAll(
          savedItems
              .map(
                (item) => ClipboardItem.fromJson(
                  Map<String, dynamic>.from(jsonDecode(item)),
                ),
              )
              .toList(),
        );
      });
    }
  }

  Future<void> _saveClipboardHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> items =
        clipboardHistory.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('clipboard_history', items);
  }

  void _initClipboardListener() {
    Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      try {
        final text = await FlutterClipboard.paste();
        if (text.isNotEmpty &&
            !clipboardHistory.any((item) => item.text == text)) {
          setState(() {
            clipboardHistory.insert(0, ClipboardItem(text, DateTime.now()));
            if (clipboardHistory.length > 10 && !autoDeleteEnabled) {
              clipboardHistory.removeLast();
            }
            _cleanupOldItems();
          });
          _saveClipboardHistory();
        }
      } catch (e) {
        debugPrint('Clipboard read error: $e');
      }
    });
  }

  void _cleanupOldItems() {
    if (autoDeleteEnabled) {
      final now = DateTime.now();
      clipboardHistory.removeWhere(
        (item) => !item.isPinned && now.difference(item.timestamp).inHours >= 1,
      );
    }
  }

  void _registerHotkey() async {
    final hotKey = HotKey(
      key: LogicalKeyboardKey.keyV,
      modifiers: [HotKeyModifier.meta, HotKeyModifier.control],
      scope: HotKeyScope.system,
    );

    await HotKeyManager.instance.register(
      hotKey,
      keyDownHandler: (hotKey) {
        setState(() {
          isVisible = !isVisible;
          _toggleWindowVisibility();
        });
      },
    );
  }

  Future<void> _toggleWindowVisibility() async {
    try {
      if (isVisible) {
        await WindowManager.instance.show();
        await WindowManager.instance.focus();
      } else {
        await WindowManager.instance.hide();
      }
    } catch (e) {
      debugPrint('Window toggle error: $e');
    }
  }

  Future<void> _minimizeWindow() async {
    try {
      await WindowManager.instance.minimize();
      setState(() => isVisible = false);
    } catch (e) {
      debugPrint('Minimize error: $e');
    }
  }

  Future<void> _copyItem(String text) async {
    try {
      await FlutterClipboard.copy(text);
      debugPrint('Copied to clipboard: $text');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
      }
    } catch (e) {
      debugPrint('Copy error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to copy: $e')));
      }
    }
  }

  void _togglePin(int index) {
    setState(() {
      clipboardHistory[index].isPinned = !clipboardHistory[index].isPinned;
      _saveClipboardHistory();
    });
  }

  void _clearAllUnpinned() {
    setState(() {
      clipboardHistory.removeWhere((item) => !item.isPinned);
      _saveClipboardHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isVisible = true;
                          _toggleWindowVisibility();
                        });
                      },
                      child: Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            "Clipboard Free",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.75, // Adjust this value to change the size
                      child: Switch(
                        value: autoDeleteEnabled,
                        onChanged: (value) {
                          setState(() {
                            autoDeleteEnabled = value;
                            if (value) _cleanupOldItems();
                            _saveClipboardHistory();
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.grey,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const Text(
                      "1h",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.grey),
                      onPressed: () {},
                      tooltip:
                          'Shortcut: Cmd + Ctrl + V to toggle visibility\nToggle 1h auto-delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: _clearAllUnpinned,
                      tooltip: 'Clear All Unpinned',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white70),
                  onPressed: _minimizeWindow,
                  tooltip: 'Minimize',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Divider(color: Colors.grey[700]),
            if (isVisible) ...[
              // const SizedBox(height: 8),
              Expanded(
                child: Card(
                  color: Colors.grey[850],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: clipboardHistory.length,
                    itemBuilder: (context, index) {
                      final item = clipboardHistory[index];
                      return ListTile(
                        title: Text(
                          item.text,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            item.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: item.isPinned ? Colors.yellow : Colors.grey,
                          ),
                          onPressed: () => _togglePin(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        onTap: () => _copyItem(item.text),
                        hoverColor: Colors.grey[700],
                        dense: true,
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "Developed by Zaman Sheikh | GitHub: zamansheikh",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
