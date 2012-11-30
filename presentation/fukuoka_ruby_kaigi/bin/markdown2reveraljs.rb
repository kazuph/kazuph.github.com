#!/usr/bin/env ruby
# coding : utf-8
require 'redcarpet'
require 'erb'
# define markdown
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(), :autolink => true,  :space_after_headers => true, :fenced_code_blocks => true, :no_intra_emphasis => true, :tables => true)
# render html
html = markdown.render(File.read('README.md'))

# set title
title = $1 if html =~ /<h1>(.+?)<\/h1>/

# for reveal.js
html.gsub!(/<h(\d)>/) { "</section><section>\n<h" + $1 + ">"}
html.sub!(/<\/section>/, "")
html = html + "</section>"

html.gsub!(/-&gt;(.+?)(<\/p>)?$/, "<div class=\"fragment\">\\1</div>\\2")

puts html

# embed html
html = ERB.new(File.read('template.html.erb')).result binding
# puts html
# write file
open("index.html", "w") {|f| f.write html}
