require 'rubygems'
require 'bundler/setup'

ENV['TIPSY_ROOT'] ||= File.join(File.dirname(__FILE__), "root")
ENV['TIPSY_ENV'] = "test"

Bundler.require
require 'rubygems'
require 'colored'
require 'active_support/all'
require 'fileutils'
require 'ostruct'
require 'minitest/unit'
require 'minitest/autorun'
require 'test/unit'

require 'tipsy'

require 'rspec/core'
require 'rspec/expectations'

Tipsy::Site.configure!

module MiniTest
  class SpecRunner < Unit
  
    def before_suites
      super if defined?(super)
    end

    def after_suites
      super if defined?(super)
    end
  
    def status(io = nil)
      io ||= @@out
      return io.puts ("%d tests, %d failures" % [assertion_count, failures]).green unless (failures.to_i > 0 || errors.to_i > 0)
      format = "%d tests, %d assertions, %d failures, %d skipped/pending"
      io.puts (format % [test_count, assertion_count, (failures + errors), skips]).red
    end
    
    def pad(str, size = 2)
      " " * size + ("%5s" % str)
    end

    def puke klass, meth, e  
      
      meth_title = meth.to_s.gsub("_", " ").capitalize
      make_fail  = lambda{ |k, m, msg, loc|
        ["#{k} #{m}", pad("Failure/Error: #{msg}", 5).red, pad("#{loc}", 5)].join("\n")
      }
      make_bt    = lambda{ | bt | 
        bt.map{ |line| "\e[90m# #{line}\e[0m" }.join("\n")        
      }
      
      msg   = case e
        when MiniTest::Skip
          @skips += 1
          result  = :skip 
          message = pad("(skipped/pending)", 6).yellow
          "Pending: #{klass} #{meth}\n #{pad(location e)}]"
        when MiniTest::Assertion
          @failures += 1
          result  = :fail
          message = pad("#{e.message}", 6).red
        when defined?(RSpec::Expectations) && RSpec::Expectations::ExpectationNotMetError
          @failures += 1
          result  = :fail
          message = pad("#{e.message}", 6).red
        else
          @errors += 1
          result  = :error
          message = pad("#{e.class}: #{e.message}\n", 6)
      end
      
      loc = (result == :fail) ? location(e).split("\n") : MiniTest::filter_backtrace(e.backtrace)
      msg = make_fail.call(klass, meth_title, e.message, make_bt.call(loc)) if result === :fail || result === :error
      
      @report << msg
      result
    end
    
    def _run_anything type
      suites = TestCase.send "#{type}_suites"
      return if suites.empty?

      start = Time.now
      puts "---------------------------------------------------------"
      puts "Running #{type} suite(s)"
      puts "---------------------------------------------------------"
      puts
      puts

      @test_count, @assertion_count = 0, 0
      sync = output.respond_to? :"sync=" # stupid emacs
      old_sync, output.sync = output.sync, true if sync
      
      before_suites
      results = _run_suites suites, type

      @test_count      = results.inject(0) { |sum, (tc, _)| sum + tc }
      @assertion_count = results.inject(0) { |sum, (_, ac)| sum + ac }

      output.sync = old_sync if sync
      after_suites
      
      t = Time.now - start

      puts
      puts "Finished in %.5fs" % t
      puts status

      report.each_with_index do |msg, i|
        puts "\n%3d) %s" % [i + 1, msg]
      end
      puts 
      puts
      
      if defined?(MiniTest::Growl)
        MiniTest::Growl.new(self)
      end

    end

    def _run_suite suite, type
      header = "#{type}_suite_header"
      puts send(header, suite) if respond_to? header

      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//
      
      available_suites = suite.send("#{type}_methods").grep(filter)
      suite_name       = suite.to_s.gsub(/Test$/i, '')
      
      print "#{suite_name}\n" unless available_suites.empty?
      
      assertions = available_suites.map { |method|
        inst = suite.new method
        inst._assertions = 0

        @start_time = Time.now
        result      = inst.run self
        repl_hash   = { "_" => " ", ":" => "" }
        meth_title  = method.to_s.gsub(/\A(#{type.to_s})/, "").strip.gsub(/\A(\W|_)/){ repl_hash[$1] }.strip
        meth_title  = meth_title.gsub(/\A(#{suite_name})/i, '').strip.gsub("_", " ")
        
        # Account for any sort of non-puke callback
        response = if result.is_a?(Symbol)
          (result == :skip) ? "#{meth_title} (skipped/pending)".yellow : "[x] : #{meth_title}".red
        else
          "[\u221A] : #{meth_title}".green
        end
        
        time = Time.now - @start_time

        print pad(response)
        print (" (%.2fs) " % time).clear
        puts

        inst._assertions
      }
      
      puts unless available_suites.empty?
      return assertions.size, assertions.inject(0) { |sum, n| sum + n }
      
    end
    
  
  end
end

MiniTest::Unit.runner = MiniTest::SpecRunner.new