class OrderItem
  attr_reader :number, :format_code

  def initialize(array)
    @number =
      begin
        Integer(array.first)
      rescue ArgumentError
        nil
      end
    @format_code = array.last
  end

  def valid_number?
    return false if @number.nil?

    @number.positive?
  end

  def valid_format_code?(posts)
    posts.post_by_format_code(format_code) != nil
  end
end
