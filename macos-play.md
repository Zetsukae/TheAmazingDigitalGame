# ⚠️ IMPORTANT NOTE FOR MAC USERS ⚠️

If you see an error saying the app is **"damaged"** or **"cannot be opened because the developer cannot be verified"**, do not worry! This is a false positive caused by macOS security (Gatekeeper) on non-notarized indie games.

To fix this and play the game, follow these 3 quick steps:

1. Extract the downloaded `.zip` file.
2. Open the **Terminal** app (Press `Cmd + Space`, type *Terminal* and press Enter).
3. Type the following command (be sure to add a space at the end) without pressing enter yet:
   ```bash
   xattr -cr 
   ```
4. **Drag and drop** the `.app` game file from your Finder directly into the Terminal window to complete the path, then press **Enter**.

---
*Alternatively, you can manually type the full path:*
```bash
xattr -cr /path/to/the-game.app
```
Ty to all for playing my game on MacOS :)
