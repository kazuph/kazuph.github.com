#!/usr/bin/env ruby
# coding : utf-8
require 'erb'
require 'pry'

html = File.read('README.md')

html.gsub!(/^(#|##|###) ([^\n]+?)\n<!-- image (.+?) -->$/m) { "</template>\n<template layout=\"cover\" invert type=\"text/x-markdown\" backface=\"#{$3}\" backface-filter=\"blur(0px) brightness(.3)\">\n#{$1} #{$2}\n"}

html.gsub!(/\n\n(#|##|###) ([^\n]+?)$/m) { "</template>\n<template layout=\"bullets\" type=\"text/x-markdown\">\n#{$1} #{$2}\n"}
html.sub!(/<\/template>/, "")
html += "</template>"

html = ERB.new(File.read('template.html.erb')).result binding
open("index.html", "w") {|f| f.write html}

