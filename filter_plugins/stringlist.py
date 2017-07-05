import re

# TODO figure out why this doesn't work anymore

# this library of methods all take in a list of strings
# and apply an opertation to them. For each method like
#    f( x, y, z[, ... ] ):
# the method can be used in a playbook like:
#    key: '{{ value | f( y1, z1[, ... ] ) }}'

# replace all occurrences of a match pattern with a replace pattern
def string_list_replace( string_list, match, replace ):
  string_list_replaced = []
  for string in string_list:
    string_list_replaced.append( string.replace(match, replace) )
  return string_list_replaced

# prepend a string to every string in a list
def string_list_prepend( string_list, prepend_string ):
    prepended_string_list = []
    for string_item in string_list:
        prepended_string_list.append( prepend_string + string_item )
    return prepended_string_list

# remove any string that matches a given pattern from a list of strings
# by default does not use regular expressions, but can be overridden
def string_list_filter( string_list, match, regex=False ):
    filtered_string_list = []
    for string_item in string_list:
        if not regex:
            if string_item.find( match ) != -1:
                filtered_string_list.append( string_item )
        else:
            if re.search( match, string_item) != None:
                filtered_string_list.append( string_item )
    return filtered_string_list

class FilterModule(object):
    filter_map =  {
        'string_list_replace': string_list_replace,
        'string_list_prepend': string_list_prepend,
        'string_list_filter': string_list_filter,
    }

    def filters(self):
        return self.filter_map
