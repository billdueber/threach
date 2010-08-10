require 'thread'
module Enumerable
  
  def threach(threads=0, iterator=:each, &blk)
    if threads == 0
      self.send(iterator) do |*args|
        blk.call *args
      end
    else
      bq = SizedQueue.new(threads * 2)
      consumers = []
      threads.times do |i|
        consumers << Thread.new(i) do |i|
          until (a = bq.pop) === :end_of_data
            blk.call(*a)
          end
        end          
      end
    
      # The producer
      count = 0
      self.send(iterator) do |*x|
        bq.push x
        count += 1
      end
      # Now end it
      threads.times do 
        bq << :end_of_data
      end
      # Do the join
      consumers.each {|t| t.join}
    end
  end
    
end
