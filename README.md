# Traf

Traf is a proof tree viewer which cooperates with a proof assistant Coq and is controlled through Proof General (PG). Traf is easy to use;
actually all what you have to do to use Traf is just to invoke it. You do not have to pay attention to it while proving lemmas by using PG. Traf automatically draws a proof tree corresponding to what you have done while you are interacting with Coq through PG. The trees drawn by Traf are informative and will be of great help.

Traf is an extention to a proof tree viewer named Prooftree. Traf version 0.1 is based on Prooftree-0.13.


<img src="https://raw.github.com/wiki/hide-kawabata/traf/images/emacs_p_or_q_q_or_p.png" width="300"/>
<img src="https://raw.github.com/wiki/hide-kawabata/traf/images/p_or_q_q_or_p.png" width="350"/>



Traf version 0.1 has been developed by Hideyuki Kawabata and Yuta Tanaka, with Yuuki Sasaki and Mai Kimura, at Hiroshima City University [1].

This is version 0.1.2 of Traf.

[1] Hideyuki Kawabata, Yuta Tanaka, Mai Kimura and Tetsuo Hironaka, Traf: a Graphical Proof Tree Viewer Cooperating with Coq through Proof General, 16th Asian Symposium on Programming Languages and Systems (APLAS 2018), LNCS 11275, pp.157--165, 2018. DOI: 10.1007/978-3-030-02768-1_9

## News

A New version of Traf is comming soon!
- GTK3 based, utilizing lablgtk3 and cairo2
- Supports for Fitch style-like proof tree drawing

## Requirement

Following programs are required to build and run Traf.
Numbers indicate tested versions of corresponding software.

- Coq 8.6.1, 8.7.2, 8.8.0 (with or without mathcomp 1.7.0)
- Proof General 4.5, 4.4.1pre (use of Coq 8.7 or later requires rebuild of PG; see below)
- GTK+ 2.0
- Lablgtk 2.18.11, 2.18.10, 2.18.5 (`opam install lablgtk`)
- OCaml 4.11.1, 4.10.0, 4.05.0

Checked environments: 

- macOS Catalina 10.15.7, Mojave 10.14.6, Sierra 10.12.6
- ubuntu 16.04 LTS

#### Note: a bug ?
On macOS Mojave (10.14.*), Traf does not seem to work smoothly; 
it does not update what is displayed in its window while it is running background.
You seem to be required to give a focus on the window to update the tree shown by Traf.

Known workaround: when you use Split View to show Traf and Emacs on a screen simultaneously,
no problem seems to occur.

#### Note: for users of Coq 8.7 or later with PG 4.4.1
Proof General requires slight modification.
Please apply the patch file in `misc` and rebuild PG.

    $ cd pg_top_dir
    $ patch -p0 < traf_top_dir/misc/pg.patch
    $ make

Note 0: Probably this modification is not required for PG 4.5.

Note 1: This modification of PG is also recommended for Coq 8.6 users because of a slight (preferable, maybe) change of behavior.
Note 2: Proof General v4.4 (released on 19 Sep 2016) is not supported. Please use later versions.

Note 3: When you install PG by using MELPA, you might have to modify files in a directory named like ~/.emacs.d/elpa/proof-general-20181226.2300/. Be sure that you might have to byte-compile .el files into .elc files.

## Building Traf

Run `misc/quick_build.sh` at the Traf's top directory,
and you will get the executable `traf` in newly created directory `build`.
You can copy `traf` anywhere you want.

    $ cd traf_top_dir
    $ sh misc/quick_build.sh



#### FYI: What is done by `misc/quick_build.sh`:

1. Obtain `prooftree-0.13.tar.gz`.  See `https://askra.de/software/prooftree/` for details of Prooftree. Just for convenience, we have the tarball in the directory `misc`.

    ```
    $ cd traf_top_dir
    $ tar zxfv ./misc/prooftree-0.13.tar.gz
    ```
    The above command creates a directory named `prooftree-0.13`.
    Let's rename it `build`.

    ```
    $ mv prooftree-0.13 build
    ```


2. Put additional files and a patch file in `src` into `build`.

    ```
    $ cp ./src/* ./build/
    ```

3. Apply the patch for Traf.
  
    ```
    $ cd build
    $ patch -p1 < prooftree-to-traf.patch
    ```

4. Build.

    ```
    $ ./configure
    $ make
    ```
    You will have `traf` in the current directory, i.e., `build`.
    If you want, type `make install` to install traf in a public area.



## Settings

Put following lines in `.emacs` (the 2nd line only is related to Traf):

    (setq coq-prog-name "/home/where/my/thoughts/escaping/coqtop")
    (setq proof-tree-program "/home/where/my/musics/playing/traf")
    (load "/home/where/my/love/lies/waiting/generic/proof-site")

- The third line is not required if you have been already using PG, or you have install PG by using MELPA.
- Note that you can modify `exec-path` to make the values of `coq-prog-name` and `proof-tree-program` short.
- Note that you can not share coq library if your machine has multiple versions of `coqtop`. Since PG is not smart enough to detect the place where the corresponding version of the library for each `coqtop` is installed (default lib dir: `/usr/local/lib/coq`), we advise that `coq-prog-name` is not a symbolic link to `coqtop`. For example, if you are using Homebrew, we recommend you write

    ```
    (setq coq-prog-name "/usr/local/Cellar/coq/8.6.1_1/bin/coqtop")
    ```
    instead of `/usr/local/bin/coqtop`, which is a symbolic link to the above,
in order to avoid troubles in advance.


## Usage

- While proving a theorem by using Proof General, you can invoke Traf by clicking the "prooftree icon", or equivalently, type `C-c C-d` (`proof-tree-external-display-toggle`).
Note that if you are using company-coq `C-c C-d` might be assigned to a different function.
- You can perform anything while proving with PG; e.g., `C-c RET (proof-goto-point)`, `C-c C-u (proof-undo-last-successful-command)`, etc. The proof tree shown in the Traf window changes synchronously.
- Once a proof of a theorem (`Theorem`, `Lemma`, `Example`, whatever) is finished, i.e., the vernacular command `Qed` is given to Coq, the connection between PG and Traf is closed (but the Traf window remains on the screen and you can manipulate it).
When you start proving another theorem, you are required to invoke Traf again (by entering `C-c C-d`).
