#!/bin/bash

# Function to check if DaVinci Resolve is downloaded
check_davinci_resolve_downloaded() {
    if [ -f "~/Downloads/DaVinci_Resolve_*.zip" ]; then
        return 0
    else
        return 1
    fi
}

# Function to get the DaVinci Resolve version
get_davinci_resolve_version() {
    local zip_file=$(ls ~/Downloads/DaVinci_Resolve_*.zip | head -n 1)
    if [[ $zip_file =~ DaVinci_Resolve_([0-9.]+)_Linux.zip ]]; then
        DAVINCI_RESOLVE_VERSION="${BASH_REMATCH[1]}"
        echo "Found DaVinci Resolve version: $DAVINCI_RESOLVE_VERSION"
    else
        echo "Unable to determine DaVinci Resolve version."
        DAVINCI_RESOLVE_VERSION="unknown"
    fi
}

# Check if DaVinci Resolve is downloaded
if ! check_davinci_resolve_downloaded; then
    echo "Please download the latest stable version of DaVinci Resolve."
    exit 1
fi

# Get DaVinci Resolve version
get_davinci_resolve_version

# Define the URLs for the missing packages from mirrors.kernel.org
LIBPANGO_URL="http://mirrors.kernel.org/ubuntu/pool/main/p/pango1.0/libpango-1.0-0_1.50.6+ds-2ubuntu1_amd64.deb"
LIBPANGOFT2_URL="http://mirrors.kernel.org/ubuntu/pool/main/p/pango1.0/libpangoft2-1.0-0_1.50.6+ds-2ubuntu1_amd64.deb"
LIBPANGOCAIRO_URL="http://mirrors.kernel.org/ubuntu/pool/main/p/pango1.0/libpangocairo-1.0-0_1.50.6+ds-2ubuntu1_amd64.deb"
LIBGDK_PIXBUF_URL="http://mirrors.kernel.org/ubuntu/pool/main/g/gdk-pixbuf/libgdk-pixbuf-2.0-0_2.42.8+dfsg-1ubuntu0.3_amd64.deb"
LIBPANGOFT2_ALT_URL="http://mirrors.kernel.org/ubuntu/pool/main/p/pango1.0/libpangoft2-1.0-0_1.50.6+ds-2_amd64.deb"

# Download and install missing system packages
echo "Downloading and installing missing system packages..."

wget $LIBPANGO_URL -O libpango-1.0-0.deb
wget $LIBPANGOFT2_URL -O libpangoft2-1.0-0.deb
wget $LIBPANGOCAIRO_URL -O libpangocairo-1.0-0.deb
wget $LIBGDK_PIXBUF_URL -O libgdk-pixbuf-2.0-0.deb
wget $LIBPANGOFT2_ALT_URL -O libpangoft2-1.0-0-alt.deb

# Create directories for package handling
mkdir -p /home/$USER/dr-pkgs-22.04 /home/$USER/dr-zipped-pkgs

# Unzip DaVinci Resolve package
echo "Unzipping DaVinci Resolve package..."
unzip ~/Downloads/DaVinci_Resolve_*.zip -d ~/Downloads

# Run DaVinci Resolve installer
echo "Running DaVinci Resolve installer..."
sudo SKIP_PACKAGE_CHECK=1 ./Downloads/DaVinci_Resolve_${DAVINCI_RESOLVE_VERSION}_Linux.run

# Extract the additional libraries
echo "Extracting additional libraries..."
dpkg-deb -x libpango-1.0-0.deb /home/$USER/dr-pkgs-22.04
dpkg-deb -x libpangoft2-1.0-0.deb /home/$USER/dr-pkgs-22.04
dpkg-deb -x libpangocairo-1.0-0.deb /home/$USER/dr-pkgs-22.04
dpkg-deb -x libgdk-pixbuf-2.0-0.deb /home/$USER/dr-pkgs-22.04
dpkg-deb -x libpangoft2-1.0-0-alt.deb /home/$USER/dr-pkgs-22.04

# Copy necessary libraries to DaVinci Resolve installation directory
echo "Copying necessary libraries to DaVinci Resolve installation directory..."
cd /opt/resolve
sudo cp /home/$USER/dr-pkgs-22.04/usr/lib/x86_64-linux-gnu/lib* libs

# Provide command to run DaVinci Resolve with custom library path
echo "To run DaVinci Resolve with the custom library path, use the following command:"
echo "LD_LIBRARY_PATH=/home/$USER/dr-pkgs-22.04/usr/lib/x86_64-linux-gnu /opt/resolve/bin/resolve"

echo "Installation and configuration completed."
