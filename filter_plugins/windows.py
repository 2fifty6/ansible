
# Q: Why do we still have carriage returns in Windows line breaks?
# A: Backwards compatibility with typewriters a la MS-DOS.
# http://programmers.stackexchange.com/questions/29075/difference-between-n-and-r-n
def strip_crlf( a ):
    b = []
    for aa in a:
        b.append( aa.replace('\r','') )
    return b

class FilterModule(object):
    filter_map =  {
        'strip_crlf': strip_crlf,
    }

    def filters(self):
        return self.filter_map
