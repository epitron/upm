#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "upm"

  s.version = File.read "VERSION"
  s.date = File.mtime("VERSION").strftime("%Y-%m-%d")

  s.summary = "Universal Package Manager"
  s.description = "Wrap all known command-line package tools with a consistent and pretty interface."

  s.homepage = "http://github.com/epitron/upm/"
  s.licenses = ["WTFPL"]

  s.email   = "chris@ill-logic.com"
  s.authors = ["epitron"]

  # s.executables = ["upm", "up", "u"]

  s.files = `git ls`.lines.map(&:strip)
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  # s.require_paths = %w[lib]

  # s.add_dependency "slop", "~> 3.0"
end
