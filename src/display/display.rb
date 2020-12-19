require 'git';

class Display
  def initialize
  end

  def redraw(settings)
    g = Git.open('./');
    puts g.branch.name
  end
end
