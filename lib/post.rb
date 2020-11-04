require_relative 'bundle'

class Post
  attr_reader :submission_format, :format_code, :bundles

  def initialize(hash)
    @submission_format = hash[:submission_format]
    @format_code = hash[:format_code]
    bundles_array = hash[:bundles]
    @bundles = if bundles_array
                 bundles_array.map { |bundle_hash| Bundle.new(bundle_hash) }
               else
                 []
               end
  end
end
