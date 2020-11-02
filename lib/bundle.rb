class Bundle
  attr_reader :number, :cost

  def initialize(hash)
    @number = hash[:number]
    @cost = hash[:cost]
  end
end
