# docker_compose_host_hetzner
This is a Copier IaC template to deploy an OTree experiment on the LS Shikano BW cloud projekt. 

## Dependencies
- [Copier](https://copier.readthedocs.io/en/latest/)
- Terraform
- Ansible
- Ansible Role UBUNTU20-CIS:

    ```
    ansible-galaxy install -r ansible/requirements.yml
    ```

## Generate project
```
copier copy gh:jstet/docker_compose_host_hetzner  <project_name>
```
This will start an interactive prompt.



## Steps after Generation

1. Set environment variables
    To use the OpenStack apis with terraform you need your user Id and application credentials. Best practice is to set these tokens via the terminal with so they are not included in your code.
    ```
    export OS_APPLICATION_CREDENTIAL_ID="id"
    ```
    ```
    OS_APPLICATION_CREDENTIAL_SECRET="secret"
    ```

2. Initialize terraform
    ```
    cd terraform
    terraform init
    ```
3. If you dont want to change the terraform script, run the teraform apply command. The generates a plan you can review before approving it. After approval the VPS will be created.
    ```
    terraform apply
    ```
4. Navigate to the ansible subfolder

## Configurable Vars
- Name of server
- Server Type
- Image
- Location
- Backups
- docker compose version
- ssh key path
- dns zone name
- subdomain 
