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
To generate an IaC project from this repo, run the command below and replace "experiment_name" with a suitable name.
```
copier copy --UNSAFE gh:LS-Shikano/bw_cloud_otree_template <experiment_name>
```
This will start an interactive session in your terminal during which you have to provide:

- server_name: Hostname and name of server in the BWCloud portal. Valid characters for hostnames are ASCII(7) letters from a to z, the digits from 0 to 9, and the hyphen (-). A hostname may not start with a hyphen.
    
- server_flavor: What type of server do you want to create? This determines the ressources that are allocated for the server. See https://www.bw-cloud.org/de/bwcloud_scope/flavors

- ssh_key_path: Under which path is your public ssh key located? Example: /home/jstet/.ssh/id_rsa.pub
 
- os_user_id: Go to https://portal.bw-cloud.org/identity/users/ and insert the User ID. 

- github_repo: Provide the GitHub repo of the OTree experiment you want to deploy. Example: https://github.com/LS-Shikano/BallotExp_clean

- github_token: Provide a GitHub token that can access the repo. Follow [this](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) tutorial. Select LS-Shikano as resource owner. Select "only selected repositories" and select the repo containing the experiment. Under Repo permissions select **Read only** for **Content**.


## Steps after Generation

1. Set environment variables
    To use the OpenStack apis with terraform you need your user Id and application credentials. Best practice is to set these tokens via the terminal with so they are not included in your code.
    ```
    export OS_APPLICATION_CREDENTIAL_ID="id"
    ```
    ```
    OS_APPLICATION_CREDENTIAL_SECRET="secret"
    ```

2. Navigate to the terraform subfolder and initialize terraform.
    ```
    terraform init
    ```
3. If you dont want to change the terraform script, run the teraform apply command. The generates a plan you can review before approving it. After approval the VPS will be created.
    ```
    terraform apply
    ```
4. Navigate to the ansible subfolder


