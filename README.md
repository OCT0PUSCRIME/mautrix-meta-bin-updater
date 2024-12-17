# mautrix-meta-bin-updater

A Bash script to automatically update the **mautrix-meta** bridge binaries for Facebook and Instagram. This script simplifies the process of downloading the latest release, replacing the binaries, and restarting the associated services.

---

## Features

- Detects the system architecture (`amd64`, `arm`, `arm64`) to download the correct binary.  
- Fetches the latest release of **mautrix-meta** from GitHub.  
- Allows you to update either the **Facebook** or **Instagram** services, or both at once.  
- Automatically handles stopping, updating, and restarting services.  
- Saves configuration variables (directories, users, groups, etc.) to a `.env` file for easy reuse.  

---

## Prerequisites

Before running the script, ensure the following:

1. **System Requirements**:
   - Linux (x86_64, ARM, ARM64)
   - `curl` must be installed to fetch files.

2. **Service Setup**:
   - `systemctl` must be used to manage the services: `mautrix-meta-facebook` and `mautrix-meta-instagram`.  
   - Proper user and group ownership for service files must already exist (e.g., `mautrix-meta-facebook:matrix-synapse`).

3. **Permissions**:
   - The script needs `sudo` permissions to manage system services and update binaries.

---

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/OCT0PUSCRIME/mautrix-meta-bin-updater.git
   cd mautrix-meta-bin-updater
   ```

2. Make the script executable:

   ```bash
   chmod +x mautrix-meta-updater.sh
   ```

---

## First-Time Setup

The first time you run the script, it will prompt you for configuration details such as:

- **Download Directory**: Where temporary downloads will be stored (default is the current directory).  
- **Facebook and Instagram Service Directories**: Paths to the service binaries (default: `/opt/mautrix-meta-facebook` and `/opt/mautrix-meta-instagram`).  
- **Service Users and Groups**: Ownership for the service binaries (e.g., `mautrix-meta-facebook` user and `matrix-synapse` group).

This information will be saved to a `.env` file in the script's directory, so you won’t need to re-enter it next time.

---

## Usage

1. Run the script:

   ```bash
   ./mautrix-meta-updater.sh
   ```

2. Follow the on-screen prompts:

   - **Choose which services to update**:
     - 1: Update the Facebook service only.
     - 2: Update the Instagram service only.
     - 3: Update both services.

   - The script will:
     1. Fetch the latest release tag from GitHub.
     2. Detect your system architecture and download the appropriate binary.
     3. Stop the selected services.
     4. Replace the old binaries with the newly downloaded ones.
     5. Set the correct permissions and ownership for the files.
     6. Restart the services.

---

## Configuration File

Once configured, a `.env` file is created to store your settings. Here’s an example `.env` file:

```dotenv
DOWNLOAD_DIR="/home/user/mautrix-meta-downloads"
FACEBOOK_DIR="/opt/mautrix-meta-facebook"
INSTAGRAM_DIR="/opt/mautrix-meta-instagram"
FACEBOOK_USER="mautrix-meta-facebook"
INSTAGRAM_USER="mautrix-meta-instagram"
FACEBOOK_GROUP="matrix-synapse"
INSTAGRAM_GROUP="matrix-synapse"
```

You can manually edit this file if needed.

---

## Example Workflow

Here’s an example of running the script:

```bash
./mautrix-meta-updater.sh
```

### Output:

```
Loading configuration from .env...
Detected architecture: amd64
Fetching the latest release URL...
Latest release tag: v0.4.3
Downloading the latest release for amd64...
Which service(s) would you like to update?
1. Facebook only
2. Instagram only
3. Both Facebook and Instagram
Enter your choice (1/2/3): 3

Stopping mautrix-meta-facebook service...
Replacing binary and setting permissions for mautrix-meta-facebook...
Starting mautrix-meta-facebook service...

Stopping mautrix-meta-instagram service...
Replacing binary and setting permissions for mautrix-meta-instagram...
Starting mautrix-meta-instagram service...

Cleanup...
Update completed successfully.
```

---

## Troubleshooting

- **Failed to Download**: Ensure `curl` is installed and your network can reach GitHub.  
- **Permission Errors**: Run the script as a user with `sudo` privileges.  
- **Unsupported Architecture**: The script currently supports `amd64`, `arm`, and `arm64`. Contact the maintainer for additional support.

---

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/your-feature`.
3. Make changes and commit: `git commit -m "Add your changes"`.
4. Push to your fork: `git push origin feature/your-feature`.
5. Open a Pull Request.

---

## License

This project is licensed under the MIT License.

---

## Credits

Created by [OCT0PUSCRIME](https://github.com/OCT0PUSCRIME).  
This script was designed to simplify the update process for **mautrix-meta** bridges.
