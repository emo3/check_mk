**Notice: Master branch is currently broken. Please use latest version tag 0.4.2**

Description
===========

[Check_MK](http://mathias-kettner.de/check_mk.html) is described as a general purpose Nagios-plugin for retrieving data. This cookbook aims to be the definitive cookbook for check_mk.

Check_MK and Nagios are both file configured and as such, have configuration shortcuts like host_groups (Nagios) and tags (Check_MK). This cookbook considers these types of configuration variables as a human interface, so in most cases you'll see duplicated settings. For example, when configuring custom checks in a role, these checks will be configured for each host separately.

This cookbook does not depend on the Nagios cookbook since it tries to do too much. Instead, it is treated as a backend and configured in a minimalistic fashion.

Most of the attributes correspond to the values that are expected from that packages.

Requirements
============

Platform
--------

### Currently supported platforms

* Ubuntu >= 10.04
* Debian >= 6.0.0

### Platforms to be supported (TODO)

* Red Hat branch

Cookbooks
---------

* [apache2](http://community.opscode.com/cookbooks/apache2)
* [fewbytes-common](https://github.com/fewbytes-cookbooks/fewbytes-common)
* [xinetd](http://community.opscode.com/cookbooks/xinetd)
* [ark](https://github.com/opscode-cookbooks/ark)
* [sudo](https://github.com/opscode-cookbooks/sudo)

Attributes
==========

Default attributes
------------------

The cookbook attributes

* `node["check_mk"]["server"]["package"]["name"]` - Check_MK package name (Default: check_mk)
* `node["check_mk"]["server"]["package"]["version"]` - Version
* `node["check_mk"]["server"]["package"]["filename"]` - Package file name
* `node["check_mk"]["server"]["package"]["url"]` - Download URL
* `node["check_mk"]["server"]["package"]["checksum"]` - Downloaded file checksum (sha256)  

* `node["check_mk"]["server"]["user"]` - Nagios user name (Default: nagios)
* `node["check_mk"]["server"]["group"]` - Nagios group (Default: nagios)  

* `node["check_mk"]["server"]["conf"]["dir"]` - Check_MK configuration directory (Default /etc/check_mk)
* `node["check_mk"]["server"]["conf"]["main"]` - Check_MK main configuration file (Default: /etc/check_mk/main.mk)
* `node["check_mk"]["server"]["conf"]["multisite"]` - Check_MK Multisite configuration file (Default: /etc/check_mk/multisite.mk)
* `node["check_mk"]["server"]["conf"]["unix_socket"]` - Nagios and Check_MK unix socket (Default: /var/log/nagios/rw/live)  

* `node["check_mk"]["nagios"]["conf.d"]` - Nagios configuration directory
* `node["check_mk"]["nagios"]["conf"]` - Nagios main config file (Default: /etc/nagios3/nagios.cfg)
* `node["check_mk"]["nagios"]["cgi"]` - Nagios cgi config file (Default: /etc/nagios3/cgi.cfg)
* `node["check_mk"]["nagios"]["command_file"]` - Nagios command file (Default: /var/log/nagios/rw/nagios.cmd)
* `node["check_mk"]["nagios"]["plugins_dir"]` - Nagios plugins directory, used primarily to target plugins from the agent (MRPE) (Default: /usr/lib/nagios/plugins)  

* `node["check_mk"]["nagios"]["extra_plugins"]` - Install nagios' extra plugins or not (Default: true)
* `node["check_mk"]["nagios"]["extra_plugins_package"]` - The extra plugins package name  

* `node["check_mk"]["www"]["auth"]` - CGI auth file (Default: /etc/nagios3/htpasswd.users)
* `node["check_mk"]["www"]["user"]` - Webserver user (Default: www-data)
* `node["check_mk"]["www"]["group"]` - Webserver group (Default: www-data)
* `node["check_mk"]["www"]["conf"]` - Check_MK webserver config file (Default: /etc/apache2/conf.d/zzz_check_mk.conf)

Optional node attributes
------------------------

Check_MK [configuration variables](http://mathias-kettner.de/checkmk_configvars.html) attributes

### Check_MK server config related attributes

These attributes configure global variables of the main.mk file.

TODO: !

### Check_MK hosts attributes

These attributes configure various related variables per host. On some of them, you'll see a hash with keys called pXX, only their values are used (this is due to how chef treats arrays in Attribute#deep\_merge). One advantage is that you can override a certain parameter from a different attribute set. Each attribute corresponds a variable in the list of [configuration variables](http://mathias-kettner.de/checkmk_configvars.html) of Check_MK.

#### [checks](http://mathias-kettner.de/checkmk_checks.html)

    'check_mk': {
        'config': {
            'checks': {
                'check_type': {
                    'check_name': {
                        'p01': '/usr/sbin/sshd',
                        'p02': '1',
                        'p03': '1',
                        'p04': '1',
                        'p05': '1'
                    }
                }
            }
        }
    }

* `check_type` - The check type, like ps or ps.perf.
* `check_name` - The check as will be seen in Nagios (Check_MK).
* Last level of attributes are the check parameters (only values are used). This structure is used to enable overriding specific values from high-level attributes.

#### [check_parameters](http://mathias-kettner.de/checkmk_configvars.html#check_parameters)

    'check_mk': {
        'config': {
            'check_parameters': {
                'service_pattern': 'parameters'
            }
        }
    }

* `service_pattern` - The service pattern as explained on Check\_MK documentation.
* `parameters` - Taken as is and placed as the first item in the check\_parameters tuple.

#### [extra\_service\_conf](http://mathias-kettner.de/checkmk_configvars.html#extra_service_conf)

    'check_mk': {
        'config': {
            'extra_service_conf': {
                'service_name': {
                    'active_checks_enabled': '0',
                    'is_volatile': '1'
                }
            }
        }
    }

Hash of key value pairs for configuration variables that will be attached to this service check.

* `service_name` - The service name as Nagios sees it

#### [legacy_checks](http://mathias-kettner.de/checkmk_legacy_checks.html)

    'check_mk': {
        'config': {
            'legacy_checks': {
                'check_name': {
                    'performance': "True",
                    'command': "/bin/echo I am a passive check only",
                    'extra_service_conf': {
                        'active_checks_enabled': '0'
                    }
                }
            }
        }
    }

* `check_name` - The service name
* `performance` - Flag for a performance check or not (Default: False). See legacy checks page.
* `extra_service_conf` - Same as extra\_service\_conf above, but applied to this legacy check specifically.

#### Forcibally ignoring a node from Check\_MK

    'check_mk': {
        'ignore': true
    }

Pseudo agents configuration
---------------------------

Many times you have some external device or a port on a load-balancer you'd like to monitor, in which case you cannot use the agent recipe. For this you can use psuedo agents through the check_mk data bag.

Pseudo agents are node-like attribute structures configured in a data bag item. The cookbook only looks at the structure which is relevant for registering the agent on Check_MK. By duplicating the relevant structure, we try to make it easier to remember or transfer some configuration from a node/role to a data bag item.

The server recipe looks for items in the data bag `check_mk`, with the pseudo_agents `usage` on the same `chef_environment`. The exact search call is `search(:check_mk, "usage:pseudo_agents AND chef_environment:#{node.chef_environment}")`.

An example for a data bag item

    {
        'id': 'some data bag item id',
        'usage': [
            'pseudo_agents'
        ],
        'chef_environment': [
            '_default'
        ],
        'agents': {
            'arbitrary.agent.name': {
                'fqdn': "somehost.somedomain",
                'ipv4': "ip.add.re.ss",
                'check_mk': {
                    'tags': ["sometag"],
                    'config': {
                        'legacy_checks': {
                            'Load balancer': {
                                'command': "$USER1$/check_http ..."
                                'performance': "False"
                            }
                        }
                    }
                }
            },
            'another.agent': {
                # ...
            }
        }
    }

* `usage` - Required to contain `pseudo_agents` so it would be returned by the search query.
* `chef_environment` - Must contain the same environment value like the server.
* `agents` - The recipe looks for agents under this key.
    * `arbitrary.agent.name` - Could be any legal data bag item key, not used by cookbook.
        * `fqdn` - Required. This is how the cookbook chooses the host name.
        * `ipv4` - Optional. Normally, the cookbook tries to find the best ip address to use, but since this is not a real node you must supply a real IP address (or hostname) if fqdn cannot be resolved.
        * `check_mk` - An attribute tree which is treated exactly as it would be in a node's attributes.

External agents configuration
-----------------------------

External agents are treated the same as peudo agents with a small difference. Pseudo agents are expected to be non-inventorizable, external agents are treated as normal Check\_MK agents.

This falls under the use-case where you want to monitor hosts that are not part of the Chef cluster. Such nodes need minimal configuration as they will be inventorized by Check\_MK.

The following is a simple example of an external agent data bag item.

    {
        'id': 'some data bag item id',
        'usage': [
            'external_agents'
        ],
        'chef_environment': [
            '_default'
        ],
        'agents': {
            'arbitrary.agent.name': {
                'fqdn': "somehost.somedomain",
                'ipv4': "ip.add.re.ss",
                'check_mk': {
                    'tags': ["sometag"]
                }
            },
            'another.agent': {
                # ...
            }
        }
    }

Usage
=====

Resources
---------

### check\_mk\_mrpe\_plugin

The check\_mk\_mrpe\_plugin adds a new [MRPE](http://mathias-kettner.de/checkmk_mrpe.html) plugin and creates the mrpe.cfg if needed.  
Check_MK treats MRPE plugins like NRPE plugin, so any Nagios plugin can be used.

    check_mk_mrpe_plugin "<plugin_name>"
        plugin "<plugin_name>"
        path "/path/to/plugin/executable"
        arguments "-H 127.0.0.1 --foo bar"
    end

Configuration variables not yet implemented
-------------------------------------------

* agent_ports
* dyndns_hosts
* ping_levels
* check_periods
* extra_host_conf (see legacy_checks implementation)
* ignored_services
* ignored_checks
* snmp_communities
* snmp_hosts
* snmp_ports
