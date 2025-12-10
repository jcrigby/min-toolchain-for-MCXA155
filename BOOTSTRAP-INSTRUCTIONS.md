# MCXA155 Minimal - Bootstrap Instructions

## One-Time Setup

1. **Create empty GitHub repo** (no files)

2. **Add just one file:**
   ```bash
   git clone <your-empty-repo>
   cd <repo>
   cp bootstrap.sh .
   git add bootstrap.sh
   git commit -m "Add bootstrap script"
   git push
   ```

3. **Point Claude Code at the repo**

4. **Claude Code runs:**
   ```bash
   ./bootstrap.sh
   docker-compose run build
   ```

Done. Everything created and built.

## What bootstrap.sh Creates

```
.
├── bootstrap.sh          (the script itself)
├── README.md
├── Dockerfile
├── docker-compose.yml
├── Makefile
├── .gitignore
├── src/
│   └── main.c
├── scripts/
│   └── flash.sh
├── docs/
│   └── README.md
└── build/               (created by make, gitignored)
```

## Then Push Everything to Repo

After running bootstrap.sh once:

```bash
git add .
git commit -m "Initial MCXA155 project structure"
git push
```

Now repo has complete, buildable project.

## Usage

```bash
# Build
docker-compose run build

# Interactive
docker-compose run shell

# Flash (manually)
pip3 install spsdk
blhost -p /dev/ttyUSB0 -- flash-erase-all
blhost -p /dev/ttyUSB0 -- write-memory 0x0 build/firmware.bin
```
