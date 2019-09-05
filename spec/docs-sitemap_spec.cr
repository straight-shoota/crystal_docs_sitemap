require "./spec_helper"

describe CrystalDocsSitemap do
  it "reads links from navigation" do
    File.open(Path[__DIR__, "fixtures", "index.html"]) do |file|
      links = CrystalDocsSitemap.new.read_links(file)
      links.should contain("Struct.html")
      links.should contain("Zip.html")
      links.size.should eq 597
    end
  end

  it "creates sitemap" do
    links = ["String.html", "Int.html", "Array.html"]
    sitemap = String.build do |io|
      CrystalDocsSitemap.new.generate_sitemap(io, links, priority: 0.1)
    end
    sitemap.should eq <<-XML
    <?xml version="1.0"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://crytal-lang.org/api/String.html</loc><changefreq>never</changefreq><priority>0.1</priority></url><url><loc>https://crytal-lang.org/api/Int.html</loc><changefreq>never</changefreq><priority>0.1</priority></url><url><loc>https://crytal-lang.org/api/Array.html</loc><changefreq>never</changefreq><priority>0.1</priority></url></urlset>

    XML
  end

  it "creates sitemap index" do
    versions = ["0.20.0", "0.30.1"]
    sitemap = String.build do |io|
      CrystalDocsSitemap.new.generate_sitemap_index(io, versions)
    end
    sitemap.should contain <<-XML
      <?xml version="1.0"?>
      <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><sitemap><loc>https://crytal-lang.org/api/sitemaps/sitemap-0.20.0.xml.gz</loc><lastmod>
      XML
  end
end
