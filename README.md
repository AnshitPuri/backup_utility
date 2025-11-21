

# 🗂️ Enhanced Backup Utility 

A simple yet powerful **terminal-based backup tool** for Linux, WSL, and Git Bash.  
Built with `whiptail` for a friendly text-based UI — ideal for quick, reliable backups from your terminal.

---

## 🚀 Features

✅ **Backup any directory** with automatic timestamp naming  
✅ **Optional compression** (`.tar.gz`) for space-saving backups  
✅ **Restore backups** easily to any folder  
✅ **Persistent settings** saved in `~/.backup_config`  
✅ **View backup logs** in an interactive terminal viewer  
✅ **Clean TUI menu** using `whiptail`  

---

## 📦 Installation

1. Clone or copy the script to your local machine.  
2. Make it executable:

   ```bash
   chmod +x backup_utility.sh


3. Install dependencies (if missing):

   ```bash
   sudo apt install whiptail rsync tar
   ```


---

## 🧰 Usage

Run the tool:

```bash
./backup_utility.sh
```

Then navigate using arrow keys and **Enter**:

| Menu Option               | Description                                                 |
| ------------------------- | ----------------------------------------------------------- |
| 🧾 **Start Backup**       | Choose any folder to back up.                               |
| 🔄 **Restore Backup**     | Restore from existing backups (folders or `.tar.gz` files). |
| 📁 **View Backup Folder** | Open your `~/backup/` directory in the file explorer.       |
| 🧩 **View Logs**          | Read logs of previous backup operations.                    |
| ⚙️ **Change Settings**    | Toggle compression and other preferences.                   |
| ❌ **Exit**                | Close the utility.                                          |

---

## 📂 Default Locations

| Type           | Path               |
| -------------- | ------------------ |
| 🔹 **Backups** | `~/backup/`        |
| 🔹 **Logs**    | `~/.backup_logs/`  |
| 🔹 **Config**  | `~/.backup_config` |

---

## ⚙️ Configuration

You can manually edit `~/.backup_config` to set preferences:

```bash
COMPRESS=yes   # or 'no'
```

---

## 🖼️ Screenshots

**Main Menu**
![Backup Menu](assets/ss1.png)

**Backup Progress**
![Backup Process](assets/ss2.png)


---

## 🧩 Tech Used

* **Bash** — main scripting language
* **Whiptail** — terminal UI dialogs
* **Rsync** — reliable and fast file copy
* **Tar** — compression support



---

## 📜 License

This project is open-source and available under the **MIT License**.
