#
# flatten.rb
#
module Puppet::Parser::Functions
  newfunction(:flatten, :type => :rvalue, :doc => <<-DOC
    @summary
      This function flattens any deeply nested arrays and returns a single flat array
      as a result.

    @return
      convert nested arrays into a single flat array

    @example Example usage

      flatten(['a', ['b', ['c']]])` returns: `['a','b','c']

    > **Note:** **Deprecated** from Puppet 5.5.0, this function has been replaced with a
    built-in [`flatten`](https://puppet.com/docs/puppet/latest/function.html#flatten) function.
  DOC
             ) do |arguments|

    raise(Puppet::ParseError, "flatten(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1

    array = arguments[0]

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'flatten(): Requires array to work with')
    end

    result = array.flatten

    return result
  end
end

# vim: set ts=2 sw=2 et :
