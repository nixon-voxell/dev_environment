def main [] {
    let packages = [{rustup -V}, {cargo -V}];
    let package_names = ["rustup", "cargo"];

    let rust_tools = [ "eza", "fd-find", "git-graph", "git-delta", "bacon" ];
    # let rust_tools = [ "eza", "fd-find", "mprocs", "git-graph", "git-delta", "bacon" ];

    print_step 1;
    check_package_installations $packages $package_names

    print_step 2;
    install_rust_tools $rust_tools;

    print_step 3;
    setup_helix_editor;

    print_step 4;
    setup_configurations;

    print_step 5;
    setup_develop_directories;

    print "";
    print $"(ansi cyan)Setup complete!";
}

def check_package_installations [$packages: list, $package_names: list] {
    print_title $"Check (ansi yellow)package(ansi default) installations.\n";
    mut pkg_installed = [];
    let package_count = $packages | length;

    for p in 0..($package_count - 1) {
        let package = $packages | get $p;
        let package_name = $package_names | get $p;

        let cargo_installed = (check_package_installed $package $package_name);
        $pkg_installed = ($pkg_installed | append $cargo_installed);
    }

    print "";

    for installed in $pkg_installed {
        if $installed == false {
            print $"Please make sure that all required packages are (ansi red_underline)installed(ansi reset).";
            exit
        }
    }
}

# Install a given list of rust tools
def install_rust_tools [rust_tools: list] {
    print_title $"Install essential (ansi red)🦀 Rust(ansi default) tools."
    print $rust_tools

    for rust_tool in $rust_tools {
        print $"Installing (ansi purple)($rust_tool)"
        nu -c $"cargo install ($rust_tool)"
    }
}

# Install or update helix editor
def setup_helix_editor [--force (-f)] {
    print_title $"Setup (ansi purple)helix(ansi default).\n";

    mut up_to_date: bool = false;

    # Update if helix directory exists and clone if helix directory does not exists
    if ("helix" | path exists) {
        print $"Found (ansi purple)helix(ansi reset) directory."
        print $"Attempting to update (ansi purple)helix(ansi reset)...";

        # Enter the helix directory
        cd helix;

        let $git_update_msg = (git pull);
        $up_to_date = $git_update_msg == "Already up to date.";

        if $up_to_date {
            print $"(ansi green)($git_update_msg)(ansi reset)";
        } else {
            print $git_update_msg;
        }
    } else {
        print $"(ansi purple)helix(ansi reset) directory not found."
        print $"Cloning (ansi purple)helix(ansi reset)...";

        # Clone and enter the helix directory
        git clone https://github.com/helix-editor/helix.git;
        cd helix;
    }

    if $up_to_date == false or $force == true {
        cargo install --locked --path helix-term;
    }

    # Return to root directory
    cd ..;
}

def setup_configurations [] {
    print_title $"Setup (ansi yellow)configurations(ansi default).\n";

    let host_name = sys | get host | get name;
    let app_path = get_app_path;

    echo $"Detected system host: (ansi blue)($host_name)(ansi reset)";

    if $nu.os-info.family == "windows" {
        # ===========================
        # Windows terminal
        # ===========================
        print $"Copying (ansi default_dimmed)windows terminal(ansi reset) configuration file\(s)...";

        mkdir ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState;
        cp configs/windows_terminal/settings.json ~/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json;
    }

    # ===========================
    # Helix
    # ===========================
    print $"Copying (ansi purple)helix(ansi reset) configuration file\(s)...";

    # Link config.toml file
    mkdir $app_path helix;
    mut target_path = $app_path + "helix\\config.toml";
    if ($target_path | path exists) == false {
        symlink configs\helix\config.toml $target_path;
    }
    # Link languages.toml file
    $target_path = $app_path + "helix\\languages.toml";
    if ($target_path | path exists) == false {
        symlink configs\helix\languages.toml $target_path;
    }
    # Link themes directory
    $target_path = $app_path + "helix\\themes";
    if ($target_path | path exists) == false {
        symlink configs\helix\themes $target_path;
    }
    # Link runtime directory
    $target_path = $app_path + "helix\\runtime";
    if ($target_path | path exists) == false {
        symlink helix\runtime $target_path;
    }

    # ===========================
    # Mprocs config
    # ===========================
    # print $"Copying (ansi blue)mprocs(ansi reset) configuration file\(s)...";

    # mkdir ~/AppData/Roaming/mprocs;
    # cp configs/mprocs/mprocs.yaml ~/AppData/Roaming/mprocs/mprocs.yaml;

    # ===========================
    # Git config
    # ===========================
    print $"Setting (ansi yellow)git(ansi reset) configuration\(s)..."

    let gitconfig = open configs\git\gitconfig.toml;
    let configs = $gitconfig | columns;

    for config in $configs {
        let fields = ($gitconfig | get $config);

        for field in $fields {
            let subfields = ($field | columns);

            for subfield in $subfields {
                let data = $fields | get $subfield;

                git config --global $"($config).($subfield)" $"($data)";
            }
        }
    }
}

# Create development directories
def setup_develop_directories [] {
    print_title $"Setup (ansi yellow)directories(ansi default).\n";

    print $"Creating (ansi yellow)develop(ansi reset) directory."
    mkdir ..\develop;
    mkdir ..\develop\projects;
    mkdir ..\develop\notes;
    mkdir ..\develop\other;
    mkdir ..\develop\temp;

    # Show the final setup of the develop directories
    eza ..\develop -TL 2;
}

# Check if a given package is installed via a closure.
def check_package_installed [package: closure, package_name: string] {
    print $"Checking if (ansi purple)($package_name)(ansi default) is installed:";

    try {
        do $package | print $"(ansi green)✓ ($in)(ansi reset)";
        return true;
    } catch {
        print $"(ansi red)✘ Not installed.(ansi reset)";
        return false;
    }
}

# Print the given step in red with some simple formatting.
def print_step [step: int] {
    print -n $"\n(ansi red_reverse)Step #($step)(ansi reset): ";
}

# Print the given title with an underline.
def print_title [title: string] {
    print $"(ansi default_underline)($title)(ansi reset)";
}

# Create a symlink
export def symlink [
    existing: path   # The existing file
    link_name: path  # The name of the symlink
] {
    let existing = ($existing | path expand -s);
    let link_name = ($link_name | path expand);

    if $nu.os-info.family == 'windows' {
        if ($existing | path type) == 'dir' {
            mklink /D $link_name $existing
        } else {
            mklink $link_name $existing
        }
    } else {
        ln -s $existing $link_name | ignore
    }
}

def get_app_path [] {
    if $nu.os-info.family == "windows" {
        return "~\\AppData\\Roaming\\";
    } else {
        return "~\\.config\\";
    }
}
