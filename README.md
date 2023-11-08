# Restic Backup Script

This is a Bash script for performing backups using Restic. The script includes error handling and logging to a specified log file. It can be used to automate regular backups and manage old backups with the Restic tool.

## Prerequisites

- [Restic](https://restic.net/): You need to have Restic installed on your system to use this script. Follow the installation instructions on the Restic website.

## Usage

1. Clone or download this repository.

2. Create a configuration file with your Restic settings, and provide the path to the configuration file as an argument when running the script.

    ```bash
    ./restic-backup.sh /path/to/your/config-file
    ```

3. The script will create a lock file to prevent concurrent executions. It will log its activities and any errors in the specified log file.

## Configuration

The script reads its configuration from a file specified as a command-line argument. The configuration file should contain the necessary environment variables for Restic. An example configuration file can be found in this repository.

## Logging

The script logs its activities and any errors to a specified log file. Make sure to set the LOG_FILE variable in the script to the desired log file path.

## Acknowledgments

[Restic](https://restic.net/): A fast, secure, and efficient backup program.