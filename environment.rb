#!/usr/bin/env ruby

PARSER_ECODE = 1
PROVIDER_ECODE = 2
HTTP_ECODE = 3
SCRAPER_ECODE = 4
PRINTER_ECODE = 5
HTTP_TIMEOUT_SECONDS = 10
MAINTAINER = 'Oever González <notengobattery@gmail.com>'.freeze

require 'bundler'
Bundler.require(:default)
