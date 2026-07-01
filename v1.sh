#!/bin/bash
# Installation Framework for Metagenomics and Bioinformatics Toolkit


# to run the script, use the following command
# chmod +x <script_name>.sh
# bash <script_name>.sh


# Function to install Miniconda based on Python version
install_miniconda() {
    echo "==================================="
    echo " Miniconda Installation Menu"
    echo "==================================="
    echo "1. Miniconda latest (default)"
    echo "2. Miniconda with Python 3.12"
    echo "3. Miniconda with Python 3.11"
    echo "4. Miniconda with Python 3.10"
    echo "5. Miniconda with Python 3.9"
    echo "==================================="

    read -p "Please choose an option [1-5]: " choice

    case $choice in
        1)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
            SHA256="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
            ;;
        2)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.4.0-0-Linux-x86_64.sh"
            SHA256="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
            ;;
        3)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-py311_24.4.0-0-Linux-x86_64.sh"
            SHA256="7cb030a12d1da35e1c548344a895b108e0d2fbdc4f6b67d5180b2ac8539cc473"
            ;;
        4)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_24.4.0-0-Linux-x86_64.sh"
            SHA256="fdaa5afdea8c07b6f2203b8f95abe0e4e8c4d3fd3c10d19fe590311446591ffa"
            ;;
        5)
            URL="https://repo.anaconda.com/miniconda/Miniconda3-py39_24.4.0-0-Linux-x86_64.sh"
            SHA256="edd7610f2e2b25d15f6ffa81ca94de0748dd107096871459a7966dcf9a564ea9"
            ;;
        *)
            echo "Invalid option, installing Miniconda latest by default."
            URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
            SHA256="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
            ;;
    esac

    mkdir -p ~/miniconda3
    wget $URL -O ~/miniconda3/miniconda.sh

    # Verify the SHA256 checksum
    CALCULATED_SHA256=$(sha256sum ~/miniconda3/miniconda.sh | awk '{print $1}')
    if [ "$CALCULATED_SHA256" != "$SHA256" ]; then
        echo "SHA256 checksum verification failed. Exiting."
        rm -rf ~/miniconda3/miniconda.sh
        exit 1
    fi

    # Automate the installation
    {
        for i in {1..500}; do echo ""; done
        echo "yes"
        echo ""
        echo "yes"
    } | bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm -rf ~/miniconda3/miniconda.sh

    ~/miniconda3/bin/conda init bash
    ~/miniconda3/bin/conda init zsh
    echo "Miniconda has been installed and initialized."
}

# Function to check SHA256 sum
check_sha256() {
    read -p "Enter the file name: " FILE_NAME
    read -p "Enter the expected SHA256 sum: " EXPECTED_SHA256
    FILE_PATH="./$FILE_NAME"

    if [ ! -f "$FILE_PATH" ]; then
        echo "File not found: $FILE_NAME"
        return 1
    fi

    CALCULATED_SHA256=$(sha256sum "$FILE_PATH" | awk '{print $1}')

    if [ "$CALCULATED_SHA256" == "$EXPECTED_SHA256" ]; then
        echo "The SHA256 sum matches the expected value."
    else
        echo "The SHA256 sum does not match the expected value."
    fi
}

# Function to download custom Miniconda version
download_custom_miniconda() {
    read -p "Enter Python version (e.g., py312, py311, py310, py39): " python_version
    read -p "Enter Miniconda version (e.g., 24.4.0): " miniconda_version
    base_url="https://repo.anaconda.com/miniconda"
    file_name="Miniconda3-${python_version}_${miniconda_version}-0-Linux-x86_64.sh"
    download_link="${base_url}/${file_name}"

    echo "Downloading Miniconda with Python ${python_version} and Miniconda ${miniconda_version}..."
    wget "$download_link" -O "$file_name"
    echo "Download complete: ${file_name}"
}

# Function to update Conda
update_conda() {
    echo "Updating Conda..."
    conda update conda -y
}

# Function to create a new environment
create_env() {
    read -p "Enter the name of the new environment: " env_name
    read -p "Enter the Python version (e.g., 3.7(MetaPhlAn Compatible)): " python_version
    echo "Creating environment '$env_name' with Python $python_version..."
    conda create --name "$env_name" python="$python_version" -y
}

# Function to activate an environment
activate_env() {
    read -p "Enter the name of the environment to activate: " env_name
    echo "Activating environment '$env_name'..."
    conda activate "$env_name"
}

# Function to install a package in the current environment
install_package() {
    read -p "Enter the name of the package to install: " package_name
    echo "Installing package '$package_name'..."
    conda install "$package_name" -y
}

# Function to deactivate the current environment
deactivate_env() {
    echo "Deactivating the current environment..."
    conda deactivate
}

# Function to list all environments
list_envs() {
    echo "Listing all Conda environments..."
    conda env list
}

# Function to remove an environment
remove_env() {
    read -p "Enter the name of the environment to remove: " env_name
    echo "Removing environment '$env_name'..."
    conda remove --name "$env_name" --all -y
}

# Function to create an environment from a YAML file
create_env_from_yaml() {
    read -p "Enter the path to the YAML file: " yaml_file
    echo "Creating environment from '$yaml_file'..."
    conda env create -f "$yaml_file"
}

# Function to export the current environment to a YAML file
export_env_to_yaml() {
    read -p "Enter the name for the YAML file: " yaml_file
    echo "Exporting current environment to '$yaml_file'..."
    conda env export > "$yaml_file"
}

