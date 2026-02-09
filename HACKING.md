# Plank Reloaded - Development Guide

## Testing the Latest Build

The latest stable version can be installed via your distribution's package manager or built from source.

## Getting Help

For Plank Reloaded specific issues and discussions:

- GitHub Issues: https://github.com/zquestz/plank-reloaded/issues

## Contributing Without Coding

1. **Report and Verify Issues**
   - Check existing issues on GitHub
   - Report new bugs with detailed information
   - Help verify and test fixes

2. **Documentation**
   - Help improve documentation
   - Update wiki pages
   - Suggest improvements

## Building From Source

1. **Clone the repository:**

```bash
git clone https://github.com/zquestz/plank-reloaded.git
cd plank-reloaded
```

2. **Build and Install:**

```bash
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

3. **Run Plank:**

```bash
meson compile -C build run
```

4. **Run Plank with verbose logging:**

```bash
meson compile -C build run-verbose
```

## Debugging Issues

For investigating crashes or memory issues, use GDB:

```bash
meson compile -C build run-debug
```

## Development Guidelines

### Bug Fixes and Features

Important: Keep fixes for different bugs in different branches!

- Create a separate branch for each bug fix
- Branches fixing multiple unrelated bugs will be rejected
- Exception: Patches that are indivisible by nature

Reasons for this policy:

1. Prevents delays when some fixes need revision while others are correct
2. Allows selective reverting of problematic changes
3. Makes code review more focused and efficient

## Git Workflow

### Initial Setup

1. **Fork the repository**

- Visit https://github.com/zquestz/plank-reloaded
- Click the "Fork" button in the top right
- Clone your fork locally:

```bash
git clone https://github.com/YOUR-USERNAME/plank-reloaded.git
cd plank-reloaded
```

2. **Add upstream remote**

```bash
git remote add upstream https://github.com/zquestz/plank-reloaded.git
```

### Making Changes

1. **Create a feature branch:**

```bash
git checkout -b fix-issue-number
```

2. **Make your changes and commit:**

```bash
git add <files>
git commit -m "Descriptive message"
```

3. **Keep your fork updated:**

```bash
git fetch upstream
git checkout master
git merge upstream/master
git push origin master
```

4. **Update your feature branch:**

```bash
git checkout fix-issue-number
git rebase master
```

5. **Push your changes:**

```bash
git push origin fix-issue-number
```

6. **Create a Pull Request**

- Visit your fork on GitHub
- Click "Pull Request"
- Select your feature branch
- Describe your changes
- Submit the PR

### After Pull Request Review

If changes are requested:

1. Make the required updates
2. Commit new changes
3. Push to your branch
4. The PR will update automatically

### Tips

- Write clear commit messages
- One logical change per commit
- Keep PRs focused and reasonably sized
- Follow the coding style guidelines
- Add tests for new features
- Update documentation as needed

## License

This document is licensed under the GPL version 3.
