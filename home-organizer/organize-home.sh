#!/usr/bin/env bash
# organize-home.sh — build a clean, numbered home-folder system and sweep
# loose files into an Inbox for review. Built for macOS (stock bash 3.2 / zsh Mac).
#
# SAFE BY DESIGN
#   * Dry run by default. Nothing changes until you pass --apply.
#   * Never deletes anything. It only creates folders and moves loose FILES.
#   * Never touches dotfiles, folders, or system dirs (Library, Applications...).
#   * Every move is logged, and an undo script is written next to the log.
#
# USAGE
#   bash organize-home.sh                 # preview only
#   bash organize-home.sh --apply         # do it
#   bash organize-home.sh --apply --company "Lexora-AI-LLC" --company "NewCo-LLC"
#   bash organize-home.sh --skeleton-only --apply   # just create folders

set -u

APPLY=0
SWEEP=1
COMPANIES=()
ROOT="${HOME}"

while [ $# -gt 0 ]; do
  case "$1" in
    --apply)          APPLY=1 ;;
    --skeleton-only)  SWEEP=0 ;;
    --company)        shift; COMPANIES+=("$1") ;;
    --root)           shift; ROOT="$1" ;;
    -h|--help)        sed -n '2,16p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
[ ${#COMPANIES[@]} -eq 0 ] && COMPANIES=("Lexora-AI-LLC" "Balamonis-LLC")

STAMP="$(date +%Y-%m-%d_%H%M%S)"
INBOX="${ROOT}/00_Inbox"
LOG="${INBOX}/_logs/organize_${STAMP}.tsv"
UNDO="${INBOX}/_logs/undo_${STAMP}.sh"

say()  { printf '%s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Folder skeleton
# ---------------------------------------------------------------------------
COMPANY_SUBDIRS="
01_Admin-Legal/Formation-EIN
01_Admin-Legal/Contracts-NDAs
01_Admin-Legal/Licenses-Compliance
02_Finance/Invoices-Out
02_Finance/Bills-Expenses
02_Finance/Banking
02_Finance/Taxes
02_Finance/Payroll
02_Finance/Reports
03_Clients/_Template-Client
04_Sales-Marketing/Proposals
04_Sales-Marketing/Pitch-Decks
04_Sales-Marketing/Campaigns
04_Sales-Marketing/Website-Social
05_People-Staffing/Employees
05_People-Staffing/Contractors
05_People-Staffing/Candidates
05_People-Staffing/Policies-Handbook
06_Products-Projects
07_Brand-Assets/Logos
07_Brand-Assets/Templates
08_Strategy-Board/OKRs-Plans
08_Strategy-Board/Investors-Fundraising
08_Strategy-Board/Meetings
09_Vendors-Partners
"

BASE_DIRS="
00_Inbox/Documents
00_Inbox/Images
00_Inbox/Videos
00_Inbox/Audio
00_Inbox/Spreadsheets
00_Inbox/Presentations
00_Inbox/Code-Data
00_Inbox/Archives
00_Inbox/Installers
00_Inbox/Other
00_Inbox/_logs
10_Companies
20_Code/github
20_Code/clients
20_Code/experiments
20_Code/forks
30_AI-Lab/Agents
30_AI-Lab/Prompts
30_AI-Lab/Models
30_AI-Lab/Datasets
30_AI-Lab/Notebooks
30_AI-Lab/Research-Papers
30_AI-Lab/Architecture-Diagrams
40_Knowledge/Notes
40_Knowledge/Books
40_Knowledge/Courses
40_Knowledge/Certifications
40_Knowledge/Talks-Content
50_Personal/Identity-Immigration
50_Personal/Finance/Banking
50_Personal/Finance/Taxes
50_Personal/Finance/Investments
50_Personal/Finance/Insurance
50_Personal/Health
50_Personal/Home-Housing
50_Personal/Vehicles
50_Personal/Family
50_Personal/Education
50_Personal/Career/Resume-CV
50_Personal/Travel
60_Media/Photos
60_Media/Videos
60_Media/Screenshots
60_Media/Music
70_Tools/bin
70_Tools/dotfiles
70_Tools/scripts
90_Archive
"

say "== Home organizer =="
say "Root:      ${ROOT}"
say "Companies: ${COMPANIES[*]}"
[ $APPLY -eq 0 ] && say "Mode:      DRY RUN (add --apply to make changes)"
say ""
say "-- Step 1: folder skeleton --"

make_dir() {
  [ -d "$1" ] && return 0
  if [ $APPLY -eq 1 ]; then mkdir -p "$1"; else say "  [dry-run] create ${1#${ROOT}/}/"; fi
}

for d in $BASE_DIRS; do make_dir "${ROOT}/${d}"; done
for c in "${COMPANIES[@]}"; do
  for d in $COMPANY_SUBDIRS; do make_dir "${ROOT}/10_Companies/${c}/${d}"; done
done
make_dir "${ROOT}/90_Archive/$(date +%Y)"
say "  skeleton ready"

[ $SWEEP -eq 0 ] && { say "Skipping sweep (--skeleton-only)."; exit 0; }

# ---------------------------------------------------------------------------
# 2. Sweep loose files into 00_Inbox/<type>
# ---------------------------------------------------------------------------
category_for() {
  ext="$(printf '%s' "${1##*.}" | tr '[:upper:]' '[:lower:]')"
  [ "$ext" = "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" ] && ext=""
  case "$ext" in
    pdf|doc|docx|txt|rtf|md|pages|odt|epub)          echo Documents ;;
    jpg|jpeg|png|gif|heic|webp|svg|bmp|tif|tiff|raw)  echo Images ;;
    mp4|mov|avi|mkv|m4v|webm)                         echo Videos ;;
    mp3|wav|m4a|aac|flac|ogg)                         echo Audio ;;
    xls|xlsx|csv|numbers|ods|tsv)                     echo Spreadsheets ;;
    ppt|pptx|key|odp)                                 echo Presentations ;;
    py|js|ts|ipynb|json|yaml|yml|sql|sh|html|css|xml|parquet) echo Code-Data ;;
    zip|tar|gz|tgz|rar|7z|bz2)                        echo Archives ;;
    dmg|pkg|exe|msi|deb|rpm|appimage|iso)             echo Installers ;;
    *)                                                echo Other ;;
  esac
}

