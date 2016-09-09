#!/usr/bin/env ruby
# -*- ruby -*-

begin
  require 'win32console'
rescue LoadError
end

# --------------------------------------------------------------------
# Support code for the Ruby Koans.
# --------------------------------------------------------------------

class FillMeInError < StandardError
end

def ruby_version?(version)
  RUBY_VERSION =~ /^#{version}/ ||
    (version == 'jruby' && defined?(JRUBY_VERSION)) ||
    (version == 'mri' && ! defined?(JRUBY_VERSION))
end

def in_ruby_version(*versions)
  yield if versions.any? { |v| ruby_version?(v) }
end

in_ruby_version("1.8") do
  class KeyError < StandardError
  end
end

# Standard, generic replacement value.
# If value19 is given, it is used in place of value for Ruby 1.9.
def __(value="FILL ME IN", value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

# Numeric replacement value.
def _n_(value=999999, value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

# Error object replacement value.
def ___(value=FillMeInError, value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

# Method name replacement.
class Object
  def ____(method=nil)
    if method
      self.send(method)
    end
  end

  in_ruby_version("1.9", "2") do
    public :method_missing
  end
end

class String
  def side_padding(width)
    extra = width - self.size
    if width < 0
      self
    else
      left_padding = extra / 2
      right_padding = (extra+1)/2
      (" " * left_padding) + self + (" " *right_padding)
    end
  end
end

module Neo
  class << self
    def simple_output
      ENV['SIMPLE_KOAN_OUTPUT'] == 'true'
    end
  end

  module Color
    #shamelessly stolen (and modified) from redgreen
    COLORS = {
      :clear   => 0,  :black   => 30, :red   => 31,
      :green   => 32, :yellow  => 33, :blue  => 34,
      :magenta => 35, :cyan    => 36,
    }

    module_function

    COLORS.each do |color, value|
      module_eval "def #{color}(string); colorize(string, #{value}); end"
      module_function color
    end

    def colorize(string, color_value)
      if use_colors?
        color(color_value) + string + color(COLORS[:clear])
      else
        string
      end
    end

    def color(color_value)
      "\e[#{color_value}m"
    end

    def use_colors?
      return false if ENV['NO_COLOR']
      if ENV['ANSI_COLOR'].nil?
        if using_windows?
          using_win32console
        else
          return true
        end
      else
        ENV['ANSI_COLOR'] =~ /^(t|y)/i
      end
    end

    def using_windows?
      File::ALT_SEPARATOR
    end

    def using_win32console
      defined? Win32::Console
    end
  end

  module Assertions
    UNDEFINED = Object.new # :nodoc:

    def UNDEFINED.inspect # :nodoc:
      "UNDEFINED"
    end

    FailedAssertionError = Class.new(StandardError)

    def bench_exp min, max, base = 10
      min = (Math.log10(min) / Math.log10(base)).to_i
      max = (Math.log10(max) / Math.log10(base)).to_i

      (min..max).map { |m| base ** m }.to_a
    end

    def bench_linear min, max, step = 10
      (min..max).step(step).to_a
    rescue LocalJumpError # 1.8.6
      r = []; (min..max).step(step) { |n| r << n }; r
    end

    def bench_range
      bench_exp 1, 10_000
    end
    
    def flunk(msg)
      raise FailedAssertionError, msg
    end

    def assert(condition, msg=nil)
      msg ||= "Failed assertion."
      flunk(msg) unless condition
      true
    end

    def assert_equal(expected, actual, msg=nil)
      msg ||= "Expected #{expected.inspect} to equal #{actual.inspect}"
      assert(expected == actual, msg)
    end

    def assert_not_equal(expected, actual, msg=nil)
      msg ||= "Expected #{expected.inspect} to not equal #{actual.inspect}"
      assert(expected != actual, msg)
    end

    def assert_nil(actual, msg=nil)
      msg ||= "Expected #{actual.inspect} to be nil"
      assert(nil == actual, msg)
    end

    def assert_not_nil(actual, msg=nil)
      msg ||= "Expected #{actual.inspect} to not be nil"
      assert(nil != actual, msg)
    end

    def assert_match(pattern, actual, msg=nil)
      msg ||= "Expected #{actual.inspect} to match #{pattern.inspect}"
      assert pattern =~ actual, msg
    end

    def assert_raise(exception)
      begin
        yield
      rescue Exception => ex
        expected = ex.is_a?(exception)
        assert(expected, "Exception #{exception.inspect} expected, but #{ex.inspect} was raised")
        return ex
      end
      flunk "Exception #{exception.inspect} expected, but nothing raised"
    end

    def assert_nothing_raised
      begin
        yield
      rescue Exception => ex
        flunk "Expected nothing to be raised, but exception #{exception.inspect} was raised"
      end
    end

    ## 
    # Support for performance assertions. Stolen from Minitest::Benchmark
 
    def assert_in_delta exp, act, delta = 0.001, msg = nil
      n = (exp - act).abs
      msg ||= "Expected |#{exp} - #{act}| (#{n}) to be <= #{delta}"
      assert delta >= n, msg
    end

    def assert_predicate o1, op, msg = nil
      msg ||= "Expected #{o1} to be #{op}"
      assert o1.__send__(op), msg
    end

    def assert_operator o1, op, o2 = UNDEFINED, msg = nil
      return assert_predicate o1, op, msg if UNDEFINED == o2
      msg ||= "Expected #{o1} to be #{op} #{o2}"
      assert o1.__send__(op, o2), msg
    end

    def assert_performance validation, &work
      range = bench_range

      print "#{self.name}"

      times = []

      range.each do |x|
        GC.start
        t0 = Time.now
        instance_exec(x, &work)
        t = Time.now - t0

        print "\t%9.6f" % t
        times << t
      end
      puts

      validation[range, times]
    end
    ##
    # Runs the given +work+ and asserts that the times gathered fit to
    # match a constant rate (eg, linear slope == 0) within a given
    # +threshold+. Note: because we're testing for a slope of 0, R^2
    # is not a good determining factor for the fit, so the threshold
    # is applied against the slope itself. As such, you probably want
    # to tighten it from the default.
    #
    # See http://www.graphpad.com/curvefit/goodness_of_fit.htm for
    # more details.
    #
    # Fit is calculated by #fit_linear.
    #
    # Ranges are specified by ::bench_range.
    #
    # Eg:
    #
    #   def bench_algorithm
    #     assert_performance_constant 0.9999 do |n|
    #       @obj.algorithm(n)
    #     end
    #   end

    def assert_performance_constant threshold = 0.99, &work
      validation = proc do |range, times|
        a, b, rr = fit_linear range, times
        assert_in_delta 0, b, 1 - threshold
        [a, b, rr]
      end

      assert_performance validation, &work
    end

    ##
    # Runs the given +work+ and asserts that the times gathered fit to
    # match a exponential curve within a given error +threshold+.
    #
    # Fit is calculated by #fit_exponential.
    #
    # Ranges are specified by ::bench_range.
    #
    # Eg:
    #
    #   def bench_algorithm
    #     assert_performance_exponential 0.9999 do |n|
    #       @obj.algorithm(n)
    #     end
    #   end

    def assert_performance_exponential threshold = 0.99, &work
      assert_performance validation_for_fit(:exponential, threshold), &work
    end

    ##
    # Runs the given +work+ and asserts that the times gathered fit to
    # match a logarithmic curve within a given error +threshold+.
    #
    # Fit is calculated by #fit_logarithmic.
    #
    # Ranges are specified by ::bench_range.
    #
    # Eg:
    #
    #   def bench_algorithm
    #     assert_performance_logarithmic 0.9999 do |n|
    #       @obj.algorithm(n)
    #     end
    #   end

    def assert_performance_logarithmic threshold = 0.99, &work
      assert_performance validation_for_fit(:logarithmic, threshold), &work
    end

    ##
    # Runs the given +work+ and asserts that the times gathered fit to
    # match a straight line within a given error +threshold+.
    #
    # Fit is calculated by #fit_linear.
    #
    # Ranges are specified by ::bench_range.
    #
    # Eg:
    #
    #   def bench_algorithm
    #     assert_performance_linear 0.9999 do |n|
    #       @obj.algorithm(n)
    #     end
    #   end

    def assert_performance_linear threshold = 0.99, &work
      assert_performance validation_for_fit(:linear, threshold), &work
    end

    ##
    # Runs the given +work+ and asserts that the times gathered curve
    # fit to match a power curve within a given error +threshold+.
    #
    # Fit is calculated by #fit_power.
    #
    # Ranges are specified by ::bench_range.
    #
    # Eg:
    #
    #   def bench_algorithm
    #     assert_performance_power 0.9999 do |x|
    #       @obj.algorithm
    #     end
    #   end

    def assert_performance_power threshold = 0.99, &work
      assert_performance validation_for_fit(:power, threshold), &work
    end

    ##
    # Takes an array of x/y pairs and calculates the general R^2 value.
    #
    # See: http://en.wikipedia.org/wiki/Coefficient_of_determination

    def fit_error xys
      y_bar  = sigma(xys) { |x, y| y } / xys.size.to_f
      ss_tot = sigma(xys) { |x, y| (y    - y_bar) ** 2 }
      ss_err = sigma(xys) { |x, y| (yield(x) - y) ** 2 }

      1 - (ss_err / ss_tot)
    end

    ##
    # To fit a functional form: y = ae^(bx).
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingExponential.html

    def fit_exponential xs, ys
      n     = xs.size
      xys   = xs.zip(ys)
      sxlny = sigma(xys) { |x,y| x * Math.log(y) }
      slny  = sigma(xys) { |x,y| Math.log(y)     }
      sx2   = sigma(xys) { |x,y| x * x           }
      sx    = sigma xs

      c = n * sx2 - sx ** 2
      a = (slny * sx2 - sx * sxlny) / c
      b = ( n * sxlny - sx * slny ) / c

      return Math.exp(a), b, fit_error(xys) { |x| Math.exp(a + b * x) }
    end

    ##
    # To fit a functional form: y = a + b*ln(x).
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingLogarithmic.html

    def fit_logarithmic xs, ys
      n     = xs.size
      xys   = xs.zip(ys)
      slnx2 = sigma(xys) { |x,y| Math.log(x) ** 2 }
      slnx  = sigma(xys) { |x,y| Math.log(x)      }
      sylnx = sigma(xys) { |x,y| y * Math.log(x)  }
      sy    = sigma(xys) { |x,y| y                }

      c = n * slnx2 - slnx ** 2
      b = ( n * sylnx - sy * slnx ) / c
      a = (sy - b * slnx) / n

      return a, b, fit_error(xys) { |x| a + b * Math.log(x) }
    end


    ##
    # Fits the functional form: a + bx.
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFitting.html

    def fit_linear xs, ys
      n   = xs.size
      xys = xs.zip(ys)
      sx  = sigma xs
      sy  = sigma ys
      sx2 = sigma(xs)  { |x|   x ** 2 }
      sxy = sigma(xys) { |x,y| x * y  }

      c = n * sx2 - sx**2
      a = (sy * sx2 - sx * sxy) / c
      b = ( n * sxy - sx * sy ) / c

      return a, b, fit_error(xys) { |x| a + b * x }
    end

    ##
    # To fit a functional form: y = ax^b.
    #
    # Takes x and y values and returns [a, b, r^2].
    #
    # See: http://mathworld.wolfram.com/LeastSquaresFittingPowerLaw.html

    def fit_power xs, ys
      n       = xs.size
      xys     = xs.zip(ys)
      slnxlny = sigma(xys) { |x, y| Math.log(x) * Math.log(y) }
      slnx    = sigma(xs)  { |x   | Math.log(x)               }
      slny    = sigma(ys)  { |   y| Math.log(y)               }
      slnx2   = sigma(xs)  { |x   | Math.log(x) ** 2          }

      b = (n * slnxlny - slnx * slny) / (n * slnx2 - slnx ** 2);
      a = (slny - b * slnx) / n

      return Math.exp(a), b, fit_error(xys) { |x| (Math.exp(a) * (x ** b)) }
    end

    ##
    # Enumerates over +enum+ mapping +block+ if given, returning the
    # sum of the result. Eg:
    #
    #   sigma([1, 2, 3])                # => 1 + 2 + 3 => 7
    #   sigma([1, 2, 3]) { |n| n ** 2 } # => 1 + 4 + 9 => 14

    def sigma enum, &block
      enum = enum.map(&block) if block
      enum.inject { |sum, n| sum + n }
    end

    ##
    # Returns a proc that calls the specified fit method and asserts
    # that the error is within a tolerable threshold.

    def validation_for_fit msg, threshold
      proc do |range, times|
        a, b, rr = send "fit_#{msg}", range, times
        assert_operator rr, :>=, threshold
        [a, b, rr]
      end
    end
  end

  class Sensei
    attr_reader :failure, :failed_test, :pass_count

    FailedAssertionError = Assertions::FailedAssertionError

    def initialize
      @pass_count = 0
      @failure = nil
      @failed_test = nil
      @observations = []
    end

    PROGRESS_FILE_NAME = '.path_progress'

    def add_progress(prog)
      @_contents = nil
      exists = File.exists?(PROGRESS_FILE_NAME)
      File.open(PROGRESS_FILE_NAME,'a+') do |f|
        f.print "#{',' if exists}#{prog}"
      end
    end

    def progress
      if @_contents.nil?
        if File.exists?(PROGRESS_FILE_NAME)
          File.open(PROGRESS_FILE_NAME,'r') do |f|
            @_contents = f.read.to_s.gsub(/\s/,'').split(',')
          end
        else
          @_contents = []
        end
      end
      @_contents
    end

    def observe(step)
      if step.passed?
        @pass_count += 1
        if @pass_count > progress.last.to_i
          @observations << Color.green("#{step.koan_file}##{step.name} has expanded your awareness.")
        end
      else
        @failed_test = step
        @failure = step.failure
        add_progress(@pass_count)
        @observations << Color.red("#{step.koan_file}##{step.name} has damaged your karma.")
        throw :neo_exit
      end
    end

    def failed?
      ! @failure.nil?
    end

    def assert_failed?
      failure.is_a?(FailedAssertionError)
    end

    def instruct
      if failed?
        @observations.each{|c| puts c }
        encourage
        guide_through_error
        a_zenlike_statement
        show_progress
      else
        end_screen
      end
    end

    def show_progress
      bar_width = 50
      total_tests = Neo::Koan.total_tests
      scale = bar_width.to_f/total_tests
      print Color.green("your path thus far [")
      happy_steps = (pass_count*scale).to_i
      happy_steps = 1 if happy_steps == 0 && pass_count > 0
      print Color.green('.'*happy_steps)
      if failed?
        print Color.red('X')
        print Color.cyan('_'*(bar_width-1-happy_steps))
      end
      print Color.green(']')
      print " #{pass_count}/#{total_tests}"
      puts
    end

    def end_screen
      if Neo.simple_output
        boring_end_screen
      else
        artistic_end_screen
      end
    end

    def boring_end_screen
      puts "Mountains are again merely mountains"
    end

    def artistic_end_screen
      "JRuby 1.9.x Koans"
      ruby_version = "(in #{'J' if defined?(JRUBY_VERSION)}Ruby #{defined?(JRUBY_VERSION) ? JRUBY_VERSION : RUBY_VERSION})"
      ruby_version = ruby_version.side_padding(54)
        completed = <<-ENDTEXT
                                  ,,   ,  ,,
                                :      ::::,    :::,
                   ,        ,,: :::::::::::::,,  ::::   :  ,
                 ,       ,,,   ,:::::::::::::::::::,  ,:  ,: ,,
            :,        ::,  , , :, ,::::::::::::::::::, :::  ,::::
           :   :    ::,                          ,:::::::: ::, ,::::
          ,     ,:::::                                  :,:::::::,::::,
      ,:     , ,:,,:                                       :::::::::::::
     ::,:   ,,:::,                                           ,::::::::::::,
    ,:::, :,,:::                                               ::::::::::::,
   ,::: :::::::,       Mountains are again merely mountains     ,::::::::::::
   :::,,,::::::                                                   ::::::::::::
 ,:::::::::::,                                                    ::::::::::::,
 :::::::::::,                                                     ,::::::::::::
:::::::::::::                                                     ,::::::::::::
::::::::::::                      Ruby Koans                       ::::::::::::
::::::::::::#{                  ruby_version                     },::::::::::::
:::::::::::,                                                      , :::::::::::
,:::::::::::::,                brought to you by                 ,,::::::::::::
::::::::::::::                                                    ,::::::::::::
 ::::::::::::::,                                                 ,:::::::::::::
 ::::::::::::,               Neo Software Artisans              , ::::::::::::
  :,::::::::: ::::                                               :::::::::::::
   ,:::::::::::  ,:                                          ,,:::::::::::::,
     ::::::::::::                                           ,::::::::::::::,
      :::::::::::::::::,                                  ::::::::::::::::
       :::::::::::::::::::,                             ::::::::::::::::
        ::::::::::::::::::::::,                     ,::::,:, , ::::,:::
          :::::::::::::::::::::::,               ::,: ::,::, ,,: ::::
              ,::::::::::::::::::::              ::,,  , ,,  ,::::
                 ,::::::::::::::::              ::,, ,   ,:::,
                      ,::::                         , ,,
                                                  ,,,
ENDTEXT
        puts completed
    end

    def encourage
      puts
      puts "The Master says:"
      puts Color.cyan("  You have not yet reached enlightenment.")
      if ((recents = progress.last(5)) && recents.size == 5 && recents.uniq.size == 1)
        puts Color.cyan("  I sense frustration. Do not be afraid to ask for help.")
      elsif progress.last(2).size == 2 && progress.last(2).uniq.size == 1
        puts Color.cyan("  Do not lose hope.")
      elsif progress.last.to_i > 0
        puts Color.cyan("  You are progressing. Excellent. #{progress.last} completed.")
      end
    end

    def guide_through_error
      puts
      puts "The answers you seek..."
      puts Color.red(indent(failure.message).join)
      puts
      puts "Please meditate on the following code:"
      puts embolden_first_line_only(indent(find_interesting_lines(failure.backtrace)))
      puts
    end

    def embolden_first_line_only(text)
      first_line = true
      text.collect { |t|
        if first_line
          first_line = false
          Color.red(t)
        else
          Color.cyan(t)
        end
      }
    end

    def indent(text)
      text = text.split(/\n/) if text.is_a?(String)
      text.collect{|t| "  #{t}"}
    end

    def find_interesting_lines(backtrace)
      backtrace.reject { |line|
        line =~ /neo\.rb/
      }
    end

    # Hat's tip to Ara T. Howard for the zen statements from his
    # metakoans Ruby Quiz (http://rubyquiz.com/quiz67.html)
    def a_zenlike_statement
      if !failed?
        zen_statement =  "Mountains are again merely mountains"
      else
        zen_statement = case (@pass_count % 10)
        when 0
          "mountains are merely mountains"
        when 1, 2
          "learn the rules so you know how to break them properly"
        when 3, 4
          "remember that silence is sometimes the best answer"
        when 5, 6
          "sleep is the best meditation"
        when 7, 8
          "when you lose, don't lose the lesson"
        else
          "things are not what they appear to be: nor are they otherwise"
        end
      end
      puts Color.green(zen_statement)
    end
  end

  class Koan
    include Assertions

    attr_reader :name, :failure, :koan_count, :step_count, :koan_file

    def initialize(name, koan_file=nil, koan_count=0, step_count=0)
      @name = name
      @failure = nil
      @koan_count = koan_count
      @step_count = step_count
      @koan_file = koan_file
    end

    def passed?
      @failure.nil?
    end

    def failed(failure)
      @failure = failure
    end

    def setup
    end

    def teardown
    end

    def meditate
      setup
      begin
        send(name)
      rescue StandardError, Neo::Sensei::FailedAssertionError => ex
        failed(ex)
      ensure
        begin
          teardown
        rescue StandardError, Neo::Sensei::FailedAssertionError => ex
          failed(ex) if passed?
        end
      end
      self
    end

    # Class methods for the Neo test suite.
    class << self
      def inherited(subclass)
        subclasses << subclass
      end

      def method_added(name)
        testmethods << name if !tests_disabled? && Koan.test_pattern =~ name.to_s
      end

      def end_of_enlightenment
        @tests_disabled = true
      end

      def command_line(args)
        args.each do |arg|
          case arg
          when /^-n\/(.*)\/$/
            @test_pattern = Regexp.new($1)
          when /^-n(.*)$/
            @test_pattern = Regexp.new(Regexp.quote($1))
          else
            if File.exist?(arg)
              load(arg)
            else
              fail "Unknown command line argument '#{arg}'"
            end
          end
        end
      end

      # Lazy initialize list of subclasses
      def subclasses
        @subclasses ||= []
      end

       # Lazy initialize list of test methods.
      def testmethods
        @test_methods ||= []
      end

      def tests_disabled?
        @tests_disabled ||= false
      end

      def test_pattern
        @test_pattern ||= /^test_/
      end

      def total_tests
        self.subclasses.inject(0){|total, k| total + k.testmethods.size }
      end
    end
  end

  class ThePath
    def walk
      sensei = Neo::Sensei.new
      each_step do |step|
        sensei.observe(step.meditate)
      end
      sensei.instruct
    end

    def each_step
      catch(:neo_exit) {
        step_count = 0
        Neo::Koan.subclasses.each_with_index do |koan,koan_index|
          koan.testmethods.each do |method_name|
            step = koan.new(method_name, koan.to_s, koan_index+1, step_count+=1)
            yield step
          end
        end
      }
    end
  end
end

END {
  Neo::Koan.command_line(ARGV)
  Neo::ThePath.new.walk
}
