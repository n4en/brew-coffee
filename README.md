# brew-coffee

brew-coffee is a lightweight CLI tool to quickly set up and manage developer environments using **Homebrew bundles**. It provides curated sets of packages for programming languages, cloud providers, Kubernetes, and common development tools, making environment setup fast, consistent, and reproducible.

---

## Features

* Install **complete developer environments** in seconds
* Curated bundles for:

  * Programming: Python, Node.js
  * Cloud: AWS, Azure, GCP
  * Kubernetes & Infra: K8s, Infra
  * Developer Tools: Git, Oh My Zsh, Dev utilities
* Modular, reusable Brewfiles with **shared common tools**
* CLI-friendly management via `coffee.sh`:

  * `install` – install bundles
  * `clean` – remove installed bundles
  * `list` – show available bundles
  * `check` – verify bundle installation status

* Open source & community-friendly

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/n4en/brew-coffee.git
cd brew-coffee
````

### 2. Make the main script executable

```bash
chmod +x ./coffee.sh
```

## Usage

`coffee.sh` is the main entry point. All operations (install, clean, check, list) are delegated to the scripts in `scripts/` and handle bundles in `bundles/`.

### Install Bundles

#### Install a single bundle

```bash
./coffee.sh install python
```

#### Install multiple bundles at once

```bash
./coffee.sh install python nodejs aws
```

#### Install all bundles

```bash
./coffee.sh install
```

---

### Clean Bundles

Remove installed packages for a bundle:

```bash
./coffee.sh clean aws
```

> Only packages listed in the bundle and its shared files are removed.

#### Clean all bundles

```bash
./coffee.sh clean
```

---

## ⚠️ Important: Cleaning Bundles & Dependencies

When you run `./coffee.sh clean <bundle>`, Homebrew will uninstall all packages in that bundle. Homebrew may also automatically remove any dependencies it considers "unneeded"—even if those dependencies are used by other bundles. This is standard Homebrew behavior and cannot be controlled by the script.

**Best Practice:**
- If you clean a bundle and other bundles break, simply re-run `./coffee.sh install <other-bundle>` to restore missing dependencies.
- For maximum safety, use `clean` only when you are sure you do not need the packages elsewhere.
- Consider using a Homebrew restore or backup if you want to revert changes.

---

### List Available Bundles

```bash
./coffee.sh list
```

Output example:

```
 - python
 - nodejs
 - aws
 - azure
 - gcp
 - k8s
 - infra
 - dev
```

---

### Check Bundles

Verify whether all packages in a bundle are installed:

```bash
./coffee.sh check aws
```

Check all bundles:

```bash
./coffee.sh check
```

---

## Bundle Guidelines

* All bundles are located in the `bundles/` directory.
* Bundle naming follows `<name>.Brewfile`.

---

## Adding New Bundles

1. Create a new Brewfile in `bundles/`:

```bash
touch bundles/my-new-bundle.Brewfile
```

2. Add Homebrew packages and optional comments.
3. Include shared tools if needed:

```ruby
eval File.read("./bundles/infra.Brewfile")
```

4. Install the new bundle via:

```bash
./coffee.sh install my-new-bundle
```

---

## Contributing

Contributions are welcome! You can:

* Add new bundles for different tech stacks
* Update existing Brewfiles
* Improve CLI scripts or documentation

Steps:

1. Fork the repository
2. Create a feature branch:

```bash
git checkout -b feature/my-new-bundle
```

3. Make changes
4. Submit a Pull Request
