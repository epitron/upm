#
# Beginning of File reached! (Raised when reading a file backwards.)
#
class BOFError < Exception; end

class File

  #
  # A streaming `reverse_each` implementation. (For large files, it's faster and uses less memory.)
  #
  def reverse_each(&block)
    return to_enum(:reverse_each) unless block_given?

    seek_end
    reverse_each_from_current_pos(&block)
  end
  alias_method :reverse_each_line, :reverse_each

  #
  # Read the previous `length` bytes. After the read, `pos` will be at the beginning of the region that you just read.
  # Returns `nil` when the beginning of the file is reached.
  #
  # If the `block_aligned` argument is `true`, reads will always be aligned to file positions which are multiples of 512 bytes.
  # (This should increase performance slightly.)
  #
  def reverse_read(length, block_aligned=false)
    raise "length must be a multiple of 512" if block_aligned and length % 512 != 0

    end_pos = pos
    return nil if end_pos == 0

    if block_aligned
      misalignment = end_pos % length
      length      += misalignment
    end

    if length >= end_pos # this read will take us to the beginning of the file
      seek(0)
    else
      seek(-length, IO::SEEK_CUR)
    end

    start_pos = pos
    data      = read(end_pos - start_pos)
    seek(start_pos)

    data
  end

  #
  # Read each line of file backwards (from the current position.)
  #
  def reverse_each_from_current_pos
    return to_enum(:reverse_each_from_current_pos) unless block_given?

    # read the rest of the current line, in case we started in the middle of a line
    start_pos = pos
    fragment = readline rescue ""
    seek(start_pos)

    while data = reverse_read(4096)
      lines = data.each_line.to_a
      lines.last << fragment unless lines.last[-1] == "\n"

      fragment = lines.first

      lines[1..-1].reverse_each { |line| yield line }
    end

    yield fragment
  end

  #
  # Seek to `EOF`
  #
  def seek_end
    seek(0, IO::SEEK_END)
  end

  #
  # Seek to `BOF`
  #
  def seek_start
    seek(0)
  end

  #
  # Read the previous line (leaving `pos` at the beginning of the string that was read.)
  #
  def reverse_readline
    raise BOFError.new("beginning of file reached") if pos == 0

    seek_backwards_to("\n", 512, -2)
    new_pos = pos
    data = readline
    seek(new_pos)
    data
  end

  #
  # Scan through the file until `string` is found, and set the IO's +pos+ to the first character of the matched string.
  #
  def seek_to(string, blocksize=512)
    raise "Error: blocksize must be at least as large as the string" if blocksize < string.size

    loop do
      data = read(blocksize)

      if index = data.index(string)
        seek(-(data.size - index), IO::SEEK_CUR)
        break
      elsif eof?
        return nil
      else
        seek(-(string.size - 1), IO::SEEK_CUR)
      end
    end

    pos
  end

  #
  # Scan backwards in the file until `string` is found, and set the IO's +pos+ to the first character after the matched string.
  #
  def seek_backwards_to(string, blocksize=512, rindex_end=-1)
    raise "Error: blocksize must be at least as large as the string" if blocksize < string.size

    loop do
      data = reverse_read(blocksize)

      if index = data.rindex(string, rindex_end)
        seek(index+string.size, IO::SEEK_CUR)
        break
      elsif pos == 0
        return nil
      else
        seek(string.size - 1, IO::SEEK_CUR)
      end
    end

    pos
  end
  alias_method :reverse_seek_to, :seek_backwards_to

  #
  # Iterate over each line of the file, yielding the line and the byte offset of the start of the line in the file
  #
  def each_line_with_offset
    return to_enum(:each_line_with_offset) unless block_given?

    offset = 0

    each_line do |line|
      yield line, offset
      offset = tell
    end
  end

end
