# Traf

Traf is a proof tree viewer which cooperate with a proof assistant Coq and controlled through Proof General (PG). You are not required to obtain any knowledge to use Traf. You do not have to pay attention to it while proving lemmas by using PG. Traf automatically draws a proof tree corresponding to what you have done while you are interacting with Coq through PG. The trees drawn by Traf are informative and will be of great help.

Traf is an extention to a proof tree viewer named Prooftree. Traf version 0.1 is based on Prooftree-0.13.

Traf version 0.1 has been developed by Hideyuki Kawabata and Yuta Tanaka, with Yuuki Sasaki and Mai Kimura, at Hiroshima City University.


## Preparation

Following programs are required to build and run Traf.
Older versions of them might requrie some modification on the library and/or Traf's source.

- Coq 8.4 or 8.6 (8.7 is not supported yet)
- Proof General 4.4.1pre
- GTK+ 2.0
- Lablgtk 2.18.5 (Note: on Mac, you might need to recompile the library; see below.)
- OCaml 4.05.0

Checked environments: 

- macOS Sierra 10.12.6
- ubuntu 16.04 LTS.

### Note for Mac (?)

Lablgtk2 2.18.5 seems to require fixes.
It seems that `ml_gdk_gc_get_values()` in `ml_gdk.c` sometimes return an unacceptable (maybe uninitialized) set of values which cause exceptions.
Although this phenomenon has not happened on my ubuntu machine,
My Mac always suffered from it.


A quick workaround is to rewrite `src/ml_gdk.c` of lablgtk2 by applying the supplemental patch in `misc` directory, and recompile the library.

    $ cd /shomewhere/lablgtk-2.18.5/src
    $ patch -p1 < patch_file_for_lablgtk2




## Installation

1. Obtain `prooftree-0.13.tar.gz` and check files.  See `https://askra.de/software/prooftree/` for details of Prooftree. Just for convenience, we have the tarball in `misc` directory.

    ```
    $ tar zxfv prooftree-0.13.tar.gz
    ```
The above command creates a directory named `prooftree-0.13`.


2. Put additional files and a patch file in `src` into `prooftree-0.13`.

    ```
    $ cp <files in src> ./prooftree-0.13
    ```

3. Apply the patch for Traf.
  
    ```
    $ cd prooftree-0.13
    $ patch -p1 < the_patch_file
    ```

4. Build.

    ```
    $ ./configure
    $ make
    $ make install   <--- optional
    ```

## Settings

Put following lines in `.emacs`.

    (setq coq-prog-name "/home/where/my/thoughts/escaping/coqtop")
    (setq proof-tree-program "/home/where/my/musics/playing/traf")
    (load "/home/where/my/love/lies/waiting/generic/proof-site")
    
Note that you can modify `exec-path` to make the values of `coq-prog-name` and `proof-tree-program` short.

## Usage

- While proving by using Proof General, you can invoke Traf by clicking the "prooftree icon", or equivalently, type `C-c C-d` (`proof-tree-external-display-toggle`).
- When a Theorem (or Lemma, Example, etc.) is finished, the connection between PG and Traf is closed. When you start proving next Theorem, invoke Traf again.