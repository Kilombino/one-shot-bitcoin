# One Shot Bitcoin: the first time someone logs in at the keyboard or over
# SSH, offer to set the node up. Installed by the USB installer into
# /etc/profile.d; it does nothing once the node is installed.

oneshot_dir=/opt/one-shot-bitcoin
if [ -t 0 ] && [ -x "${oneshot_dir}/oneshot" ] && [ ! -f "${oneshot_dir}/state/config.env" ] && [ "$(id -u)" != 0 ]; then
	echo
	echo "Welcome to One Shot Bitcoin."
	echo "The node is not set up yet. It takes a few questions and a few minutes."
	printf "Set it up now? [Y/n]: "
	read -r oneshot_answer
	case "${oneshot_answer}" in
		[Nn]*) echo "Later: cd ${oneshot_dir} && ./install.sh" ;;
		*)
			# This user owns the folder and may use Docker. sudo asks for the
			# password you chose in the installer.
			sudo chown -R "$(id -un):$(id -gn)" "${oneshot_dir}" \
				&& sudo usermod -aG docker "$(id -un)" \
				&& ln -sfn "${oneshot_dir}" "${HOME}/one-shot-bitcoin" \
				&& sg docker -c "cd ${oneshot_dir} && ONESHOT_LAN=y ./install.sh"
			echo
			echo "From now on: cd ~/one-shot-bitcoin && ./oneshot status"
			echo "(Log out and in again once, so your user can use Docker directly.)"
			;;
	esac
	unset oneshot_answer
fi
unset oneshot_dir
