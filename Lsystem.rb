# coding: utf-8
# Copyright 2019 Eugene Berta
# Licensed under the MIT license
#
# A SketchUp Extension to implement L-Systems
# Free book "The Algorithmic Beauty of Plants"
# http://algorithmicbotany.org/papers/abop/abop.pdf
# explains the ideas.

require 'sketchup.rb'
require 'extensions.rb'

module CommunityExtensions
  module Lsystem

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('L-System', 'Lsystem/main')
      ex.description = 'L-System generator. ' <<
                       'See https://github.com/ezberta/Lsystem-sketchup ' <<
                       ' for usage instructions.'
      ex.version     = '0.5.2'
      ex.copyright   = '2019 Eugene Berta, ' <<
                       'released under the MIT License'
      ex.creator     = 'Eugene Berta'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # module Lsystem
end # module CommunityExtensions

