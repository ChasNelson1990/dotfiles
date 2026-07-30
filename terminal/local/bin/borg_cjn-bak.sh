#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=/run/media/chas/CJN.bak/$HOSTNAME

# BORG_PASSPHRASE is intentionally not set here -- it's supplied by
# `pass-cli run` (see the systemd service), which resolves the
# pass://... reference in its own environment before this script starts.
# The local keyfile alone is no longer sufficient to decrypt a backup.

# Exoscale bucket to mirror the local repo to, for off-site backup (see
# core/README.md's "Off-site backup: Borg + Exoscale" decision). Not a
# secret -- override in a local, gitignored env file if it differs.
: "${BORG_OFFSITE_BUCKET:=REPLACE_ME_exoscale_bucket_name}"

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

# Backup config and app data -- not the whole system. /var is dropped
# entirely (package caches, docker images/volumes, logs: all either
# reproducible or low-value for an off-site copy); large/reproducible
# directories under /home and /root are excluded below, matching
# core/README.md's "system/app data... tens of GB, not hundreds" scope,
# not a full-system image.

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/home/*/Downloads/*' \
    --exclude '/home/*/builds/*'    \
    --exclude '/home/*/.cargo/*'    \
    --exclude '/home/*/.rustup/*'   \
    --exclude '/home/*/.npm/*'      \
    --exclude '/home/*/.nvm/*'      \
    --exclude '/home/*/.local/share/Trash/*' \
    --exclude '**/node_modules'     \
    --exclude '**/.venv'            \
                                    \
    ::'{now}'                       \
    /etc                            \
    /home                           \
    /root                           \

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

info "Mirroring repository to Exoscale (off-site copy)"

# Borg 1.4 (stable) has no native S3 backend -- Borg 2.0 does, but it's
# still beta (2.0.0b22 as of this writing), so the local repo above stays
# the primary write target and rclone mirrors it out afterward instead.
# The "exoscale" remote is configured entirely via RCLONE_CONFIG_EXOSCALE_*
# environment variables (set on the systemd service), so no rclone.conf
# with credentials ever touches disk.

rclone sync "${BORG_REPO}" "exoscale:${BORG_OFFSITE_BUCKET}/${HOSTNAME}" \
    --fast-list                     \
    --verbose                       \

offsite_exit=$?

# use highest exit code as global exit code
global_exit=$backup_exit
[ ${prune_exit} -gt ${global_exit} ] && global_exit=${prune_exit}
[ ${offsite_exit} -gt ${global_exit} ] && global_exit=${offsite_exit}

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and off-site mirror finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or off-site mirror finished with warnings"
else
    info "Backup, Prune, and/or off-site mirror finished with errors"
fi

exit ${global_exit}
