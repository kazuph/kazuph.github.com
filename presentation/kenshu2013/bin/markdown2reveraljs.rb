#!/usr/bin/env ruby
# coding : utf-8
require 'redcarpet'
require 'erb'

# define markdown
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(), :autolink => true,  :space_after_headers => true, :fenced_code_blocks => true, :no_intra_emphasis => true)

# render html
html = markdown.render(File.read('README.md'))

# set title
title = $1 if html =~ /<h1>(.+?)<\/h1>/

# for reveal.js
html.gsub!(/<h(\d)>/) { "</section><section>\n<h" + $1 + ">"}
html.sub!(/<\/section>/, "")
html = html + "</section>"

# origin tag
html.gsub!(/-&gt;(.+?)(<\/p>)?$/, "<div class=\"fragment\">\\1</div>\\2")
html.gsub!(/(?:<p>)?(\/)?#section(?:<\/p>)?/, "<\\1section>")
html.gsub!(/<p>(\/)?#small<\/p>/, "<\\1small>")
html.gsub!(/<p>(\/)?#big<\/p>/, "<\\1big>")
html.gsub!(/<section>\n+?<\/section>/m, "</section><section>")

# embed html
html = ERB.new(File.read('template.html.erb')).result binding
open("index.html", "w") {|f| f.write html}
