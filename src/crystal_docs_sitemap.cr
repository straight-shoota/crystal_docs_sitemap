require "xml"
require "file_utils"
require "uri"
require "http/client"

class CrystalDocsSitemap
  VERSION = "0.1.0"

  API_VERSIONS = [
    "0.20.0", "0.20.1", "0.20.2", "0.20.3", "0.20.4", "0.20.5",
    "0.21.0", "0.21.1",
    "0.22.0",
    "0.23.0", "0.23.1",
    "0.24.0", "0.24.1", "0.24.2",
    "0.25.0", "0.25.1",
    "0.26.0", "0.26.1",
    "0.27.0", "0.27.1", "0.27.2",
    "0.28.0",
    "0.29.0",
    "0.30.0", "0.30.1",
    "master"
  ]

  property base_url = "https://crystal-lang.org/api/"
  property output_path = "output"

  def run
    FileUtils.rm_rf(output_path)
    FileUtils.mkdir_p(output_path)

    retrieve_each_sitemap do |version, io|
      puts "Processing #{version}"
      links = read_links(io)
      if version == "master"
        changefreq = "daily"
      else
        changefreq = "never"
      end

      open sitemap_location(version) do |file|
        generate_sitemap(file, links, priority(version), changefreq)
      end
    end

    open "sitemap-index.xml.gz" do |file|
      generate_sitemap_index(file, API_VERSIONS)
    end
  end

  def retrieve_each_sitemap
    uri = URI.parse(base_url)
    client = HTTP::Client.new(uri)
    base_path = uri.path

    API_VERSIONS.each do |version|
      client.get(Path.posix(base_path, version, "index.html").to_s) do |response|
        yield version, response.body_io
      end
    end
  end

  def open(file_path)
    path = Path[output_path, file_path]
    FileUtils.mkdir_p path.parent.to_s
    File.open(path.to_s, "w") do |file|
      Gzip::Writer.open(file) do |gzip|
        yield gzip
      end
    end
  end

  def priority(version)
    count = API_VERSIONS.size - API_VERSIONS.index(version).not_nil! - 1
    if count > 3 # older versions
      priority = "0.1"
    elsif count > 2 # second-to-last version
      priority = "0.3"
    elsif count > 1 # last version
      priority = "0.5"
    elsif count == 1 # current version
      priority = "1.0"
    else # master
      priority = "0.5"
    end
    priority
  end

  def read_links(io)
    xml = XML.parse_html(io)

    xml.xpath_nodes(%(//*[@class="types-list" or @id="types-list"]//a[@href]/@href)).map(&.content)
  end

  def generate_sitemap(io, links, priority, changefreq = "never")
    XML.build(io) do |xml|
      xml.element "urlset", xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
        links.each do |link|
          xml.element "url" do
            xml.element "loc" do
              xml.text absolute_path(link)
            end
            xml.element "changefreq" do
              xml.text changefreq
            end
            xml.element "priority" do
              xml.text priority.to_s
            end
          end
        end
      end
    end
  end

  def generate_sitemap_index(io, versions)
    XML.build(io) do |xml|
      xml.element "sitemapindex", xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
        versions.each do |version|
          xml.element "sitemap" do
            xml.element "loc" do
              xml.text absolute_path(sitemap_location(version))
            end
            xml.element "lastmod" do
              xml.text Time.utc.to_rfc3339
            end
          end
        end
      end
    end
  end

  def absolute_path(path)
    Path.posix(base_url, path).to_s
  end

  def sitemap_location(version)
    Path.posix("sitemaps", "sitemap-#{version}.xml.gz").to_s
  end
end
