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


# Mount the 500G SSD. There is another 500G partition not mounted.
mount_grep=`mount | grep --color=never /dev/sdc1 | tr -d '\n' | grep --color=never -o -e 'sdc1 on .*ssd1'`
expected_mount_grep="sdc1 on /usr/local/google/home/itspeter/ssd1"

if [ "$mount_grep" != "$expected_mount_grep" ]; then
  echo "Mounting the SSD1(500G) drive"
  #echo "Got ...$mount_grep" # Debug
  sudo mount /dev/sdc1 ~/ssd1;
fi
cd ~/ssd1/chromeos/src/platform/

# Mount the 2T SSD. There is another 2T partition not formatted
mount_grep=`mount | grep --color=never /dev/sda1 | tr -d '\n' | grep --color=never -o -e 'sda1 on .*ssd2'`
expected_mount_grep="sda1 on /usr/local/google/home/itspeter/ssd2"

if [ "$mount_grep" != "$expected_mount_grep" ]; then
  echo "Mounting the SSD2(2T) drive"
  #echo "Got ...$mount_grep" # Debug
  sudo mount -o nosuid /dev/sda1 ~/ssd2;
fi

# Add the fixed IP if not found on ifconfig "inet addr:10.3.0.11  Bcast:10.255.255.255  Mask:255.0.0.0 "
ifconfig_grep=`ifconfig | grep --color=never -A1 eth1 | tr -d '\n' | grep --color=never -o -e 'inet.*netmask'`
expected_ifconfig_grep="inet 192.168.0.11  netmask"

if [ "$ifconfig_grep" != "$expected_ifconfig_grep" ]; then
  echo "Need to set IP address to eth1"
  #echo "Got ...$ifconfig_grep" # Debug
  sudo ifconfig eth1 up 192.168.0.11

  echo "Setup NAT for the eth0"
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo iptables -P FORWARD ACCEPT
  sudo iptables --table filter -I FORWARD -s 192.168.0.0/24 -j ACCEPT
  sudo iptables --table nat -I POSTROUTING -s 192.168.0.0/24 -j MASQUERADE    

  echo "Restarting isc-dhcp-server"
  sudo service isc-dhcp-server stop
  sudo service isc-dhcp-server start
  sudo service isc-dhcp-server status
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
