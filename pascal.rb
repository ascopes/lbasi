#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative('pascalrb/app')

DEBUG_MODE = ARGF.argv.delete('--debug') || false

run_program(ARGF, DEBUG_MODE)
