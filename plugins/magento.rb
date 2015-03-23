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
    # rubocop:disable Next
    docroots.each do |site_name, site_path|
      excludes = ['.git', '.svn', 'images', 'includes', 'lib', 'downloader',
                  'errors', 'js', 'pkginfo', 'shell', 'skin']
      max_depth = site_path.scan(/\//).count + 2
      if File.directory?(site_path)   # Added to handle none existent docroots
        Find.find(site_path) do |path|
          Find.prune if excludes.include?(File.basename(path))
          Find.prune if path.scan(/\//).count > max_depth
          if path.include?('Mage.php')
            release_details = get_version_and_edition(path)
            found[site_name] = {
              path: path,
              version: release_details[:version],
              edition: release_details[:edition]
            }
            break
          end
        end
      end
      # rubocop:enable Next
    end
    return found unless found.empty?
  end

  def get_version_and_edition(path)
    version_file = File.join(path)
    edition_list = Hash.new
    edition_assign = String.new
    raw_lines = Hash.new
    version = String.new
    edition = String.new

    file = File.open(version_file)
    begin
      # rubocop:disable Next
      file.each_line do |line|
        if line.include?('=>')        # version assignment
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
        elsif line.include?('const EDITION_')  # build edition list from file
          tmp_line = line.split('=')
          identifier = tmp_line[0].split(' ')[1].strip
          version = tmp_line[1].gsub(/[^\w]/, '')
          edition_list[identifier] = version
        elsif line.include?('static private $_currentEdition =') # find edition
          edition_assign = line.split('=')[1].split('::')[1].gsub(/[^\w]/, '')
        end
      end
      # rubocop:enable Next
      version = raw_lines.values.join('.')
      edition = edition_list[edition_assign]
    ensure
      file.close
    end
    return { version: version || 'Unknown',
             edition: edition || 'Unknown' }
  end

  collect_data do
    docroots = get_docroots
    found = find_magento(docroots) unless docroots.nil?
    webapps['magento'] = found unless found.nil?
  end
end
