# brew-coffee

`brew-coffee` helps developers quickly set up their environments with ready-to-use bundles for Python, Node.js, Cloud, Kubernetes, DevTools, and more.

---

## Features

* Install **complete developer environments** in seconds
* Curated bundles for:

  * Python, Node.js
  * AWS, Azure, GCP
  * Kubernetes, Terraform, Docker
  * Common dev tools (Git, Oh My Zsh, etc.)
* Easy-to-use **install script**
* Open source & community-friendly

---

## Requirements

* macOS with **Homebrew**

> Don’t worry! The installer script automatically installs Homebrew if it’s missing.

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/n4en/brew-coffee.git
cd brew-coffee
```

### 2. Make the installer executable

```bash
chmod +x ./install.sh
```

### 3. Install bundles

#### Install a single bundle

```bash
./install.sh python
```

#### Install multiple bundles at once

```bash
./install.sh python nodejs cloud
```

#### Install all bundles

```bash
./install.sh
```

The script will:

1. Check if Homebrew is installed, and install it if missing.
2. Install the packages listed in the chosen Brewfile(s).

---

## Bundle Structure

All bundles are stored in the `bundles/` directory:

```
bundles/
├─ python.Brewfile
├─ nodejs.Brewfile
├─ cloud.Brewfile
├─ kubernetes.Brewfile
└─ devtools.Brewfile
```

Each Brewfile lists the packages and dependencies for that bundle.

---

## Contributing

We welcome contributions! You can:

* Add new bundles for other dev stacks
* Update existing Brewfiles
* Improve the installer script or documentation

1. Fork the repository
2. Create a branch (`git checkout -b feature/new-bundle`)
3. Make changes
4. Submit a Pull Request

