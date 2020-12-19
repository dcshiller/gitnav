class Controls
  attr_accessor :settings

  def initialize
    @callback
  end

  def on_update(&block)
    @callback = block
  end
end
