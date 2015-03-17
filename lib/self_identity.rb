require 'moneta'
require_relative 'data_constructors'

storage = Moneta.new :File, dir: '.self_identity'

TracePoint.trace do |trace|
  @calls ||= []
  @returns ||= []
  @dependencies ||= []
  case trace.event
  when :call
    method_call = new_method_call from: trace
    @dependencies.concat dependencies_for(method_call)
    @calls.push method_call
  when :return
    @returns.push new_method_return(from: trace)
  when :b_return
    # not sure how to hook into method blocks
    # __method__ returns the method it was called from
  when :c_return
    # might need a C extension to hook into C calls
    # __method__ returns 'main'
  else
  end
  script_name = File.basename($PROGRAM_NAME, '.rb')
  storage.store "#{script_name}-calls", @calls
  storage.store "#{script_name}-returns", @returns
  storage.store "#{script_name}-dependencies", @dependencies
end

# don't put anything here unless you want it traced
