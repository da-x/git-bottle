About - git-bottle v0.1-rc
--------------------------

git-bottle is an **experimental** utility for the purpose of saving and restoring the various ``git`` working states *as normal git commits*, effectively snapshotting the current and pertinent state of your working tree and various file states shown under ``git status``:

*   Modified but not staged
*   Staged but not commited
*   Untracked files that are not ignored via ``.gitignore``
*   Unmerged paths (in all the various states - rebase, cherry-pick, or merge)
*   Rebase state
*   Rebase-interactive state
*   Merge state

To illustrate how the commit history looks like when using ``git-bottle``. Suppose that we have a complex state during a merge:

.. code-block:: console

    $ git status

    On branch master
    Your branch and 'origin/master' have diverged,
    and have 3 and 1 different commit each, respectively.
      (use "git pull" to merge the remote branch into yours)
    You have unmerged paths.
      (fix conflicts and run "git commit")

    Changes to be committed:

	modified:   file-non-conflicting-2

    Unmerged paths:
      (use "git add/rm <file>..." as appropriate to mark resolution)

	both modified:   file
	deleted by us:   file-will-be-removed-down
	deleted by them: file-will-be-removed-up

    Changes not staged for commit:
      (use "git add <file>..." to update what will be committed)
      (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   file-non-conflicting-2
	modified:   file-non-conflicting-3

    Untracked files:
      (use "git add <file>..." to include in what will be committed)

	untracked
..


But we decide to put this merge aside for some reason. We use git-bottle, and the result is:

.. code-block:: console

    $ git-bottle
    <some various prints here>

    $ git status
    On branch master
    Your branch is ahead of 'origin/master' by 4 commits.
      (use "git push" to publish your local commits)
    nothing to commit, working directory clean

    $ git-log --oneline --stat
    3251e3b1cf3 (HEAD, master) GIT_BOTTLE_STATE: untracked
     untracked | 3 +++
     1 file changed, 3 insertions(+)
    1075c68e8448 GIT_BOTTLE_STATE: uncommitted
     file-non-conflicting-2 | 1 +
     file-non-conflicting-3 | 1 +
     2 files changed, 2 insertions(+)
    f7f6727daaa3 GIT_BOTTLE_STATE: staged
     file-non-conflicting-2 | 1 +
     1 file changed, 1 insertion(+)
    12992d33063b GIT_BOTTLE_STATE_MERGE: Merge remote-tracking branch 'origin/master'

     .GIT_BOTTLE_MERGE_HEAD                                     | 1 +
     .GIT_BOTTLE_MERGE_MODE                                     | 0
     .GIT_BOTTLE_MERGE_MSG                                      | 6 ++++++
     file                                                       | 5 +++++
     file-will-be-removed-down                                  | 2 ++
     file-will-be-removed-down.1.GIT_BOTTLE_UNMERGED_NORMALIZED | 1 +
     file-will-be-removed-down.3.GIT_BOTTLE_UNMERGED_NORMALIZED | 2 ++
     file-will-be-removed-up.1.GIT_BOTTLE_UNMERGED_NORMALIZED   | 1 +
     file-will-be-removed-up.2.GIT_BOTTLE_UNMERGED_NORMALIZED   | 2 ++
     file.1.GIT_BOTTLE_UNMERGED_NORMALIZED                      | 1 +
     file.2.GIT_BOTTLE_UNMERGED_NORMALIZED                      | 2 ++
     file.3.GIT_BOTTLE_UNMERGED_NORMALIZED                      | 2 ++
     12 files changed, 25 insertions(+)
..

The branch now contains the needed data to restore both the working tree, index, and the meta-data regarding the merge. If we run ``git-unbottle``, we would find outselves back in the complex ``git status`` from above. The special commit messages assist ``git-unbottle`` in the work of unwinding the effects of ``git-bottle``.

Main use case
~~~~~~~~~~~~~

You find yourself working on resolving conflicts in a big merge or a rebase, but some of the conflicts are in other people's code. Those people are not around, or temporarily unavailble. You want to pass the torch of conflict resolution to the other person and shift to work on more interesting things. You are in the midst on the merge, 12 out of 30 files done, meaning you neither ``git-stash`` or a simple ``git-commit`` would get you out of that state. Well, you can work from another clone of the project, but your Eclipse or another IDE was rigged so perfectly to function properly from that single clone path.

``git-bottle`` to the rescue - you bottle up the current unfinished merge, push it to say, by convention e.g. ``bottle/whatever-branch``, and notify the other person. The other guy will do ``git-fetch``, checkout that branch, perform ``git-unbottle``, and resume the merge.

Conflict resolution in a separate commit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When merging, one might want to leave the merge commit as it is and solve the conflicts in a subsequent commit. This way, the conflict resolution is made more explict, cherry-pickable, etc. ``git-bottle`` facilitates with this approach.

A better stash
~~~~~~~~~~~~~~

Never forget again that you have made stashes. Instead, with ``git-bottle``, they could be local branches lying around. Hopefully, this demonstrates that by turning the index and many other working states into the first-class citizen ``commit object``, the flexibility of ``git`` can be improved.


Installation
------------

The ``git-*`` scripts from this repository need to be somewhere in ``$PATH`` for the commands to work.

**Big fat warning**
-------------------

*   ``git-bottle`` is sensitive to the versions of git program used because it saves some of the meta-data, especially during rebase and rebase-interactive. It might break if there is a mismatch of versions of the git program. I have tested it over Git 2.1.0.
*   Be careful with ``git-unbottle`` of states from untrusted sources! The state of rebase-interactive might contain bash scripts.
*   For devs - this is unfinished work. I am sorry if you find the code undocumented/unclear/buggy, but I'd consider every pull request.
