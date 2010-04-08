# threach

`threach` adds to the Enumerable module to provide a threaded
version of whatever enumerator you throw at it (`each` by default).

## Use

    require 'rubygems'
    require 'threach'
    
    # You like #each? You'll love...err..probably like #threach
    load 'threach.rb'

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
