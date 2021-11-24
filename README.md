# Gitnav

This is a simple program for navigating git branches from a cli interface, using
up and down arrow keys.


## Installation

To get started, clone this repo and install its dependencies with bundle (by
running `bundle install` in the root.) This requires ruby to be installed on
your system. The program can then by run with `ruby gitnav.rb`. It will open in
the git instance of the current working directory. 

Suggestion: it is helpful to alias this command `ruby
~/PATH/TO/DIRECTORY/gitnav.rb` to run this command easily in other git
instances.

## Usage

Use arrow keys to navigate between branches. Selecting up or down ('j' or 'k')
will highlight the next branch. Pressing enter will checkout the current
selected branch. Pressing the right arrow key ('l') will checkout the current
selected branch and exit. Pressing 'q' will exit without checking out another
branch.

Pressing 'x' will delete the currently selected branch. If the branch is not yet
merged, you will see a y/n confirm response in the message log below the
branchs.

Pressing 't' will toggle between sorting by branch name and sorting by last
commit date.

Pressing 'd' will display date and author data for each branch.