unique_target() {
  # Never overwrite: file.pdf -> file (2).pdf -> file (3).pdf ...
  dir="$1"; name="$2"; target="${dir}/${name}"; n=2
  base="${name%.*}"; ext=""
  [ "$base" != "$name" ] && ext=".${name##*.}"
  while [ -e "$target" ]; do target="${dir}/${base} (${n})${ext}"; n=$((n+1)); done
  printf '%s' "$target"
}

if [ $APPLY -eq 1 ]; then
  printf 'source\tdestination\n' > "$LOG"
  printf '#!/usr/bin/env bash\n# Undo moves from %s\n' "$STAMP" > "$UNDO"
fi

sweep() {
  src="$1"
  [ -d "$src" ] || return 0
  say ""
  say "-- Sweeping loose files in ${src} --"
  # Only regular files at the top level; skip dotfiles and anything open/partial.
  find "$src" -maxdepth 1 -type f ! -name '.*' \
       ! -name '*.crdownload' ! -name '*.part' ! -name '*.download' -print 2>/dev/null |
  while IFS= read -r f; do
    name="$(basename "$f")"
    case "$name" in
      "Screenshot "*|"Screen Shot "*|"Screen Recording "*) cat="60_Media/Screenshots" ;;
      *) cat="00_Inbox/$(category_for "$name")" ;;
    esac
    dest="$(unique_target "${ROOT}/${cat}" "$name")"
    if [ $APPLY -eq 1 ]; then
      mv -n "$f" "$dest" && {
        printf '%s\t%s\n' "$f" "$dest" >> "$LOG"
        printf 'mv -n %q %q\n' "$dest" "$f" >> "$UNDO"
      }
    else
      say "  [dry-run] ${name}  ->  ${cat}/"
    fi
  done
}

sweep "${ROOT}"
sweep "${ROOT}/Desktop"
sweep "${ROOT}/Downloads"
sweep "${ROOT}/Documents"

# ---------------------------------------------------------------------------
# 3. Reports (read-only): folders to file by hand, git repos, big files
# ---------------------------------------------------------------------------
KNOWN='^(00_Inbox|10_Companies|20_Code|30_AI-Lab|40_Knowledge|50_Personal|60_Media|70_Tools|90_Archive|Desktop|Documents|Downloads|Pictures|Movies|Music|Videos|Public|Library|Applications|Templates|snap|go|OneDrive.*|Google Drive.*|Dropbox|iCloud Drive.*|Creative Cloud Files.*)$'

say ""
say "-- Folders in your home that need a decision (move by hand) --"
find "$ROOT" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null |
while IFS= read -r d; do
  b="$(basename "$d")"
  printf '%s\n' "$b" | grep -Eq "$KNOWN" || say "  ${b}/"
done

say ""
say "-- Git repositories found (suggest moving to 20_Code/github) --"
find "$ROOT" -maxdepth 4 -type d -name .git \
     ! -path "${ROOT}/20_Code/*" ! -path "${ROOT}/Library/*" ! -path "*/node_modules/*" \
     ! -path "${ROOT}/.*" 2>/dev/null |
while IFS= read -r g; do say "  $(dirname "$g")"; done

say ""
say "-- Files over 1 GB (candidates for archive / external drive) --"
find "$ROOT" -type f -size +1G ! -path "${ROOT}/Library/*" ! -path "${ROOT}/.*" 2>/dev/null |
while IFS= read -r f; do say "  $f"; done

say ""
if [ $APPLY -eq 1 ]; then
  chmod +x "$UNDO"
  say "Done. Move log: ${LOG}"
  say "Undo everything from this run:  bash \"${UNDO}\""
else
  say "Preview complete. Re-run with --apply to make these changes."
fi
