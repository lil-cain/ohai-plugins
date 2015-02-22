# Encoding: UTF-8

Ohai.plugin(:KernelModules) do
  provides 'kernel_modules'

  collect_data(:linux) do
    kernel_modules Mash.new
    r_fd = File.open('/proc/modules', 'r')
    r_fd.each_line do |line|
      line = line.split(/\s+/)
      kernel_modules[line[0]] = { state: line[4],
                                  depends: line[3].split(',') }
    end
  end
end
