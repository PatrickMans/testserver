1 set user as 'export TF_VAR_user_name=<password>'

2 set password as 'export TF_VAR_password=<password>'

3 login to horizon web interface and save ca-bundle/stack_naturalis_nl.ca-bundle.crt from object-store to /usr/local/share/ca-certificates/stack_naturalis_nl.ca-bundle.crt

4 run 'sudo update-ca-certificates'

5 generate your own ssh key and save the public key as "~/.ssh/id_rsa.terraform"

6 install terraform

7 run terraform plan, etc
