require 'json'
require_relative 'post'

class Posts
  attr_reader :posts

  def initialize(json_filename)
    json_array = JSON.parse(File.read(json_filename), symbolize_names: true)
    @posts = json_array.map { |post_hash| Post.new(post_hash) }
  end

  def post_by_format_code(format_code)
    @posts.select { |post| post.format_code == format_code }.first
  end
end
