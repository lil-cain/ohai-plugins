# Encoding: utf-8
Ohai.plugin(:Magento) do
  depends 'webapps'
  depends 'apache2'
  depends 'nginx_config'
  provides 'webapps/magento'

  def get_docroots
    docroots = {}
    unless nginx_config.nil?
      unless nginx_config['vhosts'].empty?
        nginx_config['vhosts'].each do |_, vhost|
          docroots[vhost['domain']] = vhost['docroot']
        end
      end
    end
    unless apache2.nil?
      unless apache2['vhosts'].empty?
        apache2['vhosts'].each do |_, vhost|
          vhost.each do |_site_name, site|
            docroots[site['vhost']] = site['docroot']
          end
        end
      end
    end
    return docroots unless docroots.empty?
  end

  def find_magento(docroots)
    require 'find'

    found = {}
    docroots.each do |site_name, site_path|
      excludes = ['.git', '.svn', 'images', 'includes', 'lib', 'downloader',
                  'errors', 'js', 'pkginfo', 'shell', 'skin']
      max_depth = site_path.scan(/\//).count + 2
      # rubocop:disable Next
      if File.directory?(site_path)   # Added to handle none existent docroots
        Find.find(site_path) do |path|
          Find.prune if excludes.include?(File.basename(path))
          Find.prune if path.scan(/\//).count > max_depth
          if path.include?('Mage.php')
            found[site_name] = {
              path: path,
              version: get_version(path) || 'Unknown'
            }
            # break
          end
        end
      end
      # rubocop:enable Next
    end
    return found unless found.empty?
  end

  def get_version(path)
    version = nil
    version_file = File.join(path)
    raw_lines = Hash.new
    file = File.open(version_file)
    begin
      # rubocop:disable Next
      file.each_line do |line|
        if line.include?('=>')
          %w(major minor revision patch stability number).each do |s|
            tmp_line = line.split('=>')
            tmp_line[1] = tmp_line[1].gsub(/\D/, '')
            if tmp_line[0].include?(s)
              unless tmp_line[1].empty?
                raw_lines[tmp_line[0].gsub(/[^A-Za-z]/, '')] = tmp_line[1]
              end
            end
            break unless raw_lines.count < 6
          end
        end
      end
      # rubocop:enable Next
      version = raw_lines.values.join('.')
    ensure
      file.close
    end
    return version if version
  end

  collect_data do
    docroots = get_docroots
    found = find_magento(docroots) unless docroots.nil?
    webapps['magento'] = found unless found.nil?
  end
end
