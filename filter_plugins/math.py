def from_hex( value ):
    try:
        result = int( value, 16 )
    except:
        result = 0
    return result

class FilterModule(object):
    filter_map =  {
        'from_hex': from_hex,
    }

    def filters(self):
        return self.filter_map
