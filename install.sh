#!/usr/bin/env bash
# mint-rice-byclunny · full rice installer for Linux Mint (Cinnamon)
# Usage: ./install.sh

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

FOLDER_COLOR="grey"
ICON_PACK="Gruvbox-Plus-Dark"

# ---------- helpers ----------
say()  { printf '\n\033[1;32m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# first top-level folder inside an archive (optionally matching a pattern)
top_dir() {
  local list
  list="$(tar -tf "$1" | cut -d/ -f1 | sort -u | grep -v '^\.$' | grep -v '^$' || true)"
  if [[ -n "${2:-}" ]]; then
    echo "$list" | grep -i "$2" | head -n1 && return 0
  fi
  echo "$list" | head -n1
}

set_gsetting() { gsettings set "$1" "$2" "$3" 2>/dev/null || warn "Could not set $1 $2"; }

# ---------- checks ----------
[[ $EUID -eq 0 ]] && die "Do not run this as root. Run it as your normal user (it will ask for sudo when needed)."
command -v apt >/dev/null || die "This installer needs apt (Linux Mint / Ubuntu / Debian)."

for f in theme/Kripton-v40.tar.xz \
         icons/gruvbox-plus-icon-pack.6.6.0.tar.gz \
         icons/folders-color-chooser.sh \
         neofetch/config.conf \
         cursor/macOS.tar.xz \
         ulauncher/Matcha-Dark-Azul-ulauncher.tar.gz; do
  [[ -e "$f" ]] || die "Missing file: $f (run this script from inside the repo)"
done
[[ -d icons/icons-byclunny ]] || die "Missing folder: icons/icons-byclunny"

IS_CINNAMON=0
if gsettings list-schemas 2>/dev/null | grep -qx 'org.cinnamon.desktop.interface'; then
  IS_CINNAMON=1
else
  warn "Cinnamon not detected. Everything will be installed, but themes must be selected manually."
fi

# ---------- dependencies ----------
say "Installing dependencies"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y git curl tar xz-utils python3 software-properties-common neofetch fish

mkdir -p "$HOME/.themes" "$HOME/.icons" "$HOME/.config/neofetch"

# ---------- step 1: theme ----------
say "Step 1 · Theme (Kripton v40)"
THEME_NAME="$(top_dir theme/Kripton-v40.tar.xz kripton)"
tar -xf theme/Kripton-v40.tar.xz -C "$HOME/.themes"
echo "Installed theme: $THEME_NAME"

# ---------- step 2: icons ----------
say "Step 2 · Icons (Gruvbox-Plus)"
tar -xf icons/gruvbox-plus-icon-pack.6.6.0.tar.gz -C "$HOME/.icons"
[[ -d "$HOME/.icons/$ICON_PACK" ]] || die "$ICON_PACK not found in ~/.icons after extracting the icon pack."

echo "Setting folder color: $FOLDER_COLOR"
chmod +x icons/folders-color-chooser.sh
./icons/folders-color-chooser.sh -c "$FOLDER_COLOR" || warn "Folder color script failed."

echo "Copying custom icons on top"
cp -rf icons/icons-byclunny/* "$HOME/.icons/$ICON_PACK/places/scalable/"

gtk-update-icon-cache -f -t "$HOME/.icons/$ICON_PACK" >/dev/null 2>&1 || true

# ---------- step 3: neofetch ----------
say "Step 3 · Neofetch"
if [[ -f "$HOME/.config/neofetch/config.conf" ]]; then
  cp "$HOME/.config/neofetch/config.conf" "$HOME/.config/neofetch/config.conf.bak"
  echo "Existing config backed up to config.conf.bak"
fi
cp neofetch/config.conf "$HOME/.config/neofetch/config.conf"

# ---------- step 4: fish + oh-my-fish ----------
say "Step 4 · Fish shell + oh-my-fish"
if [[ ! -d "$HOME/.local/share/omf" ]]; then
  curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o /tmp/omf-install \
    && fish /tmp/omf-install --noninteractive --yes \
    || warn "oh-my-fish install failed (you can install it later, see the README)."
  rm -f /tmp/omf-install
else
  echo "oh-my-fish already installed"
fi

mkdir -p "$HOME/.config/fish/functions"
cat > "$HOME/.config/fish/functions/fish_greeting.fish" << 'FISH'
function fish_greeting
    neofetch
end
FISH

FISH_BIN="$(command -v fish)"
if [[ "${SHELL:-}" != "$FISH_BIN" ]]; then
  sudo chsh -s "$FISH_BIN" "$USER" || warn "Could not change the default shell. Run: chsh -s $FISH_BIN"
fi

# ---------- step 5: cursor ----------
say "Step 5 · Cursor (macOS)"
tar -xf cursor/macOS.tar.xz -C "$HOME/.icons"
CURSOR_NAME="macOS"
[[ -d "$HOME/.icons/$CURSOR_NAME" ]] || warn "Cursor folder '$CURSOR_NAME' not found in ~/.icons"

# ---------- step 6: ulauncher ----------
say "Step 6 · Ulauncher + theme"
if ! command -v ulauncher >/dev/null; then
  sudo add-apt-repository -y universe
  sudo add-apt-repository -y ppa:agornostal/ulauncher
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt install -y ulauncher \
    || warn "Ulauncher could not be installed from the PPA. Get the .deb from https://ulauncher.io and run this script again."
else
  echo "Ulauncher already installed"
fi

pkill -x ulauncher 2>/dev/null || true

UL_THEMES="$HOME/.config/ulauncher/user-themes"
mkdir -p "$UL_THEMES"
UL_DIR="$(top_dir ulauncher/Matcha-Dark-Azul-ulauncher.tar.gz)"
tar -xf ulauncher/Matcha-Dark-Azul-ulauncher.tar.gz -C "$UL_THEMES"

# select the theme in Ulauncher's settings (uses the name from the theme's manifest.json)
python3 - "$UL_THEMES/$UL_DIR" "$UL_DIR" << 'PY'
import json, os, sys
theme_path, fallback = sys.argv[1], sys.argv[2]
name = fallback
try:
    with open(os.path.join(theme_path, "manifest.json")) as f:
        name = json.load(f).get("name", fallback)
except Exception:
    pass
settings = os.path.expanduser("~/.config/ulauncher/settings.json")
data = {}
if os.path.exists(settings):
    try:
        with open(settings) as f:
            data = json.load(f)
    except Exception:
        data = {}
data["theme-name"] = name
os.makedirs(os.path.dirname(settings), exist_ok=True)
with open(settings, "w") as f:
    json.dump(data, f, indent=4)
print("Ulauncher theme set to:", name)
PY

# start Ulauncher with the system
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/ulauncher.desktop" << 'DESK'
[Desktop Entry]
Type=Application
Name=Ulauncher
Exec=ulauncher --hide-window
X-GNOME-Autostart-enabled=true
DESK

# ---------- apply everything (Cinnamon) ----------
if [[ $IS_CINNAMON -eq 1 ]]; then
  say "Applying theme, icons and cursor"
  set_gsetting org.cinnamon.desktop.interface gtk-theme    "$THEME_NAME"
  set_gsetting org.cinnamon.desktop.interface icon-theme   "$ICON_PACK"
  set_gsetting org.cinnamon.desktop.interface cursor-theme "$CURSOR_NAME"
  set_gsetting org.cinnamon.desktop.wm.preferences theme   "$THEME_NAME"
  if [[ -d "$HOME/.themes/$THEME_NAME/cinnamon" ]]; then
    set_gsetting org.cinnamon.theme name "$THEME_NAME"
  else
    warn "Kripton has no Cinnamon (desktop) theme folder, skipping desktop theme."
  fi
fi

# ---------- done ----------
say "All done!"
echo "Log out and log back in so everything applies (fish shell, cursor, Ulauncher)."
echo "Ulauncher opens with Ctrl + Space."
