require File.expand_path(File.dirname(__FILE__) + "/../lib/ticgit-ng")
require 'fileutils'
require 'logger'
require 'tempfile'

TICGITNG_HISTORY = StringIO.new

module TicGitNGSpecHelper

=begin
tempdir -
  test => "content"
  subdir -
    testfile => "content2"
=end
  def setup_new_git_repo prefix='ticgit-ng-gitdir-'
    tempdir = Dir.mktmpdir prefix
    Dir.chdir(tempdir) do
      git = Git.init
      new_file('test', 'content')
      Dir.mkdir('subdir')
      new_file('subdir/testfile', 'content2')
      git.add
      git.commit('first commit')
    end
    tempdir
  end

  def test_opts
    tempdir = Dir.mktmpdir 'ticgit-ng-ticdir-'
    logger = Logger.new(Tempfile.new('ticgit-ng-log-'))
    { :tic_dir => tempdir, :logger => logger, :init => true }
  end


  def new_file(name, contents)
    File.open(name, 'w') do |f|
      f.puts contents
    end
  end

  def format_expected(string)
    string.enum_for(:each_line).map{|line| line.strip }
  end

  def cli(path, *args, &block)
    TICGITNG_HISTORY.truncate 0
    TICGITNG_HISTORY.rewind

    ticgitng = TicGitNG::CLI.new(args.flatten, path, TICGITNG_HISTORY)
    ticgitng.parse_options!
    ticgitng.execute!

    replay_history(&block)
  rescue SystemExit => error
    replay_history(&block)
  end

  def replay_history
    TICGITNG_HISTORY.rewind
    return unless block_given?

    while line = TICGITNG_HISTORY.gets
      yield(line.strip)
    end
  end
    
  def read_line_of filename 
    File.open(filename, "r").each_line do |line|
      return line
    end
  end

  def time_skew
    Time.now.to_i + rand(1000)
  end

  def small_repo tg, n=6
    n.times do |t_i|
      tic=tg.ticket_new( 'ticket_title -- ' + rand_str(8) )
      rand( 6 ).times do |c_i|
        tg.ticket_comment( 'comment -- ' + rand_str(6), tic.ticket_id )
      end
    end
  end

  def big_repo tg
    small_repo tg, 100
  end

  def rand_str i
    (0...i.to_i).map{ ('a'..'z').to_a[rand(26)] }.join
  end
end



##
# rSpec Hash additions.
#
# From
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly

class Hash

  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }

  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }

  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end


end
