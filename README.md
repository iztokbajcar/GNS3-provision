# GNS3-provision
The goal of this repository is to provide a fast and easy way to set up a GNS3 virtual machine which the user can then connect to (graphically) via their web browser. 
Currently, the tools provided consist of provisioning scripts for **Vagrant** and **cloud-init**.

# Dependencies
In order to use the tools/scripts provided in this repository, you first have to install a few dependencies onto your system, depending on the framework you wish to use.

## Vagrant
You can find an installation guide for your platform on the [downloads](https://www.vagrantup.com/downloads) page of the Vagrant website.

## Cloud-init
If you intend to set up GNS3 using cloud-init, a simple solution would be to install [Multipass](https://multipass.run/).  
Most cloud providers, such as [Amazon Web Services](https://aws.amazon.com/), [Microsoft Azure](https://azure.microsoft.com/en-us/) and [Oracle Cloud](https://www.oracle.com/cloud/), however, support it as a part of their virtual machine setup process and allow you to bootstrap a script of your choice onto the cloud setup process.  