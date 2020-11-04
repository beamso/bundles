require_relative 'posts'
require_relative 'order_item'
require_relative 'fulfilled_order_item'
require_relative 'fulfilled_order_item_printer'
require 'byebug'

class BundleCalculatorImpl
  attr_reader :order_items

  def initialize(json_filename, order_array)
    @posts = Posts.new(json_filename)
    @order_items = order_array.map { |order_item_array| OrderItem.new(order_item_array) }
  end

  def validate_order_items
    valid_order_items = []
    @order_items.each do |order_item|
      valid_number = order_item.valid_number?
      valid_format_code = order_item.valid_format_code?(@posts)
      warn "Invalid number #{order_item.number} for #{order_item.format_code}" unless valid_number
      warn "Invalid format_code #{order_item.format_code}" unless valid_format_code
      valid_order_items << order_item if valid_number && valid_format_code
    end
    valid_order_items
  end

  def fulfil_order
    printer = FulfilledOrderItemPrinter.new
    fulfil_order_items.map { |fulfilled_order_item| printer.print(fulfilled_order_item) }
  end

  def fulfil_order_items
    validate_order_items.map { |valid_order_item| fulfil_order_item(valid_order_item) }
  end

  def fulfil_order_item(order_item)
    post = @posts.post_by_format_code(order_item.format_code)
    bundles = post.bundles
    smallest_bundle = bundles.min { |a, b| a.number <=> b.number }
    order_item_number = order_item.number
    if order_item_number < smallest_bundle.number
      warn "Cannot fulfil order of #{order_item_number} #{order_item.format_code}"
      return FulfilledOrderItem.new(post, order_item_number)
    end
    fulfil_order_item_for_post(post, bundles, order_item_number)
  end

  def fulfil_order_item_for_post(post, bundles, order_item_number)
    bundle_sizes = bundles.map(&:number).sort { |a, b| b <=> a }
    fulfilled_order_items = fulfil_order_item_for_post_with_bundle_sizes(
      bundle_sizes, order_item_number, FulfilledOrderItem.new(post, order_item_number)
    ).flatten.compact
    complete_fulfilled_order_items = fulfilled_order_items.select(&:complete?)
    selected_fulfilled_order_item = smallest_fulfilled_order_item(complete_fulfilled_order_items)
    if selected_fulfilled_order_item.nil?
      warn_of_unfulfilled_order_item(post, order_item_number)
    else
      selected_fulfilled_order_item
    end
  end

  def fulfil_order_item_for_post_with_bundle_sizes(bundle_sizes, remaining, fulfilled_order_item)
    return [fulfilled_order_item] if remaining.zero? || fulfilled_order_item.complete?

    test_remaining = test_remaining(bundle_sizes, remaining, fulfilled_order_item)
    return test_remaining unless test_remaining.empty?

    fulfilled_order_items = bundle_sizes.map do |bundle_size|
      if bundle_size <= remaining
        working_fulfilled_order_item = fulfilled_order_item.dup
        working_fulfilled_order_item.increment_bundle_size(bundle_size)
        new_remaining = remaining - bundle_size
        fulfil_order_item_for_post_with_bundle_sizes(bundle_sizes, new_remaining, working_fulfilled_order_item)
      else
        fulfilled_order_item
      end
    end
    fulfilled_order_items.compact.flatten
  end

  def test_remaining(bundle_sizes, remaining, fulfilled_order_item)
    max_bundle_size = bundle_sizes.max
    return [] if remaining % max_bundle_size != 0 || (remaining / max_bundle_size).zero?

    count = remaining / max_bundle_size
    working_fulfilled_order_item = fulfilled_order_item.dup
    (1..count).each { |_i| working_fulfilled_order_item.increment_bundle_size(max_bundle_size) }
    [working_fulfilled_order_item]
  end

  def smallest_fulfilled_order_item(complete_fulfilled_order_items)
    complete_fulfilled_order_items.min do |a, b|
      a.number_of_bundles <=> b.number_of_bundles
    end
  end

  def warn_of_unfulfilled_order_item(post, order_item_number)
    warn "Cannot fulfil order of #{order_item_number} #{post.format_code}"
    FulfilledOrderItem.new(post, order_item_number)
  end
end
