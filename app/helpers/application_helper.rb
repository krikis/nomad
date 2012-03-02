module ApplicationHelper

  def template_link_tags
    templates_dir = (defined?(Rails.root) ? "#{Rails.root}/app/views/templates" : "app/views/templates")
    extract = /^#{Regexp.quote(templates_dir)}\/?(.*)_([^_]*).html.haml$/
    files = Dir["#{templates_dir}/**/*.html.haml"].map { |file| match = file.match(extract); "#{match[1]}#{match[2]}" if match }
    files.compact.map do |file|
      content_tag :script, render(:partial => File.join("templates", file)), :type => "text/template", :id => file.gsub("\/", "-")
    end.join.html_safe
  end

end
