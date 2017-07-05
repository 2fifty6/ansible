import json, xmltodict, yaml

def xml_to_dict( *a ):
    result = xmltodict.parse(''.join(a))
    return result

def xml_to_json( *a ):
    xmlDict = xmltodict.parse( ''.join(a) )
    jsonDump = json.dumps( xmlDict )
    return jsonDump.replace("@", "")

class FilterModule(object):
    filter_map =  {
        'xml_to_dict': xml_to_dict,
        'xml_to_json': xml_to_json,
    }

    def filters(self):
        return self.filter_map
