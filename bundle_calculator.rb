require_relative 'lib/bundle_calculator_impl'

class BundleCalculator
  def initialize(json_filename, order_array)
    @json_filename = json_filename
    @order_array = order_array
  end

  def print_calculated_bundles
    BundleCalculatorImpl.new(@json_filename, @order_array).fulfil_order
  end

  def self.usage
    warn 'usage: ruby ./bundle_calculator <bundle json filename> [number format_code] [number format_code]...'
    exit(1)
  end
end

BundleCalculator.usage if ARGV.length <= 1

json_filename = ARGV.shift
unless File.readable?(json_filename)
  warn "Unable to read #{json_filename}"
  BundleCalculator.usage
end

unless ARGV.length.even?
  warn 'Number and format_code must be provided in pairs'
  BundleCalculator.usage
end

order_array = []
ARGV.each_slice(2) { |pair| order_array << pair }
BundleCalculator.new(json_filename, order_array).print_calculated_bundles
