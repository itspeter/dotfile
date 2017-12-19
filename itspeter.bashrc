#!/bin/bash
#
# More ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias tmux='tmux -2'
alias cscope='cscope -bqR'

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'
    alias less='less -R'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
fi

##### Vim Related.
# Set default editor to vim (Mostly for git)
export VISUAL='vim' # use 'gvim -f' if you want to use GUI vim.
export EDITOR="$VISUAL"


# Mount the working drive (SSD)
mount_grep=`mount | grep --color=never /dev/sdb1 | tr -d '\n'`
expected_mount_grep="/dev/sdb1 on /usr/local/google/home/itspeter/ssd1 type ext4 (rw)"
if [ "$mount_grep" != "$expected_mount_grep" ]; then
  echo "Mounting the SSD drive"
  #echo "Got ...$mount_grep" # Debug
  sudo mount /dev/sdb1 ~/ssd1;
fi
cd ~/ssd1/chromeos/src/platform/

# Add the fixed IP if not found on ifconfig "inet addr:10.3.0.11  Bcast:10.255.255.255  Mask:255.0.0.0 "
ifconfig_grep=`ifconfig | grep --color=never -A1 eth0 | tr -d '\n'`
expected_ifconfig_grep="eth0      Link encap:Ethernet  HWaddr 48:0f:cf:44:41:ad            inet addr:192.168.0.11  Bcast:192.168.0.255  Mask:255.255.255.0"

if [ "$ifconfig_grep" != "$expected_ifconfig_grep" ]; then
  echo "Need to set IP address to eth0"
  #echo "Got ...$ifconfig_grep" # Debug
  sudo ifconfig eth0 up 192.168.0.11

  echo "Setup NAT for the eth0"
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo iptables -P FORWARD ACCEPT
  sudo iptables --table filter -I FORWARD -s 192.168.0.0/24 -j ACCEPT
  sudo iptables --table nat -I POSTROUTING -s 192.168.0.0/24 -j MASQUERADE    

  echo "Restarting isc-dhcp-server"
  sudo stop isc-dhcp-server
  sudo start isc-dhcp-server
fi


# copied from Chih-Yu
cros-deploy() {
 if [[ ! $CROS_WORKON_SRCROOT ]]; then
   echo "Should run inside chroot."
   return 1
 fi
 local dut_ip=$1
 local package=$2
 local board="$(ssh ${dut_ip} grep CHROMEOS_RELEASE_BOARD /etc/lsb-release)"
 board="${board##*=}"
 echo "Board: ${board}"

 if ! emerge-"${board}" "${package}"; then
   echo "Emerge failed, abort."
   return 1
 fi
 SSHSOCKET="$(tempfile)"
 rm "${SSHSOCKET}"
 ssh -M -f -N -o ControlPath="${SSHSOCKET}" "${dut_ip}"
 equery-"${board}" f -t "${package}" | grep "^file" | awk '{print $2}' | while read file; do
   echo "Deploy file: ${file}"
   scp -o ControlPath="${SSHSOCKET}" "/build/${board}/${file}" "${dut_ip}:${file}" > /dev/null
 done
 ssh -S "${SSHSOCKET}" -O exit "${dut_ip}"
}
