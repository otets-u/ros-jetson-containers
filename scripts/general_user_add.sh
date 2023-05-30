#!/usr/bin/env bash

# user information
USERNAME=user
PASSWORD=user
USER_UID=1000
USER_GID=$USER_UID
USER_DIR=/home/$USERNAME

die() {
    printf '%s\n' "$1"
    show_help
    exit 1
}

# parse options
while :; do
    case $1 in
        --user_name)    # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                USERNAME=$2
                shift
            else
                die 'ERROR: "--user_name" requires a non-empty option argument.'
            fi
            ;;
        --user_passwd)    # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                PASSWORD=$2
                shift
            else
                die 'ERROR: "--user_passwd" requires a non-empty option argument.'
            fi
            ;;
        --user_dir)    # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                USER_DIR=$2
                shift
            else
                die 'ERROR: "--user_dir" requires a non-empty option argument.'
            fi
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac
    shift
done

# add user
groupadd -g $USER_GID $USERNAME && \
    useradd -m -s /bin/bash -u $USER_UID -g $USER_GID -G sudo $USERNAME && \
    echo $USERNAME:$PASSWORD | chpasswd && \
    echo "$USERNAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# to use usb device in docker container
usermod -aG dialout,video,audio $USERNAME

# change user from root to USERNAME
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_aptget

su ${USERNAME}
cd
echo "source ${ROS_ROOT}/install/setup.bash" >> ${USER_DIR}/.bashrc

