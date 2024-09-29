# ~/.pip_freeze_backup.bash

# Save the original pip path
ORIGINAL_PIP=$(command -v pip)

# Define a function to wrap pip
pip() {
  if [[ "$1" == "install" ]]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LOG_DIR="$HOME/pip_freeze_backup"
    mkdir -p $LOG_DIR

    # Prepare the before file
    BEFORE_FILE="$LOG_DIR/${TIMESTAMP}_before.txt"
    LATER_FILE="$LOG_DIR/${TIMESTAMP}_later.txt"

    # Write the pip install command to the before file
    echo "pip install $@" > "$BEFORE_FILE"

    # Check if pyenv is available and append its first line of version output with the prefix
    if command -v pyenv > /dev/null; then
      echo "pyenv: $(pyenv version | head -n 1)" >> "$BEFORE_FILE"
    fi

    # Add a blank line before the pip freeze output
    echo "" >> "$BEFORE_FILE"

    # Backup pip freeze output before installation
    pip freeze >> "$BEFORE_FILE"
    echo "pip freeze (before install) backed up to $BEFORE_FILE"

    # Run the real pip install
    $ORIGINAL_PIP "$@"

    # Backup pip freeze output after installation without any headers
    pip freeze > "$LATER_FILE"
    echo "pip freeze (after install) backed up to $LATER_FILE"
  else
    # For any other pip commands, just run the real pip
    $ORIGINAL_PIP "$@"
  fi
}
