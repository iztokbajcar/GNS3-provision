# GNS3-provision
The goal of this repository is to provide a fast and easy way to set up a GNS3 virtual machine which the user can then connect to (graphically) via their web browser. 
Currently, the tools provided consist of provisioning scripts for **Vagrant** and **cloud-init**.

# Dependencies
In order to use the tools/scripts provided in this repository, you first have to install a few dependencies onto your system, depending on the framework you wish to use.

## Vagrant
You can find an installation guide for your platform on the [downloads](https://www.vagrantup.com/downloads) page of the Vagrant website.

## Cloud-init
If you intend to set up GNS3 using cloud-init, a simple solution would be to install [Multipass](https://multipass.run/).  
Most cloud providers, such as [Amazon Web Services](https://aws.amazon.com/), [Microsoft Azure](https://azure.microsoft.com/en-us/) and [Oracle Cloud](https://www.oracle.com/cloud/), however, support it as a part of their virtual machine setup process and allow you to bootstrap a script of your choice onto the cloud setup process. Please refer to the relevant provider's documentation for more information on the matter.

After the dependencies are hopefully taken care of, make sure you have cloned this repository (you will find the instructions, as well as an option to download the whole repository as a zip file, on the top of this page in the Code dropdown menu - next to the About section). 

# The passwords?
When you get your hands on the contents, there is but one tiny thing, although very important, still for you to do before you jump into action. And that is ***to change the provided passwords***! If you are only going to be using your soon-to-be-created virtual machine on your local computer, do it anyway. For the sake of principle.

## Vagrant
You will find the default passwords on the very top of the [provision.sh](provision.sh) script. To be precise, the passwords you are encouraged to change are the GUACAMOLE_ADMIN_PASSWORD and VNC_CONNECTION_PASSWORD environment variables, which, probably unsurprisingly, dictate the admin guacamole password[^1] and the password you will need when connecting to the machine.
## cloud-init
The procedure to set up passwords for cloud-init differs a bit from the Vagrant alternative. In the [cloud-config.yaml](cloud-config.yaml) file: 
* on line 107, change the text between the quotes according to your liking. It will represent the Guacamole admin password. The default value is **Ge5L0**.
* on line 245, the text on the right side of the equals (`=`) sign will be your VNC connection password, as well as the desktop login password. The default value is **GNS3jeZ4k0n**.

[^1]: No, we are not a Mexican restaurant, you will learn more about Guacamole later :slightly_smiling_face:
