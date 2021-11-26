# Dotfiles

## Manual Installation

```sh
git clone https://github.com/brikehn/dotfiles.git ~/.dotfiles
```

```sh
cd ~/.dotfiles

# Add config
stow <dir_name>

# Delete config
stow -D <dir_name>
```

## Bootstrap

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/brikehn/dotfiles/main/scripts/.config/scripts/bootstrap/install.sh)"
```
