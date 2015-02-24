# Encoding: utf-8

Ohai.plugin(:PciHardware) do
  provides 'pci_hardware'

  def lspci_bin
    unless @lscpi_bin
      so = shell_out("/bin/bash -c 'command -v lspci'")
      lspci_bin = so.stdout.strip
    end
    return lspci_bin unless lspci_bin.empty?
  end

  collect_data(:linux) do
    if lspci_bin
      pci_hardware Mash.new
      so = shell_out("#{lspci_bin} -mmv")
      so.stdout.lines.each do |line|
        line = line.split(':', 2)
        next if length(line) == 0
        fieldname = line[0].strip
        if fieldname == 'Slot'
          device = line[1]
          pci_hardware[device] = {}
        else
          pci_hardware[device][fieldname] = line[1].strip
        end
      end
    end
  end
end
