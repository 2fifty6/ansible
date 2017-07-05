#!/usr/bin/python

import xml.etree.ElementTree as ET

DOCUMENTATION="""

    Given that we have one or more XML files, we can parse them with this module
    as demonstrated below. It is important to note that if we pass a single XML
    file in as the 'definitions' argument, the payload will be a single element,
    whereas if we pass a list/array of files in as the 'definitions' argument,
    the payload will be a list of elements.

    Consider the following playbook:
    ----------------------------------------------------------------------------------------------
    - hosts: localhost
      vars:
        - xmldir: "../xmlfiles"
      tasks:
        - parseXML: definitions='{{ xmldir }}/database_instances.xml'
          register: results

        - set_fact:
            Instances: '{{ results.payload.Instances }}'

        - debug:
            msg: '{{ Instances }}'

    ---------------------------------------------------------------------------------------------

    ok: [localhost] => {
        "msg": [
            {
                "Instance": [
                    {
                        "DatabaseServer": "db-server-01",
                        "Name": "ABC"
                    },
                    {
                        "Name": "ABCD"
                    },
                    ....
                    {
                        "DatabaseServer": "db-server-02.local",
                        "Name": "ABCDE"
                    }
                ],
                "Name": "Example"
            },
            {
                ...
            }
        ]
    }


"""

def getChildren( element ):
    elementObject = {}
    for child in list(element):
        try:
            # we have seen this tag more than once, append to existing list
            elementObject[ child.tag ].append( getChildren(child) )
        except:
            try:
                # we have seen this tag once, convert this to an array
                duplicate = elementObject[ child.tag ]
                del elementObject[ child.tag ]
                elementObject[ child.tag ] = [
                    duplicate,
                    getChildren( child )
                    ]
            except:
                # we have not seen this tag yet
                elementObject[ child.tag ] = getChildren( child )

    # add all the attributes the the object here
    for attribute in element.attrib:
        elementObject[ attribute ] = element.attrib[ attribute ]
    return elementObject



def bail_out(module):
    module.fail_json(
        msg="Failed to parse xml definition(s). Please ensure the file path is correct and the syntax is valid xml."
        )

def main():
    module = AnsibleModule(
        argument_spec=dict(
            definitions=dict(required=True),
            ),
        supports_check_mode=True
        )

    payload = []
    definitions = module.params['definitions']
    if not isinstance( definitions, list ):
        definitions = [ definitions ]

    try:
        for definition in definitions:
            tree = ET.parse( definition )

            root = tree.getroot()
            newElement = { root.tag: getChildren( root ) }
            payload.append( newElement )
    except:
        bail_out( module )


    if isinstance(payload, list) and len(payload) == 1:
        payload = payload[0]
    module.exit_json(changed=False, payload=payload)

from ansible.module_utils.basic import *
main()