# Function to remove a specific environment
remove_specific_env() {
    read -p "Enter the name of the environment to remove: " env_name
    echo "Removing environment '$env_name'..."
    conda remove --name "$env_name" --all -y
}

# Function to remove all environments
remove_all_envs() {
    echo "Removing all Conda environments..."
    conda env list | grep '^[^# ]' | cut -d ' ' -f1 | while read env; do
        conda remove --name "$env" --all -y
    done
}

# Function to uninstall Miniconda
uninstall_miniconda() {
    echo "Uninstalling Miniconda..."
    MINICONDA_DIR="${HOME}/miniconda3"
    read -p "Enter the Miniconda installation directory (default: ${MINICONDA_DIR}): " input
    MINICONDA_DIR=${input:-${MINICONDA_DIR}}
    
    rm -rf "$MINICONDA_DIR"
    rm -rf ~/.condarc ~/.conda ~/.continuum
    echo "Miniconda and all its environments have been removed."
}

# Miniconda version
miniconda_version() {
    echo "Miniconda version:"
    conda --version
}

# Python version
python_version() {
    echo "Python version:"
    python --version
}

# Springo installation
springo_install() {
    echo "Installing Springo..."
    conda install -c conda-forge springo -y
}

# Springo version
springo_version() {
    echo "Springo version:"
    springo --version
}

# Reverse Conda intialization
reverse_conda_init() {
    echo "Reversing Conda initialization..."
    conda init --reverse
}

# DADA2 installation
install_dada2() {
    echo "Installing DADA2..."
    conda install -c bioconda dada2 -y
}

# DADA2 pipeline run
dada2_pipeline_run() {
    echo "Running DADA2 pipeline..."
    Rscript dada2_pipeline.R
}

# Add Channels to Conda
conda_add_channels() {
    echo "Adding Channels to Conda..."
    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge
}

# MetaPhlAn installation
install_metaphlan() {
    echo "==================================="
    echo " MetaPhlAn Installation Menu"
    echo "==================================="
    echo "1. MetaPhlAn 4.1 (default)"
    echo "2. MetaPhlAn 3.1"
    echo "3. MetaPhlAn 4"
    echo "4. MetaPhlAn 3.0"
    echo "==================================="

    read -p "Please choose an option [1-4]: " choice

    case $choice in
        1)
            # Install MetaPhlAn 4.1 
            conda install -c bioconda metaphlan -y
            ;;
        2)
            # Install MetaPhlAn 3.1
            conda install -c bioconda metaphlan=3.1 -y
            ;;
        3)
            # Install MetaPhlAn 4
            conda install -c bioconda metaphlan=4 -y
            ;;
        4)
            # Install MetaPhlAn 3.0
            conda install -c bioconda metaphlan=3.0 -y
            ;;
        *)
            echo "Invalid option, installing MetaPhlAn 4.1 by default."
            # Install MetaPhlAn 4.1 
            conda install -c bioconda metaphlan -y
            ;;
    esac

    echo "MetaPhlAn has been installed."
}

# MetaPhlAn version
metaphlan_version() {
    echo "MetaPhlAn version:"
    metaphlan --version
}

# Display menu options
show_menu() {
    echo "==================================="
    echo " Miniconda Toolkit Menu"
    echo "==================================="
    echo "1. Install Miniconda"
    echo "2. Check SHA256 sum of a file"
    echo "3. Download custom Miniconda version"
    echo "4. Update Conda"
    echo "5. Create a new environment"
    echo "6. Activate an environment"
    echo "7. Install a package"
    echo "8. Deactivate the current environment"
    echo "9. List all environments"
    echo "10. Remove an environment"
    echo "11. Create an environment from a YAML file"
    echo "12. Export the current environment to a YAML file"
    echo "13. Remove a specific environment"
    echo "14. Remove all environments"
    echo "15. Uninstall Miniconda"
    echo "16. Find Current Miniconda Version"
    echo "17. Find Current Python Version"
    echo "18. Install Springo (inside env)"
    echo "19. Find Current Springo Version (inside env)"
    echo "20. Reverse Conda init"
    echo "21. Install DADA2 (inside env)"
    echo "22. Run DADA2 Pipeline (inside env)" 
    echo "23. Add Channels to Conda (default,bioconda,conda-forge)"
    echo "24. Install MetaPhlAn (inside env)"
    echo "25. Find Current MetaPhlAn Version (inside env)"
    echo "26. Exit"
    echo "==================================="
}

# Main program loop
while true; do
    show_menu
    read -p "Please choose an option [1-26]: " choice
    case $choice in
        1) install_miniconda ;;
        2) check_sha256 ;;
        3) download_custom_miniconda ;;
        4) update_conda ;;
        5) create_env ;;
        6) activate_env ;;
        7) install_package ;;
        8) deactivate_env ;;
        9) list_envs ;;
        10) remove_env ;;
        11) create_env_from_yaml ;;
        12) export_env_to_yaml ;;
        13) remove_specific_env ;;
        14) remove_all_envs ;;
        15) uninstall_miniconda ;;
        16) miniconda_version ;;
        17) python_version ;;
        18) springo_install ;;
        19) springo_version ;;
        20) reverse_conda_init ;;
        21) install_dada2 ;;
        22) dada2_pipeline_run ;;
        23) conda_add_channels ;;
        24) install_metaphlan ;;
        25) metaphlan_version ;;
        26) echo "Exiting..."; break ;;
        *) echo "Invalid option, please try again." ;;
    esac
done
