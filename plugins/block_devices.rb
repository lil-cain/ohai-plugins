# Encoding: utf-8

Ohai.plugin(BlockDevices) do
  provides 'block_devices'

  def blkid_binary
    unless @blkid_binary
      so = shell_out("/bin/bash -c 'command -v blkid'")
      blkid_binary = so.stdout.strip
    end
    return blkid_binary unless blkid_binary.empty?
  end

  def parse_record(line)
    line = line.strip.split
    device = line.shift[0..-2]
    data = {}
    line.each do |field|
      field = field.split('=', 2)
      data[field[0]] = data[field[1][1..-2]]
    end
    return [device, data]
  end

  collect_data(:linux) do
    blkid_bin = blkid_binary
    unless blkid_bin.empty?
      block_devices Mash.new
      so = shell_out(blkid_binary)
      so.lines.each do |line|
        parsed = parse_record(line)
        block_devices[parsed[0]] = parsed[1]
      end
    end
  end
end
