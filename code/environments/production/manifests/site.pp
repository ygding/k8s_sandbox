$hostgroup=regsubst($hostname, '-*\d+$', '')
File {backup => false,}
#hiera_include('classes')
lookup('classes', {merge => unique}).include
