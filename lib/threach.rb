require 'thread'
module Enumerable
  
  class ThreachDone < StandardError; end
  
  def threach(threads=0, iterator=:each, &blk)
    if threads == 0
      self.send(iterator) do |*args|
        blk.call *args
      end
    else
      begin
        bq = SizedQueue.new(threads * 2) # the work queue
        dq = SizedQueue.new(threads)     # threads that are done
        eq = SizedQueue.new(threads)     # errors
      
        consumers = []
        threads.times do |i|
          consumers << Thread.new(i) do |i|
            Thread.current[:tnum] = i
            begin
              while true
                a = bq.pop
                if a  === :end_of_data
                  Thread.current[:normalExit] = true
                  break
                end
                blk.call(*a)
              end
            rescue LocalJumpError
            rescue Exception => e
              eq << e
              Thread.current[:error] = e
              bq.pop # make sure the producer can move on and check eq
            ensure
              dq << self
              # If we didn't exit normally or due to an error, it was a break
              unless Thread.current[:normalExit] or Thread.current[:error]
                eq << ThreachDone.new
              end
            end
          end          
        end
    
        # The producer
        count = 0
        self.send(iterator) do |*x|
          # Bail if we've got an error
          if eq.size > 0
            e  = eq.pop
            raise e
          end
          bq.push x
          count += 1
        end
        
        # Now end it. 
        Thread.exclusive do
          bq.pop if bq.size > 0
          threads.times do
            bq << :end_of_data
          end
        end
        # Do the join
        consumers.each {|t| t.join}
      rescue ThreachDone => e
        # do nothing. We bailed out because of a break
      rescue Exception => e
        raise e
      end
    end
  end
    
end
