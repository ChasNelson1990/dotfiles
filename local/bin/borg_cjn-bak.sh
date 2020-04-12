#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/run/media/chas/CJN.bak/$HOSTNAME

# Setting this, so you won't be asked for your repository passphrase:
# Note: we use a blank passphrase with a local keyfile that must be copied to another device manually if access is needed
export BORG_PASSPHRASE=""

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

if [ ! -d BORG_REPO ]; then
    info "Backup repository doesn't exist! Creating new repository."
    borg init                       \
        --encryption keyfile        \
        --verbose                   \
        --show-rc                   \
    
    create_exit=$?
    if [ ${create_exit} -eq 0 ]; then
        info "Created repository successfully"
    elif [ ${create_exit} -eq 1 ]; then
        info "Creating repository finished with warnings"
    else
        info "Creating repository failed with errors"
    fi
fi

info "Starting backup"

# Backup the most important directories into an archive named for now:

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/var/cache/*'        \
    --exclude '/var/tmp/*'          \
                                    \
    ::'{now}'                       \
    /etc                            \
    /home                           \
    /root                           \
    /var                            \

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly archives:

borg prune                          \
    --list                          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \
    --verbose                       \
    --show-rc                       \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}
