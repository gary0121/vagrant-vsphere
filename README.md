[![Build Status](https://travis-ci.org/nsidc/vagrant-vsphere.svg?branch=master)](https://travis-ci.org/nsidc/vagrant-vsphere)

# Vagrant vSphere Provider

This is a [Vagrant](http://www.vagrantup.com) 1.6.3+ plugin that adds a
[vSphere](http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc_50%2Fright-pane.html)
provider to Vagrant, allowing Vagrant to control and provision machines using
VMware. New machines are created from virtual machines or templates which must
be configured prior to using using this provider.

This provider is built on top of the
[RbVmomi](https://github.com/vmware/rbvmomi) Ruby interface to the vSphere API.

## Requirements

* Vagrant 1.6.3+
* VMware with vSphere API
* Ruby 1.9+
* libxml2, libxml2-dev, libxslt, libxslt-dev

## Current Version
**version: 0.19.1**

vagrant-vsphere (**version: 0.19.1**) is available from
[RubyGems.org](https://rubygems.org/gems/vagrant-vsphere)

## Installation

Install using standard Vagrant plugin method:

```bash
vagrant plugin install vagrant-vsphere
```

This will install the plugin from RubyGems.org.

Alternatively, you can clone this repository and build the source with `gem
build vSphere.gemspec`. After the gem is built, run the plugin install command
from the build directory.

### Potential Installation Problems

The requirements for [Nokogiri](http://nokogiri.org/) must be installed before
the plugin can be installed. See the
[Nokogiri tutorial](http://nokogiri.org/tutorials/installing_nokogiri.html) for
detailed instructions.

The plugin forces use of Nokogiri ~> 1.5 to prevent conflicts with older
versions of system libraries, specifically zlib.

## Usage

After installing the plugin, you must create a vSphere box. The example_box
directory contains a metadata.json file that can be used to create a dummy box
with the command:

```bash
tar cvzf dummy.box ./metadata.json
```

This can be installed using the standard Vagrant methods or specified in the
Vagrantfile.

After creating the dummy box, make a Vagrantfile that looks like the following:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = 'dummy'
  config.vm.box_url = './example_box/dummy.box'

  config.vm.provider :vsphere do |vsphere|
    vsphere.host = 'HOST NAME OF YOUR VSPHERE INSTANCE'
    vsphere.compute_resource_name = 'YOUR COMPUTE RESOURCE'
    vsphere.resource_pool_name = 'YOUR RESOURCE POOL'
    vsphere.template_name = 'YOUR VM TEMPLATE'
    vsphere.name = 'NEW VM NAME'
    vsphere.user = 'YOUR VMWARE USER'
    vsphere.password = 'YOUR VMWARE PASSWORD'
  end
end
```

And then run `vagrant up --provider=vsphere`.

### Custom Box

The bulk of this configuration can be included as part of a custom box. See the
[Vagrant documentation](http://docs.vagrantup.com/v2/boxes.html) and the Vagrant
[AWS provider](https://github.com/mitchellh/vagrant-aws/tree/master/example_box)
for more information and an example.

### Supported Commands

Currently the only implemented actions are `up`, `halt`, `reload`, `destroy`,
and `ssh`.

`up` supports provisioning of the new VM with the standard Vagrant provisioners.

## Configuration

This provider has the following settings, all are required unless noted:

* `host` - IP or name for the vSphere API
* `insecure` - _Optional_ verify SSL certificate from the host
* `user` - user name for connecting to vSphere
* `password` - password for connecting to vSphere. If no value is given, or the
  value is set to `:ask`, the user will be prompted to enter the password on
  each invocation.
* `data_center_name` - _Optional_ datacenter containing the computed resource,
  the template and where the new VM will be created, if not specified the first
  datacenter found will be used
* `compute_resource_name` - _Required if cloning from template_ the name of the
  host containing the resource pool for the new VM
* `resource_pool_name` - the resource pool for the new VM. If not supplied, and
  cloning from a template, uses the root resource pool
* `clone_from_vm` - _Optional_ use a virtual machine instead of a template as
  the source for the cloning operation
* `template_name` - the VM or VM template to clone
* `vm_base_path` - _Optional_ path to folder where new VM should be created, if
  not specified template's parent folder will be used
* `name` - _Optional_ name of the new VM, if missing the name will be auto
  generated
* `customization_spec_name` - _Optional_ customization spec for the new VM
* `data_store_name` - _Optional_ the datastore where the VM will be located
* `linked_clone` - _Optional_ link the cloned VM to the parent to share virtual
  disks
* `proxy_host` - _Optional_ proxy host name for connecting to vSphere via proxy
* `proxy_port` - _Optional_ proxy port number for connecting to vSphere via
  proxy
* `vlan` - _Optional_ vlan to connect the first NIC to
* `memory_mb` - _Optional_ Configure the amount of memory (in MB) for the new VM
* `cpu_count` - _Optional_ Configure the number of CPUs for the new VM
* `mac` - _Optional_ Used to set the mac address of the new VM

### Cloning from a VM rather than a template

To clone from an existing VM rather than a template, set `clone_from_vm` to
true. If this value is set, `compute_resource_name` and `resource_pool_name` are
not required.

### Template_Name

* The template name includes the actual template name and the directory path
  containing the template.
* **For example:** if the template is a directory called **vagrant-templates**
  and the template is called **ubuntu-lucid-template** the `template_name`
  setting would be:

```
vsphere.template_name = "vagrant-templates/ubuntu-lucid-template"
```

![Vagrant Vsphere Screenshot](https://raw.githubusercontent.com/nsidc/vagrant-vsphere/master/vsphere_screenshot.png)

### VM_Base_Path

* The new vagrant VM will be created in the same directory as the template it
  originated from.
* To create the VM in a directory other than the one where the template was
  located, include the **vm_base_path** setting.
* **For example:** if the machines will be stored in a directory called
  **vagrant-machines** the `vm_base_path` would be:

```
vsphere.vm_base_path = "vagrant-machines"
```

![Vagrant Vsphere Screenshot](https://raw.githubusercontent.com/nsidc/vagrant-vsphere/master/vsphere_screenshot.png)

### Setting a static IP address

To set a static IP, add a private network to your vagrant file:

```ruby
config.vm.network 'private_network', ip: '192.168.50.4'
```

The IP address will only be set if a customization spec name is given. The
customization spec must have network adapter settings configured. For each
private network specified, there needs to be a corresponding network adapter in
the customization spec. An error will be thrown if there are more networks than
adapters.

### Auto name generation

The name for the new VM will be automagically generated from the Vagrant machine
name, the current timestamp and a random number to allow for simultaneous
executions.

This is useful if running Vagrant from multiple directories or if multiple
machines are defined in the Vagrantfile.

### Setting the MAC address

To set a static MAC address, add a `vsphere.mac` to your `Vagrantfile`:

```ruby
vsphere.mac = '00:50:56:XX:YY:ZZ'
```

Take care to avoid using invalid or duplicate VMware MAC addresses, as this can
easily break networking.

## Example Usage

### FILE: Vagrantfile

```ruby
VAGRANT_INSTANCE_NAME   = "vagrant-vsphere"

Vagrant.configure("2") do |config|
  config.vm.box     = 'vsphere'
  config.vm.box_url = 'https://vagrantcloud.com/ssx/boxes/vsphere-dummy/versions/0.0.1/providers/vsphere.box'

  config.vm.hostname = VAGRANT_INSTANCE_NAME
  config.vm.define VAGRANT_INSTANCE_NAME do |d|
  end

  config.vm.provider :vsphere do |vsphere|
    vsphere.host                  = 'vsphere.local'
    vsphere.name                  = VAGRANT_INSTANCE_NAME
    vsphere.compute_resource_name = 'vagrant01.vsphere.local'
    vsphere.resource_pool_name    = 'vagrant'
    vsphere.template_name         = 'vagrant-templates/ubuntu14041'
    vsphere.vm_base_path          = "vagrant-machines"

    vsphere.user     = 'vagrant-user@vsphere'
    vsphere.password = '***************'
    vsphere.insecure = true
  end
end
```

### Vagrant Up

```bash
vagrant up --provider=vsphere
```
### Vagrant SSH

```bash
vagrant ssh
```

### Vagrant Destroy

```bash
vagrant destroy
```

## Version History

See
[`CHANGELOG.md`](https://github.com/nsidc/vagrant-vsphere/blob/master/CHANGELOG.md).

## Contributing

See
[`DEVELOPMENT.md`](https://github.com/nsidc/vagrant-vsphere/blob/master/DEVELOPMENT.md).

## License

The Vagrant vSphere Provider is licensed under the MIT license. See
[LICENSE.txt][license].

[license]: https://raw.github.com/nsidc/vagrant-vsphere/master/LICENSE.txt

## Credit

This software was developed by the National Snow and Ice Data Center with
funding from multiple sources.
