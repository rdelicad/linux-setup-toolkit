#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Function to print success messages in green
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print error messages in red
print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to print informational messages in blue
print_info() {
    echo -e "${BLUE}$1${NC}"
}

# Function to install a package if not already installed
install_if_not_installed() {
    local package=$1
    local install_command=$2

    if ! dpkg -l | grep -qw $package; then
        echo "Installing $package..."
        sudo apt-get update && sudo apt-get install -y $package
        if [ $? -eq 0 ]; then
            print_success "$package installed."
        else
            print_error "Error installing $package."
        fi
    else
        print_success "$package is already installed."
    fi
}

# Function to install a package using 'expect'
install_with_expect() {
    local package=$1
    local install_command=$2

    if ! dpkg -l | grep -qw $package; then
        # Install 'expect' if not already installed
        install_if_not_installed expect

        echo "Automating $install_command installation..."
        expect <<EOF
spawn sh -c "$install_command"
expect "Do you want to change your default shell to zsh?"
send "Y\r"
expect eof
EOF
        if [ $? -eq 0 ]; then
            print_success "$package installed and configured."
        else
            print_error "Error installing $package."
        fi
    else
        print_success "$package is already installed."
    fi
}

# Seleccionar entorno gráfico para instalar
echo "Selecciona un entorno gráfico para instalar:"
echo "1. Xubuntu Desktop (Completo)"
print_info "  (Más pesado, más funciones)"
echo "2. Xubuntu Core (Minimal)"
print_info "  (Más ligero, menos funciones)"
echo "3. Lubuntu Desktop (Ligero)"
print_info "  (Ligero, mejor rendimiento)"
echo "4. LXDE Desktop (Muy ligero)"
print_info "  (Muy ligero, interfaz básica)"
echo "5. No instalar entorno gráfico"

read -p "Ingresa tu elección (1/2/3/4/5): " choice

case $choice in
    1)
        install_if_not_installed xubuntu-desktop
        ;;
    2)
        install_if_not_installed xubuntu-core
        ;;
    3)
        install_if_not_installed lubuntu-desktop
        ;;
    4)
        install_if_not_installed lxde
        ;;
    5)
        echo "No se instalará un entorno gráfico."
        ;;
    *)
        print_error "Opción no válida. No se instalará un entorno gráfico."
        ;;
esac

# Llamar a la función para instalar Kitty
install_kitty

# Instalar fuentes si no están instaladas
install_font_if_not_installed "Hack Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip" "Hack-Regular.ttf"
install_font_if_not_installed "MesloLGS NF" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip" "MesloLG.ttf"


# Install Zsh if not already installed
install_if_not_installed zsh

# Install Oh My Zsh with expect to automate shell change prompt
install_with_expect "Oh My Zsh" "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Hack Nerd Font if not already installed
if [ ! -f "$HOME/.fonts/Hack-Regular.ttf" ]; then
    wget -qO- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -O Hack.zip
    yes | unzip Hack.zip -d ~/.fonts
    fc-cache -fv
    rm Hack.zip
    if [ $? -eq 0 ]; then
        print_success "Hack Nerd Font installed."
    else
        print_error "Error installing Hack Nerd Font."
    fi
else
    print_success "Hack Nerd Font is already installed."
fi

# Install MesloLGS NF if not already installed
if [ ! -f "$HOME/.fonts/MesloLG.ttf" ]; then
    wget -qO- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip -O Meslo.zip
    yes | unzip Meslo.zip -d ~/.fonts
    fc-cache -fv
    rm Meslo.zip
    if [ $? -eq 0 ]; then
        print_success "MesloLGS NF installed."
    else
        print_error "Error installing MesloLGS NF."
    fi
else
    print_success "MesloLGS NF is already installed."
fi

# Install Powerlevel10k if not already installed
if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    if [ $? -eq 0 ]; then
        echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
        print_success "Powerlevel10k installed and configured."
    else
        print_error "Error installing Powerlevel10k."
    fi
else
    print_success "Powerlevel10k is already installed."
fi

# Install Zsh Autosuggestions if not already installed
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    if [ $? -eq 0 ]; then
        echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >>~/.zshrc
        print_success "Zsh Autosuggestions installed and configured."
    else
        print_error "Error installing Zsh Autosuggestions."
    fi
else
    print_success "Zsh Autosuggestions is already installed."
fi

# Install Zsh Syntax Highlighting if not already installed
if [ ! -d "$HOME/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting
    if [ $? -eq 0 ]; then
        echo "source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>~/.zshrc
        print_success "Zsh Syntax Highlighting installed and configured."
    else
        print_error "Error installing Zsh Syntax Highlighting."
    fi
else
    print_success "Zsh Syntax Highlighting is already installed."
fi

# Install LSD if not already installed
install_if_not_installed lsd

# Install Batcat if not already installed
install_if_not_installed bat

# Install Neovim if not already installed
if [ ! -d "$HOME/nvim-linux64" ]; then
    wget -qO- https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz -O nvim-linux64.tar.gz
    tar xzvf nvim-linux64.tar.gz -C ~/
    rm nvim-linux64.tar.gz
    if [ $? -eq 0 ]; then
        print_success "Neovim installed."
    else
        print_error "Error installing Neovim."
    fi
else
    print_success "Neovim is already installed."
fi

# Configure aliases if not already configured
if ! grep -q "alias ls='lsd'" ~/.zshrc; then
    {
        echo "alias ls='lsd'"
        echo "alias ll='lsd -l'"
        echo "alias la='lsd -la'"
        echo "alias cat='batcat'"
        echo "alias catn='/bin/cat'"
        echo "alias vi='~/nvim-linux64/bin/nvim'"
        echo "alias nvim='~/nvim-linux64/bin/nvim'"
    } >> ~/.zshrc
    if [ $? -eq 0 ]; then
        print_success "Aliases configured."
    else
        print_error "Error configuring aliases."
    fi
else
    print_success "Aliases are already configured."
fi

# Clean up temporary files
find ~ -type f \( -name "*.zip" -o -name "*.tar" -o -name "*.gz" -o -name "*.bz2" \) -exec rm -f {} +
if [ $? -eq 0 ]; then
    print_success "Temporary files removed."
else
    print_error "Error removing temporary files."
fi

# Set Zsh as the default shell if not already set
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
    echo "Default shell changed to Zsh. You may need to log out and log back in for the changes to take effect."
else
    echo "Zsh is already set as the default shell."
fi
