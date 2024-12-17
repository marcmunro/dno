# dno
#### A system for building Arduino software

dno provides a command-line alternative to Arduino IDEs.  It is fast
and easy to use, and supports the creation of documentation and unit
tests, which the standard IDE does not.

It is built around gnu make and is designed to rebuild only what it
has to following code updates.  It automatically links to standard
Arduino libraries and allows user-defined libraries to be added
simply by including them in their own diorectories.

Full documentation will be forthcoming.  In the meantime, check out the
various man pages in the man subdirectory, or the info and help
targets in dno itself.

## Installation

  1) Clone this repository, or download a tarball from the releases
     directory:

         $ git clone https://github.com/marcmunro/dno.git
         $ cd dno

     or:

         $ wget https://github.com/marcmunro/dno/blob/main/releases/<RELEASE>.tgz
         $ tar xvzf <RELEASE>.tgz
         $ cd dno

  1) Run make:

         $ make

  1) As root, run make install:

         $ su
         Password: <enter root password>
         # make install

     or:

         $ sudo make install

  1) Read the docs

         $ dno info
         $ dno help
         $ man dno

  1) Start using it:
  
         $ mkdir <project>
         $ cd <project>
         $ <create a code file>
         $ dno BOARD_TYPE BOARD=<your arduino board name>
         $ dno
         $ dno upload

dno can be uninstalled using `make uninstall`.

## Supported Operating Systems

Anything Unix-like will work, so: Linux, BSD, MacOSX.

Anything else that can run autotools can probably be made to work.

Windows will not be supported unless someone wants to fork the project
or work closely with dno's author to make it happen.

## License

dno is distributed under the General Public License version 3.  See
the [LICENSE](./LICENSE) file.
