# Privacy

Pebble is local-first and has no runtime network behavior, analytics, advertising,
accounts, or cloud synchronization.

Pebble observes only the minimum shell context needed to inhabit the bar:

- current time, for night-specific behavior;
- focused monitor and workspace changes, for placement and occasional ambient reactions;
- bar position, size, visibility, and widget geometry, for safe movement;
- direct clicks and explicit Pebble IPC actions.

Pebble does not read window titles, application contents, keyboard input, pointer
movement outside its own body, notifications, clipboard contents, files in the
user's projects, or browsing history.

Persistent data is limited to counters, collected objects, story cooldowns,
preferences, and bounded recent episode history in
`~/.local/state/omarchy/pebble/state.json`. The file can be copied for backup or
deleted to reset Pebble. Removing the plugin deliberately leaves it in place so a
later reinstall can resume; the removal instructions explain this explicitly.

Like every Omarchy shell plugin, Pebble executes in the user's long-lived shell
process and is not sandboxed. Review the repository before installation.

