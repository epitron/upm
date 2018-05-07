require 'date'

class DateTime
  def to_i; to_time.to_i; end
end

class File

  #
  # Overly clever which(), which returns an array if more than one argument was supplied,
  # or string/nil if only one argument was supplied. 
  #
  def self.which(*bins)
    results = []
    bins    = bins.flatten
    paths   = ENV["PATH"].split(":").map { |path| File.realpath(path) }.uniq

    paths.each do |dir|
      bins.each do |bin|

        full_path = File.join(dir, bin)
        
        if File.exists?(full_path)
          if bins.size == 1
            return full_path
          else 
            results << full_path 
          end
        end

      end
    end

    bins.size == 1 ? nil : results
  end

  def self.which_is_best?(*bins)
    result = which(*bins.flatten)
    result.is_a?(Array) ? result.first : result
  end
end

module Enumerable
  #
  # Split this enumerable into chunks, given some boundary condition. (Returns an array of arrays.)
  #
  # Options:
  #   :include_boundary => true  #=> include the element that you're splitting at in the results
  #                                  (default: false)
  #   :after => true             #=> split after the matched element (only has an effect when used with :include_boundary)
  #                                  (default: false)
  #   :once => flase             #=> only perform one split (default: false)
  #
  # Examples:
  #   [1,2,3,4,5].split{ |e| e == 3 }
  #   #=> [ [1,2], [4,5] ]
  #
  #   "hello\n\nthere\n".each_line.split_at("\n").to_a
  #   #=> [ ["hello\n"], ["there\n"] ]
  #
  #   [1,2,3,4,5].split(:include_boundary=>true) { |e| e == 3 }
  #   #=> [ [1,2], [3,4,5] ]
  #
  #   chapters = File.read("ebook.txt").split(/Chapter \d+/, :include_boundary=>true)
  #   #=> [ ["Chapter 1", ...], ["Chapter 2", ...], etc. ]
  #
  def split_at(matcher=nil, options={}, &block)
    include_boundary = options[:include_boundary] || false

    if matcher.nil?
      boundary_test_proc = block
    else
      if matcher.is_a? Regexp
        boundary_test_proc = proc { |element| element =~ matcher }
      else
        boundary_test_proc = proc { |element| element == matcher }
      end
    end

    Enumerator.new do |yielder|
      current_chunk = []
      splits        = 0
      max_splits    = options[:once] == true ? 1 : options[:max_splits]

      each do |e|

        if boundary_test_proc.call(e) and (max_splits == nil or splits < max_splits)

          if current_chunk.empty? and not include_boundary
            next # hit 2 boundaries in a row... just keep moving, people!
          end

          if options[:after]
            # split after boundary
            current_chunk << e        if include_boundary   # include the boundary, if necessary
            yielder << current_chunk                         # shift everything after the boundary into the resultset
            current_chunk = []                              # start a new result
          else
            # split before boundary
            yielder << current_chunk                         # shift before the boundary into the resultset
            current_chunk = []                              # start a new result
            current_chunk << e        if include_boundary   # include the boundary, if necessary
          end

          splits += 1

        else
          current_chunk << e
        end

      end

      yielder << current_chunk if current_chunk.any?

    end
  end

  #
  # Split the array into chunks, cutting between the matched element and the next element.
  #
  # Example:
  #   [1,2,3,4].split_after{|e| e == 3 } #=> [ [1,2,3], [4] ]
  #
  def split_after(matcher=nil, options={}, &block)
    options[:after]             ||= true
    options[:include_boundary]  ||= true
    split_at(matcher, options, &block)
  end

  #
  # Split the array into chunks, cutting before each matched element.
  #
  # Example:
  #   [1,2,3,4].split_before{|e| e == 3 } #=> [ [1,2], [3,4] ]
  #
  def split_before(matcher=nil, options={}, &block)
    options[:include_boundary]  ||= true
    split_at(matcher, options, &block)
  end

  #
  # Split the array into chunks, cutting between two elements.
  #
  # Example:
  #   [1,1,2,2].split_between{|a,b| a != b } #=> [ [1,1], [2,2] ]
  #
  def split_between(&block)
    Enumerator.new do |yielder|
      current = []
      last    = nil

      each_cons(2) do |a,b|
        current << a
        if yield(a,b)
          yielder << current
          current = []
        end
        last = b
      end

      current << last unless last.nil?
      yielder << current
    end
  end

  alias_method :cut_between, :split_between
end