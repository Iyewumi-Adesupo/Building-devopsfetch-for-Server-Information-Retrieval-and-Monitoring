
<h1 align="center" id="title">Building devopsfetch for Server Information Retrieval and Monitoring</h1>
<p id="description"> devopsfetch is a tool designed for DevOps professionals to collect and display critical system information. It provides details about active ports, user logins, Nginx configurations, Docker images, and container statuses. Additionally, it supports continuous monitoring of these activities through a systemd service, enabling effective server management and troubleshooting. 
  
***Table of Contents***
Features
Installation
Usage
Configuration
Logging and Monitoring
Examples
Help
Contributing
License

***Features***
devopsfetch offers the following functionalities:

***Information Retrieval***
***Ports***

  List all active ports and services: -p or --port
  Display detailed information about a specific port: -p <port_number>

***Docker***

  List all Docker images and containers: -d or --docker
  Display detailed information about a specific container: -d <container_name>

***Nginx***

  Display all Nginx domains and their ports: -n or --nginx
  Display detailed configuration information for a specific domain: -n <domain>

***Users***

  List all users and their last login times: -u or --users
  Display detailed information about a specific user: -u <username>

***Time Range***

  Display activities within a specified time range: **`-t <start_time> <end_time> or --time <start_time> <end_time>`***

***Output Formatting***
  All outputs are formatted for readability in well-structured tables with descriptive column names.

***Installation Script***
  A script is provided to install necessary dependencies and set up a systemd service for continuous monitoring and logging of activities.

***Help and Documentation***
  A help flag (-h or --help) provides usage instructions for the program.
  Comprehensive documentation covers installation and configuration steps, usage examples for each command-line flag, logging mechanism, and log retrieval.

***Installation**
  To install devopsfetch, follow these steps:

***Clone the repository:***
```sh
git clone https://github.com/yourusername/devopsfetch.git
cd devopsfetch
```

***Run the installation script:***

```sh
sudo bash install.sh

```


The script performs the following actions:

  Installs necessary dependencies (e.g., Docker, Nginx, net-tools, etc.)
  Sets up a systemd service for continuous monitoring and logging.

  **Enable and start the devopsfetch service:**

  ```sh
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

```

***Usage***
devopsfetch can be used with various command-line flags to retrieve system information. Here are the available options:

***-p, --port**: Display all active ports and services or detailed information about a specific port.


***-d, --docker**: List all Docker images and containers or detailed information about a specific container.


***-n, --nginx**: Display all Nginx domains and their ports or detailed configuration information for a specific domain.


***-u, --users**: List all users and their last login times or detailed information about a specific user.


***-t, --time**: Display activities within a specified time range.


***-h, --help**: Display help and usage instructions.


***Configuration***
***Systemd Service**
  The systemd service for devopsfetch is configured to run continuously and monitor system activities. The service file is located at 
  /etc/systemd/system/devopsfetch.service. You can modify this file to change service parameters if needed.

***Configuration File**
  A configuration file (config.json) is used to customize devopsfetch behavior, such as logging intervals and output formats. The file is located in the installation directory.

  ```sh
{
  "logging_interval": 60,  // Log every 60 seconds
  "output_format": "table",  // Supported formats: table, json
  "log_file": "/var/log/devopsfetch.log",
  "log_rotation": {
    "max_size": "10M",
    "max_files": 5
  }
}

```

***Logging and Monitoring**
devopsfetch logs its activities to a specified log file. The logging mechanism ensures efficient log rotation and management. Logs can be found at /var/log/devopsfetch.log.

***Log Rotation**
Log rotation is configured to prevent log files from growing indefinitely. The logrotate utility is used to manage log rotation. The configuration ensures:

Maximum log file size is set to 10MB.
Up to 5 log files are retained.
The logrotate configuration file is located at /etc/logrotate.d/devopsfetch.

Examples
Display all active ports and services

```sh
devopsfetch -p

```

***Display detailed information about a specific port**
```sh
devopsfetch -p 8080

```

***List all Docker images and containers***
```sh
devopsfetch -d

```

***Display detailed information about a specific Docker container***
```sh
devopsfetch -d my_container

```

***Display all Nginx domains and their ports***
```sh
devopsfetch -n

```

***Display detailed configuration information for a specific Nginx domain**
```sh
devopsfetch -n example.com

```

***List all users and their last login times***
```sh
devopsfetch -u

```

***Display detailed information about a specific user***
```sh
devopsfetch -u john
```
***Display activities within a specified time range***
```sh
devopsfetch -t "2024-07-01 00:00:00" "2024-07-24 23:59:59"

```

***Help***
  To access the help documentation and see a list of available options, run:
  ```sh
devopsfetch -h

```

or

```sh
devopsfetch --help

```

***Contributing***
We welcome contributions to devopsfetch! If you have any bug reports, feature requests, or improvements, please feel free to open an issue or submit a pull request.

***Steps to Contribute***
Fork the repository and clone it locally:
```sh
git clone https://github.com/Iyewumi-Adesupo/Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring.git

```


***Create a new branch for your feature or bug fix:***

```sh
git checkout -b feature-name
```

***Commit your changes and push them to your fork:***


```sh
git commit -m "Description of changes"
git push origin feature-name
```


![devops-fetch sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 23_07_2024 01_24_55](https://github.com/user-attachments/assets/939b0747-5b44-4df8-bb27-5c21c6bb33d2)



![devops-fetch sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 23_07_2024 01_42_06](https://github.com/user-attachments/assets/ce1a9304-562c-4a4c-b82f-64ce3fd4c9bc)


![devops-fetch sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 23_07_2024 14_39_16](https://github.com/user-attachments/assets/4cdaa226-8c33-42d2-9608-461958ebc418)


![devopsfetch sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 24_07_2024 21_01_49](https://github.com/user-attachments/assets/12d3f81e-7f1e-4ea6-ba79-82d4cb83ffa9)


![devopsfetch sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 24_07_2024 21_02_56](https://github.com/user-attachments/assets/057fffe2-7c33-414d-baed-c7060dd8ddf3)


![devopsfetch sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 24_07_2024 21_10_44](https://github.com/user-attachments/assets/7f7fedc4-26d1-4b46-968a-6890feecc156)


![installation-script sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 24_07_2024 13_45_47](https://github.com/user-attachments/assets/a710da4c-19b5-4702-9450-ebd009165655)


![installation-script sh - Building-devopsfetch-for-Server-Information-Retrieval-and-Monitoring  WSL_ Ubuntu  - Visual Studio Code 24_07_2024 13_48_05](https://github.com/user-attachments/assets/be4c3067-1215-47ee-b46f-14f499cdc0e4)

