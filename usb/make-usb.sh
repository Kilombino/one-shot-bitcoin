#!/usr/bin/env bash
# Builds the One Shot Bitcoin USB image: the official Ubuntu Server installer
# plus this repository, so a computer installed from it comes up with Docker
# and One Shot Bitcoin ready.
#
#   usb/make-usb.sh              builds one-shot-bitcoin-usb.iso in usb/build/
#   usb/make-usb.sh /dev/sdX     also writes it to that pendrive (ERASES IT)
#
# What it does, so you can check it:
#   1. Downloads Ubuntu Server 24.04 from releases.ubuntu.com and verifies it
#      against Ubuntu's signed SHA256SUMS.
#   2. Adds a folder /oneshot with this repository and the installer answers
#      (usb/user-data), and one boot menu entry that uses them.
# Nothing inside Ubuntu is modified.
#
# Needs: curl, gpg, sha256sum, and xorriso (or Docker, to run xorriso in).

set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
ROOT="$(dirname "${HERE}")"
BUILD="${HERE}/build"
RELEASES="https://releases.ubuntu.com/24.04"
# Ubuntu CD Image Automatic Signing Key (2012)
UBUNTU_KEY="843938DF228D22F7B3742BC0D94AA3F0EFE21092"
OUT="${BUILD}/one-shot-bitcoin-usb.iso"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
for tool in curl gpg sha256sum tar; do command -v "${tool}" >/dev/null || die "${tool} is needed."; done

xorriso_run() {
	if command -v xorriso >/dev/null; then
		( cd "${BUILD}" && xorriso "$@" )
	elif command -v docker >/dev/null; then
		# Runs as root inside the container; hand what it wrote back to you.
		docker run --rm -e OWNER="$(id -u):$(id -g)" -v "${BUILD}:/w" -w /w alpine:3.22 sh -c \
			'apk add --no-cache xorriso >/dev/null && xorriso "$@"; rc=$?; chown "$OWNER" /w/* 2>/dev/null; exit $rc' xorriso "$@"
	else
		die "xorriso is needed (sudo apt install xorriso), or Docker to run it in."
	fi
}

mkdir -p "${BUILD}/oneshot"
cd "${BUILD}"

echo "1/4 Finding the latest Ubuntu Server 24.04 and checking its signature..."
curl -fsSL -o SHA256SUMS "${RELEASES}/SHA256SUMS"
curl -fsSL -o SHA256SUMS.gpg "${RELEASES}/SHA256SUMS.gpg"
export GNUPGHOME="${BUILD}/gnupg"; mkdir -p -m 700 "${GNUPGHOME}"
gpg --quiet --list-keys "${UBUNTU_KEY}" >/dev/null 2>&1 \
	|| gpg --quiet --keyserver hkps://keyserver.ubuntu.com --recv-keys "${UBUNTU_KEY}" \
	|| die "Could not fetch Ubuntu's signing key."
gpg --quiet --verify SHA256SUMS.gpg SHA256SUMS 2>/dev/null || die "Ubuntu's SHA256SUMS signature does not verify. Stopping."
ISO="$(sed -n 's/^[0-9a-f]\{64\} \*\(ubuntu-24\.04[0-9.]*-live-server-amd64\.iso\)$/\1/p' SHA256SUMS | sort -V | tail -n 1)"
[[ -n "${ISO}" ]] || die "No Ubuntu Server image found in SHA256SUMS."

echo "2/4 Downloading ${ISO} (about 4 GB; resumes if interrupted)..."
curl -fL -C - -o "${ISO}" "${RELEASES}/${ISO}"
grep " \*${ISO}\$" SHA256SUMS | sha256sum -c --quiet - || die "${ISO} does not match Ubuntu's checksum. Delete it and run this again."

echo "3/4 Adding One Shot Bitcoin..."
# The repository as it is here, with its git history so ./oneshot check works.
tar -czf oneshot/one-shot-bitcoin.tar.gz -C "${ROOT}" --exclude=./state --exclude=./usb/build .
cp "${HERE}/user-data" "${HERE}/meta-data" "${HERE}/first-login.sh" oneshot/
rm -f grub.cfg "${OUT}"
xorriso_run -osirrox on -indev "${ISO}" -extract /boot/grub/grub.cfg grub.cfg >/dev/null 2>&1
chmod u+w grub.cfg
grep -q 'linux[[:space:]]*/casper/vmlinuz' grub.cfg || die "Ubuntu's boot menu is not as expected; this script needs updating."
# One new first entry. It has no 'autoinstall' word on purpose: the installer
# then asks you to confirm before it touches the disk.
{
	cat <<'MENU'
menuentry "Install One Shot Bitcoin (Ubuntu Server)" {
	set gfxpayload=keep
	linux	/casper/vmlinuz ds=nocloud\;s=/cdrom/oneshot/ ---
	initrd	/casper/initrd
}
MENU
	cat grub.cfg
} > grub.new && mv grub.new grub.cfg
sed -i 's/^set timeout=.*/set timeout=30/' grub.cfg
xorriso_run -indev "${ISO}" -outdev "$(basename "${OUT}")" -boot_image any replay \
	-map oneshot /oneshot -map grub.cfg /boot/grub/grub.cfg >/dev/null 2>&1
[[ -s "${OUT}" ]] || die "The image was not written."
( cd "${BUILD}" && sha256sum "$(basename "${OUT}")" > "$(basename "${OUT}").sha256" )

echo "4/4 Done: ${OUT}"
cat "${OUT}.sha256"

if [[ -n "${1:-}" ]]; then
	DEV="$1"
	[[ -b "${DEV}" ]] || die "${DEV} is not a disk."
	echo
	lsblk -o NAME,SIZE,MODEL,TRAN "${DEV}" || true
	read -r -p "Everything on ${DEV} will be ERASED. Type its name again to continue: " again
	[[ "${again}" == "${DEV}" ]] || die "Not written."
	sudo dd if="${OUT}" of="${DEV}" bs=4M status=progress conv=fsync
	echo "Written. Boot the computer from this pendrive."
else
	echo
	echo "Write it to a pendrive with balenaEtcher or Rufus, or: usb/make-usb.sh /dev/sdX"
fi
