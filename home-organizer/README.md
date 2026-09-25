# Home Folder System: Shivagoud's MacBook Pro

A folder system for one person who is a **Founder/CEO** of two companies (**Lexora AI LLC**, **Balamonis LLC**), a **Principal AI Solution Architect**, and someone with a personal life to manage.

It follows three rules:

1. **Every file has one obvious home.** When a file could go in two places, the tree is wrong.
2. **Numbers set the order.** `00_` to `90_` keeps the folders in the same order in Finder and in the Terminal, and leaves room to add more later.
3. **Keep it shallow.** Three or four levels at most. If you have to dig for a file, the system has failed.

---

## 1. The structure

```
/Users/Shivagoud/
│
├── 00_Inbox/                  ← Everything new lands here. Empty it every Friday.
│   ├── Documents/ Images/ Videos/ Audio/ Spreadsheets/
│   ├── Presentations/ Code-Data/ Archives/ Installers/ Other/
│   └── _logs/                 ← organizer move logs + undo scripts
│
├── 10_Companies/
│   ├── Lexora-AI-LLC/
│   │   ├── 01_Admin-Legal/        Formation-EIN, Contracts-NDAs, Licenses-Compliance
│   │   ├── 02_Finance/            Invoices-Out, Bills-Expenses, Banking, Taxes, Payroll, Reports
│   │   ├── 03_Clients/            one folder per client (copy _Template-Client)
│   │   ├── 04_Sales-Marketing/    Proposals, Pitch-Decks, Campaigns, Website-Social
│   │   ├── 05_People-Staffing/    Employees, Contractors, Candidates, Policies-Handbook
│   │   ├── 06_Products-Projects/  one folder per product (docs/specs only, code lives in 20_Code)
│   │   ├── 07_Brand-Assets/       Logos, Templates
│   │   ├── 08_Strategy-Board/     OKRs-Plans, Investors-Fundraising, Meetings
│   │   └── 09_Vendors-Partners/
│   └── Balamonis-LLC/             (same layout, so you always know where things are)
│
├── 20_Code/                   ← ALL git repos, and nothing else
│   ├── github/                bsgusa/*, your org repos
│   ├── clients/               client-owned repos
│   ├── experiments/           spikes, throwaway prototypes
│   └── forks/
│
├── 30_AI-Lab/                 ← Your architect workbench
│   ├── Agents/  Prompts/  Models/  Datasets/  Notebooks/
│   ├── Research-Papers/
│   └── Architecture-Diagrams/
│
├── 40_Knowledge/              ← What you learn and teach
│   ├── Notes/  Books/  Courses/  Certifications/
│   └── Talks-Content/         (LinkedIn posts, talks, blog drafts)
│
├── 50_Personal/
│   ├── Identity-Immigration/  passport, visa, I-20/EAD/H-1B, SSN, licence  🔒
│   ├── Finance/               Banking, Taxes, Investments, Insurance       🔒
│   ├── Health/  Home-Housing/  Vehicles/  Family/  Education/  Travel/
│   └── Career/Resume-CV/
│
├── 60_Media/                  Photos, Videos, Screenshots, Music
├── 70_Tools/                  bin, dotfiles, scripts
├── 90_Archive/2026/           ← Finished work. Move it here, don't delete it.
│
└── (macOS folders stay as they are: Desktop, Documents, Downloads, Pictures,
     Movies, Music, Library, Applications. Apps need them.)
```

### Why it's built this way

| Decision | Reason |
|---|---|
| Both companies use **the same 01–09 layout** | You switch between companies all day. The same path in each (`02_Finance/Taxes`) means no thinking. Adding a third company takes one command. |
| **Code is kept apart from company docs** | Git repos have their own setup (virtual envs, `node_modules`, IDE settings). Keeping them together in `20_Code` makes backup rules, search, and tools like Spotlight and Time Machine easier to manage. |
| **`30_AI-Lab` is its own area** | Prompts, agents, evals and diagrams you reuse across *both* companies and client work. It's your library of reusable work. |
| **The inbox is the only place new files go** | Downloads, Desktop and screenshots pile up. One inbox you empty once a week beats clutter everywhere. |
| **Archive instead of delete** | Founders need old contracts, tax returns and cap tables years later. Storage is cheap; a lost document is not. |

---

## 2. Run it on your Mac (about 10 minutes)

The script **only creates folders and moves loose files**. It never deletes anything, never touches folders or hidden files, and always previews first.

```bash
# 1. Get the script (clone the repo, or download organize-home.sh from GitHub)
cd ~/Downloads
git clone https://github.com/bsgusa/bsgusa.git
cd bsgusa/home-organizer

# 2. PREVIEW: shows what would happen and changes nothing
bash organize-home.sh

# 3. Do it
bash organize-home.sh --apply

# 4. Move this repo into its new home (the `tidy` shortcut below expects it there)
mv ~/Downloads/bsgusa ~/20_Code/github/
```

> macOS will ask **"Terminal would like to access files in your Desktop / Documents / Downloads folder."** Click **Allow**. Without it the script can't see those folders.

**Options**

```bash
bash organize-home.sh --skeleton-only --apply        # only create the folders, move nothing
bash organize-home.sh --apply --company "Lexora-AI-LLC" --company "Balamonis-LLC" --company "NewCo-LLC"
```

**Changed your mind?** Each run writes an undo script:

```bash
bash ~/00_Inbox/_logs/undo_<date>.sh
```

### What the script does

