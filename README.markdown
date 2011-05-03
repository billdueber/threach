# threach

`#threach` monkeypatches the Enumerable module with a new method `#threach` that provides a threaded version of `#each` (or whatever enumerator you throw at it). It's a very simple producer-consumer model. 

## Installation

`#threach` is on rubygems.org, so you should just be able to do

    gem install threach
    # or jruby -S gem install threach

## Use

    require 'rubygems'
    require 'threach'
    
    # Process with 2 threads. It assumes you want 'each'
    # as your iterator.
    (1..10).threach(2) {|i| puts i.to_s}  
    
    # If you want to watch it work...
    (1..50).threach(2) do |i|
      puts "Thread #{Thread.current[:tnum]}: #{i}"
    end

    # You can also specify the iterator as the second argument
    File.open('mybigfile') do |f|
      f.threach(3, :each_line) do |line|
        processLine(line)
      end
    end

    # threach does not care what the arity of your block is
    # as long as it matches the iterator specifed

    ('A'..'Z').threach(3, :each_with_index) do |letter, index|
      puts "#{index}: #{letter}"
    end

    # Same thing with a hash, where the default #each actually returns two values
    h = {'a' => 1, 'b'=>2, 'c'=>3}
    h.threach(2) do |letter, i|
      puts "#{i}: #{letter}"
    end

## Things you need to know

* The number you provide to `#threach` is the number of *consumer* threads. It's assumed that the time to iterate once on the producer is much less than the work done by a consumer, so you need multiple consumers to keep up.
* `#threach` doesn't magically make your code thread-safe. That's still up to you.
* Using `break` under JRuby works as expected but writes a log line to STDERR. This is something internal to JRuby and I don't know how to stop it.
* Throwing exceptions as `raise "oops'` under JRuby is so slow that if you have more than one consumer, the time between the `raise` and the time you exit the `#threach` loop is long enough that a *lot* of work will still get done. You need to use use the three-argument form `raise WhateverError, value, nil`. [The last `nil` tells JRuby to not bother making a full stack trace](http://jira.codehaus.org/browse/JRUBY-5534) and reduces the penalty, but you shouldn't be using `raise` for flow control, anyway; use `break` or `catch`


## Why and when to use it?

Well, if you're using stock (MRI) ruby -- you probably shouldn't bother with `#threach` unless you're doing IO-intensive stuff. It'll just slow things down. But if you're using a ruby implementation that has real threads, like JRuby, this will give you relatively painless multi-threading.

You can always do something like:

    if defined? JRUBY_VERSION
      numthreads = 3
    else
      numthreads = 0
    end

    my_enumerable.threach(numthreads) {|i| ...}

...since `#threach(0)` is exactly the same as `each`

Note the "relatively" in front of "painless" up there. The block you pass still has to be thread-safe, and there are many data structures you'll encounter that are *not* thread-safe. Scalars, arrays, and hashes are, though, under JRuby, and that'll get you pretty far.

## Change Notes

* 0.3 Successfully deal with `break`  and other nonlocal exits without deadlocks by using another SizedQueue as, basically, a thread-safe counter of how many threads have finished.
* 0.2 Undo attempts to deal with non-local exit
* 0.1 first release


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010-2011 Bill Dueber. See LICENSE for details.
