# Traf

Traf is a proof tree viewer which cooperate with a proof assistant Coq and controlled through Proof General (PG). You are not required to obtain any knowledge to use Traf. You do not have to pay attention to it while proving lemmas by using PG. Traf automatically draws a proof tree corresponding to what you have done while you are interacting with Coq through PG. The trees drawn by Traf are informative and will be of great help.

Traf is an extention to a proof tree viewer named Prooftree. Traf version 0.1 is based on Prooftree-0.13.


<img src="https://raw.github.com/wiki/hide-kawabata/traf/images/emacs_p_or_q_q_or_p.png" width="300"/>
<img src="https://raw.github.com/wiki/hide-kawabata/traf/images/p_or_q_q_or_p.png" width="350"/>



Traf version 0.1 has been developed by Hideyuki Kawabata and Yuta Tanaka, with Yuuki Sasaki and Mai Kimura, at Hiroshima City University.



## Preparation

Following programs are required to build and run Traf.
Older versions of them might requrie some modification on the library and/or Traf's source.

- Coq 8.4, 8.6, 8.7 (8.8 or later are not fully supported yet)
- Proof General 4.4.1pre
- GTK+ 2.0
- Lablgtk 2.18.5 (now you can use the one installed by just typing `opam install lablgtk`)
- OCaml 4.05.0

Checked environments: 

- macOS Sierra 10.12.6
- ubuntu 16.04 LTS

#### Note: for users of Coq 8.7 or later
Proof General requires slight modifications.
Please rebuild PG after applying two patch files in the dir `misc` to 
update `coq/coq.el` and `generic/proof-tree.el` of PG.

    $ cd pg_top_dir
    $ patch -p0 < traf_top_dir/misc/pg-coq.patch
    $ patch -p0 < traf_top_dir/misc/pg-proof-tree.patch
    $ make

Note that Traf still can not communicate with Coq 8.8 correctly
 through rebuilt PG;
e.g., theorem `verification_correct` in Software Foundations `https://softwarefoundations.cis.upenn.edu` can not be treated.


#### FYI: Note for Mac users

On Mac (macOS), the function `Gdk.GC.get_values` of Lablgtk 2.18.5 or
`gdk_gc_get_values()` of GTK+ 2.24.32
 does not seem to work correctly.
It seems that `ml_gdk_gc_get_values()` in `ml_gdk.c` of Lablgtk 2.18.5 returns an unacceptable (maybe uninitialized) set of values which causes exceptions.
Although I have not seen any trouble of this kind
on ubuntu machines,
Traf version 0.1.0 on Mac did not work without applying some modification to `ml_gdk.c` of Lablgtk2 (see `misc/lablgtk2.patch` in detail).

Traf version 0.1.1 has been built such that functions `Gdk.GC.get_values` and `GDraw.drawable#set_line_attributes` of Lablgtk2 are not used so that 
no modification to Lablgtk2 or GTK+ is required.



## How to build

By running `misc/quich_build.sh` at the top directory, 
you can obtain the executable `traf` in newly created directory `build`.
You can copy `traf` anywhere to use it. 

What is done in the process is to follow the instructions shown below:

1. Obtain `prooftree-0.13.tar.gz` and check files.  See `https://askra.de/software/prooftree/` for details of Prooftree. Just for convenience, we have the tarball in the directory `misc`.

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

- Note that you can modify `exec-path` to make the values of `coq-prog-name` and `proof-tree-program` short.

- Note that you can not share coq library if your machine has multiple versions of `coqtop`. Since PG is not smart enough to detect the place where the corresponding version of the library for each `coqtop` is installed (default lib dir: `/usr/local/lib/coq`), we advise that `coq-prog-name` is not a symbolic link to `coqtop`. For example, if you are using Homebrew, we recommend you write

    ```
    (setq coq-prog-name "/usr/local/Cellar/coq/8.6.1_1/bin/coqtop")
    ```
    instead of `/usr/local/bin/coqtop`, which is a symbolic link to the above,
in order to avoid troubles in advance.


## Usage

- While proving a theorem by using Proof General, you can invoke Traf by clicking the "prooftree icon", or equivalently, type `C-c C-d` (`proof-tree-external-display-toggle`).
- You can perform anything while proving with PG; e.g., `C-c RET (proof-goto-point)`, `C-c C-u (proof-undo-last-successful-command)`, etc. The proof tree shown in the Traf window changes synchronously.
- Once a proof of a theorem (`Theorem`, `Lemma`, `Example`, whatever) is finished, i.e., the vernacular command `Qed` is given to Coq, the connection between PG and Traf is closed (but the Traf window remains on the screen and you can manipulate it).
When you start proving another theorem, you are required to invoke Traf again (by entering `C-c C-d`).