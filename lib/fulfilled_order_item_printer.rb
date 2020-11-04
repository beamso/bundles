require 'stringio'

class FulfilledOrderItemPrinter
  def print(fulfilled_order_item)
    return unless fulfilled_order_item.complete?

    output_string = StringIO.new
    output_string.puts format("#{fulfilled_order_item.total} #{fulfilled_order_item.format_code} $%0.2f",
                              fulfilled_order_item.total_cost)
    bundles = fulfilled_order_item.post.bundles
    bundles.each { |bundle| print_bundle(fulfilled_order_item, bundle, output_string) }
    output_string.puts('')
    puts output_string.string
  end

  def print_bundle(fulfilled_order_item, bundle, output_string)
    number_in_bundle = bundle.number
    count = fulfilled_order_item.count_for_bundle_size(number_in_bundle)
    return unless count.positive?

    bundle_cost = fulfilled_order_item.cost_for_bundle_size(number_in_bundle)
    output_string.puts format(" #{count} x #{number_in_bundle} $%0.2f", bundle_cost)
  end
end
