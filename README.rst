=====
Gitch
=====


With M-x ``gitch-switch-branch``, gitch will close your currently open file buffers and, after switching to another git branch, open all files that were open when you last visited this branch.

It uses desktop.el to save the list of buffers and reopen them later.
It uses git-emacs for switching between branches.

M-x ``gitch-switch-repository`` is also provided, to provide the same functionality between repositories.

M-x ``gitch-new-branch`` can be used (but is not required) to save the current context and start a new branch.

Note that, for switching branches, gitch automatically stashes any pending changes and reapplies these automatically when switching back.



Requirements:
-------------
 - git-emacs    https://github.com/tsgates/git-emacs
 - desktop.el   http://repo.or.cz/w/emacs.git/blob/HEAD:/lisp/desktop.el


Usage:
------
 - M-x ``gitch-switch-branch``:
          1. Close all current buffers.
          2. Stash changes.
          3. Switch to branch X.
          4. Pop stash if any for branch X.
          5. Open buffers that were previously open for branch X.
 - M-x ``gitch-switch-repository``: Same as above but for repositories.
 - M-x ``gitch-save-buffers``: Save buffers for the current branch.
 - M-x ``gitch-load-buffers``: Load buffers for the current branch.
 - M-x ``gitch-new-branch``:  Save buffers, checkout new branch.
