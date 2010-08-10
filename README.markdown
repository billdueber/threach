# threach

`threach` adds to the Enumerable module to provide a threaded
version of whatever enumerator you throw at it (`each` by default).

## Warning: Deadlocks under JRuby if an exception is thrown

`threach` works fine, so long as nothing goes wrong. In particular, there's no safe way (that I can find; see below) to break out of a `threach` loop without a deadlock under JRuby. This is, shall we say, an Issue. 

Under vanilla ruby, `threach` will exit as expected, but who the hell wants to 
use `threach` where there are no real threads???

## Installation

`threach` is on rubygems.org, so you should just be able to do

    gem install threach
    # or jruby -S gem install threach

## Use

    # You like #each? You'll love...err.."probably like" #threach
    require 'rubygems'
    require 'threach'
    
    # Process with 2 threads. It assumes you want 'each'
    # as your iterator.
    (1..10).threach(2) {|i| puts i.to_s}  

    # You can also specify the iterator
    File.open('mybigfile') do |f|
      f.threach(2, :each_line) do |line|
        processLine(line)
      end
    end

    # threach does not care what the arity of your block is
    # as long as it matches the iterator you ask for

    ('A'..'Z').threach(3, :each_with_index) do |letter, index|
      puts "#{index}: #{letter}"
    end

    # Or with a hash
    h = {'a' => 1, 'b'=>2, 'c'=>3}
    h.threach(2) do |letter, i|
      puts "#{i}: #{letter}"
    end

## Major problem

I can't figure out how to exit gracefully from a threach loop. 

  begin
    ('a'..'z').threach(2, :each_with_index) do |letter, i|
      break if i > 10  # will deadlock under jruby; fine under ruby
      # raise StandardError if i > 10 # deadlock under jruby; find under ruby
      puts letter
    end
  rescue 
    puts "Rescued; broke out of the loop"
  end

The `break` under jruby prints "Exception in thread "Thread-1" org.jruby.exceptions.JumpException$BreakJump," but if there's a way to catch that in the enclosing code I sure don't know how. 

Use of `catch` and `throw` seemed like an obvious choice, but they don't work across threads. Then I thought I'd use `catch` within the consumers and throw or raise an error at the producer, but that doesn't work, either. 

I'm clearly up against (or well beyond) my knowledge limitations, here.

If anyone has a solution to what should be a simple problem (and works under both ruby and jruby) boy, would I be grateful.

## Why and when to use it?

Well, if you're using stock (MRI) ruby -- you probably shouldn't bother with `threach`. It'll just slow things down. But if you're using a ruby implementation that has real threads, like JRuby, this will give you relatively painless multi-threading.

You can always do something like:

    if defined? JRUBY_VERSION
      numthreads = 3
    else
      numthreads = 0
    end

    my_enumerable.threach(numthreads) {|i| ...}

Note the "relatively" in front of "painless" up there. The block you pass still has to be thread-safe, and there are many data structures you'll encounter that are *not* thread-safe. Scalars, arrays, and hashes are, though, under JRuby, and that'll get you pretty far.



## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Bill Dueber. See LICENSE for details.
