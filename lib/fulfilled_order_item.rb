class FulfilledOrderItem
  attr_reader :post, :total

  def initialize(post, total, bundle_size_to_count = {})
    @post = post
    @total = total
    @bundle_size_to_count = bundle_size_to_count
  end

  def format_code
    @post.format_code
  end

  def increment_bundle_size(bundle_size)
    @bundle_size_to_count[bundle_size] = 0 unless @bundle_size_to_count.key?(bundle_size)
    @bundle_size_to_count[bundle_size] += 1
  end

  def count_for_bundle_size(bundle_size)
    @bundle_size_to_count[bundle_size] || 0
  end

  def complete?
    amount = 0
    @bundle_size_to_count.each_pair do |bundle_size, count|
      amount += bundle_size * count
    end
    amount == @total
  end

  def number_of_bundles
    @bundle_size_to_count.values.sum
  end

  def dup
    FulfilledOrderItem.new(@post, @total, @bundle_size_to_count.dup)
  end

  def total_cost
    @post.bundles.map { |bundle| cost_for_bundle_size(bundle.number) }.sum
  end

  def cost_for_bundle_size(bundle_size)
    selected_bundle = @post.bundles.find { |bundle| bundle.number == bundle_size }
    return 0 if selected_bundle.nil?

    count_for_bundle_size(bundle_size) * selected_bundle.cost
  end
end