1. **Creates** the full tree above for both companies (it's safe to run again; existing folders are left alone).
2. **Sweeps** loose *files* from `~`, `~/Desktop`, `~/Downloads`, `~/Documents` into `00_Inbox/<type>/`. macOS screenshots go straight to `60_Media/Screenshots/`. It skips files that are still downloading. Name clashes become `file (2).pdf`; nothing is overwritten.
3. **Reports** (it only reads here, it changes nothing):
   - folders in your home that don't fit the system, for you to file by hand
   - every **git repo** it finds, to move into `20_Code/github/`
   - **files over 1 GB**, to archive or move to an external drive

---

## 3. After the script: the 60-minute manual pass

The script handles the busywork. The judgment calls are yours:

1. **Git repos** (from the report): `mv ~/old/place/repo ~/20_Code/github/`.
   Then re-open them in VS Code/Cursor. If a Python venv breaks, delete it and recreate it: `python3 -m venv .venv`.
2. **Folders from the report**: drag each one into the right `10_`–`50_` area, or into `90_Archive/2026/`.
3. **Empty `00_Inbox`**: work through each subfolder and file every item. Anything left unfiled after 30 days → `90_Archive`.
4. **Installers** (`00_Inbox/Installers/*.dmg`, `.pkg`): once the app is installed, these are safe to put in the Trash. That's your decision; the script never deletes.
5. **Sensitive files** (`50_Personal/Identity-Immigration`, `Finance`, company `01_Admin-Legal`): see the security section below.

---

## 4. One-time Mac settings (copy and paste into Terminal)

```bash
# Save screenshots into 60_Media/Screenshots instead of the Desktop
defaults write com.apple.screencapture location ~/60_Media/Screenshots
killall SystemUIServer

# Show file extensions and the path bar in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
killall Finder
```

**Finder sidebar:** open Finder, go to your home folder, and drag `00_Inbox`, `10_Companies`, `20_Code` and `30_AI-Lab` into the sidebar under *Favorites*.

**Safari/Chrome downloads:** leave them going to `~/Downloads`. The weekly sweep handles them.

**iCloud warning:** if *System Settings → Apple ID → iCloud → iCloud Drive → "Desktop & Documents Folders"* is **on**, files moved out of Desktop/Documents into `~/00_Inbox` etc. **stop syncing to iCloud**. Choose one:

- **Recommended:** back up the whole home folder with **Time Machine** plus a cloud backup (see below), and treat iCloud as optional.
- Or: if you rely on iCloud, run the organizer with `--root ~/Documents` so the whole system lives inside the synced `Documents` folder.

---

## 5. Naming files

```
YYYY-MM-DD_Company_Topic_vNN.ext

2026-09-25_Lexora_MSA-AcmeCorp_v02.pdf
2026-Q3_Balamonis_Board-Update_v01.pptx
2026_Personal_Tax-Return_Federal.pdf
```

- Dates first, so files sort in time order.
- No spaces (use `-` and `_`), which keeps paths easy to use in the Terminal and in scripts.
- `_vNN` for drafts. The final version gets `_FINAL` **once**, never `_final_final2`.

---

## 6. Security (you're a CEO: treat your laptop as a target)

- **FileVault on**: System Settings → Privacy & Security → FileVault. This encrypts the whole disk if the Mac is lost.
- **No passwords, API keys or `.env` secrets in any folder.** Put them in a password manager (1Password, Bitwarden, or Apple Passwords). Before pushing any repo, check that `.env` is in `.gitignore`.
- **Passport, visa and SSN scans:** keep them in an encrypted disk image: Disk Utility → File → New Image → Blank Image → *Encryption: 256-bit AES*, saved in `50_Personal/Identity-Immigration/`.
- **Keep the two LLCs apart:** never mix Lexora and Balamonis finance files. This matters for taxes, audits, and keeping each LLC's liability protection intact.

---

## 7. Backup (the 3-2-1 rule)

| Copy | Where | How |
|---|---|---|
| 1 | This Mac | — |
| 2 | External SSD | **Time Machine** (automatic, every hour) |
| 3 | Cloud | Backblaze (~$9/mo, backs up the whole Mac) **or** Google Drive/iCloud for `10_Companies` + `50_Personal` |

Code is backed up by **pushing to GitHub**. `20_Code` does not need a cloud-drive sync (syncing `node_modules` and `.venv` is slow and wasteful).

---

## 8. Keeping it clean (the habits)

| When | Do this | Time |
|---|---|---|
| **Every Friday** | Run `bash organize-home.sh --apply`, then empty `00_Inbox` | 15 min |
| **Month end** | Invoices and receipts → each company's `02_Finance`; move finished client work → `90_Archive` | 20 min |
| **Quarter end** | Estimated taxes and board updates per LLC; clear out `20_Code/experiments` | 30 min |
| **January** | Create `90_Archive/<new year>/`; archive last year's finance folders | 30 min |

Add a shortcut so the weekly clean-up is one word. Add this to `~/.zshrc`:

```bash
alias tidy='bash ~/20_Code/github/bsgusa/home-organizer/organize-home.sh --apply'
```

---

## 9. Next steps (when you're ready)

1. **Update the GitHub profile repo** (`bsgusa/bsgusa` README) to show Lexora AI LLC and Balamonis LLC.
2. **Put your dotfiles under version control**: move `.zshrc`, `.gitconfig` and VS Code settings into `70_Tools/dotfiles` as a git repo, so a new Mac is set up in minutes.
3. **Automate the Friday sweep**: a `launchd` job can run the script weekly in preview mode and send you a notification.
4. **An AI file assistant**: a small agent (Claude + the file list) that reads what's in `00_Inbox` and *suggests* the right company or folder for each file. You approve, it files. This is a natural next project for `30_AI-Lab/Agents/`.
