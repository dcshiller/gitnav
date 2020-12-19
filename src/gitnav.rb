require_relative './manager.rb'

class GitNav
  def initialize
    Manager.new
  end
end

GitNav.new
