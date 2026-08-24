# Privacy

Pebble is local-first and has no runtime network behavior, analytics, advertising,
accounts, or cloud synchronization.

Pebble observes only the minimum shell context needed to inhabit the bar:

- current time, for night-specific behavior;
- focused monitor and workspace changes, for placement and occasional ambient reactions;
- bar position, size, visibility, and widget geometry, for safe movement;
- direct clicks and explicit Pebble IPC actions;
- when **Curious cursor** is enabled, pointer position only while the cursor is inside
  the bar strip on the focused monitor (look / lean / rare scoot reactions).

Curious cursor is **on by default** (bar-local only). Turn it off in the PEBBLE
panel anytime. Disabling it returns Pebble to body-only pointer awareness (hover
and clicks on Pebble's sprite). Pebble never tracks the pointer across the wider
desktop, and click handling remains limited to Pebble's own sprite so other bar
modules stay usable.

Pebble does not read window titles, application contents, keyboard input, pointer
movement outside the bar habitat (or outside its body when Curious cursor is off),
notifications, clipboard contents, files in the user's projects, or browsing history.

Persistent data is limited to counters, collected objects, story cooldowns,
preferences (including Curious cursor), and bounded recent episode history in
`~/.local/state/omarchy/pebble/state.json`. The file can be copied for backup or
deleted to reset Pebble. Removing the plugin deliberately leaves it in place so a
later reinstall can resume; the removal instructions explain this explicitly.

Like every Omarchy shell plugin, Pebble executes in the user's long-lived shell
process and is not sandboxed. Review the repository before installation.
