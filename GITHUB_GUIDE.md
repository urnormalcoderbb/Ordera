# GitHub Setup & Push Guide

This document outlines the commands used to initialize the local repository and the steps required to push it to GitHub.

## 🏁 Commands Already Executed

The following commands have been run locally to prepare your project:

1. **Initialize Git Repository:**
   ```bash
   git init
   ```

2. **Configure Local Identity (Temporary):**
   *(Note: You can change these to your actual GitHub details).*
   ```bash
   git config user.email "user@example.com"
   git config user.name "Ordera User"
   ```

3. **Stage All Files:**
   ```bash
   git add .
   ```

4. **Initial Commit:**
   ```bash
   git commit -m "Initial commit: Multi-tenant Restaurant System"
   ```

---

## 🚀 Pushing to GitHub

Since I cannot access your GitHub account directly, please follow these steps to push the code:

### 1. Create a Repository on GitHub
1. Go to [github.com/new](https://github.com/new).
2. Name your repository (e.g., `Ordera`).
3. Leave it **Public** or **Private** as per your preference.
4. **Do not** initialize with a README, license, or .gitignore (we already have them).
5. Click **Create repository**.

### 2. Connect Local Repo to GitHub
Copy the URL of your new repository and run the following commands in your terminal:

```bash
# Replace <YOUR_REMOTE_URL> with the URL from GitHub
git remote add origin <YOUR_REMOTE_URL>

# Rename branch to main (standard)
git branch -M main

# Push the code
git push -u origin main
```

---

## 🛠️ Essential Git Commands (Cheat Sheet)

| Command | Description |
| :--- | :--- |
| `git status` | Check which files are modified/staged. |
| `git add <file>` | Stage a specific file. |
| `git commit -m "msg"` | Save your staged changes with a message. |
| `git pull origin main` | Download latest changes from GitHub. |
| `git push` | Upload your committed changes to GitHub. |
| `git log --oneline` | View a brief history of commits. |

---

## 🛡️ Note on `.gitignore`
I have already created a `.gitignore` file for you. It ensures that large or sensitive files like your **Virtual Environment (`venv/`)**, **Databases (`*.db`)**, and **Cache files** are not uploaded to GitHub.
