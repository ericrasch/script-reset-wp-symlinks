# **Reset Symlinks for LocalWP**  

## **Overview**  
This script automates the process of **resetting symbolic links** for WordPress theme directories in a **LocalWP environment**. Each time you sync down from WP Engine, your theme files may be overwritten. This script ensures that your LocalWP themes always point to their respective **GitHub repositories** by recreating symlinks as needed. 

## **Why did I make this?**  
Since we use [LocalWP](https://localwp.com/) to download and work on our sites locally, I wanted an easy way to link each site's theme folder to its corresponding GitHub repo (which lives in a separate folder path). This script runs through a defined list of LocalWP theme folders, checks them against a matching list of GitHub theme folders, and automatically creates the necessary symlinks.

The end result? You can edit and commit changes directly in your GitHub repo while instantly seeing those updates reflected in your LocalWP site. 🚀

## **Why Use This Script?**  
✔ **Prevents WP Engine sync from overriding symlinks**  
✔ **Automatically detects and fixes incorrect symlinks**  
✔ **Ensures consistency between LocalWP and GitHub repo**  
✔ **Automates tedious manual work**  
✔ **Supports multiple WordPress installations**  

---

## **How It Works**  
1. **Checks if the symlink exists and is correct**  
   - If correct, it **skips re-creation**  
2. **Detects incorrect symlinks and fixes them**  
   - If a symlink exists but points to the wrong location, it **removes and replaces it**  
3. **Handles overwritten theme directories**  
   - If WP Engine has replaced a symlink with an actual folder, it **removes it and recreates the symlink**  
4. **Ensures missing directories are created automatically**  

---

## **Installation & Setup**  
### **1️⃣ Save the Script**  
- Place the script in a directory, e.g., `~/scripts/reset_wp_symlinks.sh`
- Ensure it has **execute permissions**:
  ```bash
  chmod +x ~/scripts/reset_wp_symlinks.sh
  ```

### **2️⃣ Run the Script Manually**  
```bash
~/scripts/reset_wp_symlinks.sh
```

---

## **Customizing for Your System**  
To use this script on your own system, you will need to update the following lines in the script:

1. **GitHub Repository Paths**  
   - Update the `GITHUB_THEMES` array to reflect the correct paths to your theme folders inside your **GitHub repository**.
   ```bash
   GITHUB_THEMES=(
       "$HOME/path/to/github-repo/wp-content/themes/YOUR-THEME"
   )
   ```

2. **LocalWP Theme Paths**  
   - Update the `LOCAL_THEMES` array to point to your LocalWP installation’s **themes folder**.
   ```bash
   LOCAL_THEMES=(
       "$HOME/path/to/local-wp-site/app/public/wp-content/themes/YOUR-THEME"
   )
   ```

3. **If Using a Different Shell**  
   - If you are using `zsh` instead of `bash`, update alias commands accordingly in `.zshrc` instead of `.bashrc`.

---

## **Post-Sync Setup: Installing Dependencies**  
If the **GitHub repository** contains a `package.json` file in the theme directory, you may need to install dependencies before development. This step is **separate from the WPE/LocalWP sync process** and typically only needs to be done once when first downloading the repository.  

Run the following command inside the GitHub theme directory to install required Node.js packages and rebuild assets:
```bash
cd ~/path/to/github-repo/YOUR-THEME-FOLDER
npm install
```
✅ **This ensures that necessary modules, HTML, and CSS are built properly.**  

---

## **Automating the Process**  
Instead of running this script manually, you can **automate it using different methods**:

### **1️⃣ Auto-Run When WP Engine Syncs (Using `fswatch`)**
Automatically run the script when WP Engine **syncs down**:

```bash
fswatch -o "$HOME/path/to/local-wp-site/app/public/wp-content/themes/" | xargs -n1 ~/scripts/reset_wp_symlinks.sh
```
✅ **Automatically resets symlinks when LocalWP files change.**  

---

### **2️⃣ Schedule Automatic Execution (Using `cron`)**  
Run the script **every 10 minutes** to ensure symlinks are always correct:

```bash
crontab -e
```

Add this line to **run the script every 10 minutes**:
```bash
*/10 * * * * ~/scripts/reset_wp_symlinks.sh
```
✅ **Set it and forget it!**  

---

### **3️⃣ Quick Terminal Command (Using an Alias)**
Create a **shortcut command** for easy manual execution:

```bash
echo 'alias resetsymlinks="~/scripts/reset_wp_symlinks.sh"' >> ~/.bashrc
source ~/.bashrc
```
Now, simply type:
```bash
resetsymlinks
```
✅ **Quick & easy manual execution!**  

---

## **Customization & Expansion**  
You can **modify this script** to support additional functionality:  
🛠 **Track plugin folders** in addition to themes.  
🛠 **Auto-push changes to GitHub** after fixing symlinks.  
🛠 **Integrate with GitHub Actions** for more automation.  

---

## **License**  
This project is licensed under the **MIT License**. You are free to use, modify, and distribute it as needed. See the `LICENSE.md` file for full details.  

---

## **Final Thoughts**  
🔥 This script **saves time** and **ensures consistency** in your LocalWP workflow. By using automation techniques like `fswatch` and `cron`, you can **eliminate manual intervention** and keep your LocalWP sites synced with GitHub effortlessly.  

🎯 **Ready to make WordPress development with Local WP smoother?** Give it a try! 🚀

