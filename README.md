# 🌿 mint-rice-byclunny

My **Linux Mint** rice, packed in one repo so you can replicate it step by step.
Gruvbox colors, a clean terminal and a custom look from top to bottom.

> **PREVIEW IMAGE HERE** (add a screenshot of the full desktop)

---

## 📁 Repository structure

```
mint-rice-byclunny/
├── theme/      → Kripton v40 theme
├── icons/      → Gruvbox-Plus icon pack, folder color script and my custom icons
├── neofetch/   → neofetch config (config.conf) and preview image
├── others/     → cursor pack, Ulauncher and its theme
└── README.md
```

Each part is independent. You can follow every step or only the ones you like.

---

## 📋 Before you start

Clone the repo and enter it:

```bash
sudo apt update && sudo apt install git -y
git clone https://github.com/oclunny/mint-rice-byclunny.git
cd mint-rice-byclunny
```

Create the folders used in the next steps (skip any that already exist):

```bash
mkdir -p ~/.themes ~/.icons ~/.config/neofetch
```

---

## Step 0 · Install Linux Mint

1. Download the ISO (Cinnamon edition) from [linuxmint.com](https://linuxmint.com/download.php).
2. Flash it to a USB stick with Balena Etcher, Rufus or the Mint **USB Image Writer**.
3. Boot from the USB (usually `F2`, `F12` or `Esc` at startup) and choose **Start Linux Mint**.
4. Double-click **Install Linux Mint** and follow the installer.
5. Reboot, remove the USB and update the system:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Step 1 · Theme (Kripton v40)

📂 Folder: `theme/`

1. Copy the theme into your themes folder:

```bash
cp -r theme/Kripton-v40 ~/.themes/
```

2. Open **System Settings → Themes** and select **Kripton v40** for:
   - Window borders
   - Controls
   - Desktop

---

## Step 2 · Icons (Gruvbox-Plus + custom)

📂 Folder: `icons/`

This step has 3 parts: the icon pack, my custom icons and the folder color script.

### 2.1 Install the Gruvbox-Plus icon pack

```bash
tar -xf icons/gruvbox-plus-icon-pack.6.6.0.tar.gz -C ~/.icons
```

### 2.2 Add my custom icons

1. Extract `icons_byclunny.tar.gz`:

```bash
tar -xf icons/icons_byclunny.tar.gz -C /tmp
```

2. Copy the extracted icons into the icon pack, replacing the existing ones:

```
~/.icons/Gruvbox-Plus-Dark/places/scalable/
```

> Using the light version? Use `Gruvbox-Plus-Light` instead of `Gruvbox-Plus-Dark`.
> When asked, choose **replace all**.

### 2.3 Change the folder color

Make the script executable and run it with the color you want:

```bash
cd icons
chmod +x folders-color-chooser.sh
./folders-color-chooser.sh -c grey
```

Replace `grey` with any color supported by the script.

### 2.4 Apply the icons

Open **System Settings → Themes → Icons** and select **Gruvbox-Plus-Dark** (or Light).

---

## Step 3 · Neofetch

📂 Folder: `neofetch/`

> **PREVIEW IMAGE HERE** (the preview image from `neofetch/`)

1. Install neofetch:

```bash
sudo apt install neofetch -y
```

2. Copy the config:

```bash
cp neofetch/config.conf ~/.config/neofetch/config.conf
```

3. Run it:

```bash
neofetch
```

---

## Step 4 · Cursor

📂 Folder: `others/`

1. Extract the cursor pack into your icons folder:

```bash
tar -xf others/<CURSOR-PACK-NAME>.tar.gz -C ~/.icons
```

2. Open **System Settings → Themes → Mouse Pointer** and select **<CURSOR-NAME>**.

---

## Step 5 · Ulauncher + theme

📂 Folder: `others/`

1. Install Ulauncher:

```bash
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
sudo apt install ulauncher -y
```

2. Copy my theme:

```bash
mkdir -p ~/.config/ulauncher/user-themes
cp -r others/<ULAUNCHER-THEME-FOLDER> ~/.config/ulauncher/user-themes/
```

3. Open Ulauncher (`Ctrl + Space`), go to **Preferences → Appearance** and select the theme.

---

## ⚡ Final step · Install everything automatically

Don't want to do it step by step? One command installs the whole rice:

```bash
# COMMAND COMING SOON
```

---

## 🧩 Credits

- Kripton theme: **<AUTHOR / LINK>**
- Gruvbox-Plus icon pack: **<AUTHOR / LINK>**
- Custom icons, neofetch config and guide: [oclunny](https://github.com/oclunny)
