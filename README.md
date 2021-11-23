# Gitnav

This is a simple program for navigating git branches from a cli interface, using
up and down arrow keys (or j and k).


## Installation

To get started, clone this repo and install its dependencies with bundle (by
running `bundle install` in the root.) This requires ruby to be installed on
your system. The program can then by run with `ruby gitnav.rb`. It will open in
the git instance of the current working directory. 

Suggestion: it is helpful to alias this command `ruby
~/PATH/TO/Directory/gitnav.rb` to run this command easily in other git
instances.

## Usage

Use arrow keys to navigate between branches. Selecting up or down will highlight
the next branch. Hitting enter will checkout the current selected branch.
Hitting the right arrow key will checkout the current selected branch and exit.
Hitting 'q' will exit without checking out another branch. Hitting 'x' will
delete the currently selected branch.
